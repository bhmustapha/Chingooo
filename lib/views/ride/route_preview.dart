import 'package:carpooling/main.dart';
import 'package:carpooling/widgets/main_navigator.dart';
import 'package:carpooling/widgets/snackbar_utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'utils/ride_utils.dart';
import 'package:carpooling/models/vehicle.dart';
import 'package:carpooling/services/vehicle_service.dart';

import 'package:lucide_icons_flutter/lucide_icons.dart';

class RoutePreviewPage extends StatefulWidget {
  final LatLng pickUp;
  final LatLng dropOff;
  final String destinationName;
  final String pickUpName;

  RoutePreviewPage({
    required this.pickUp,
    required this.dropOff,
    required this.destinationName,
    required this.pickUpName,
  });

  @override
  _RoutePreviewPageState createState() => _RoutePreviewPageState();
}

class _RoutePreviewPageState extends State<RoutePreviewPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  // loadingg
  bool _showLoading = true;
  final MapController _mapController = MapController();
  List<LatLng> routePoints = [];
  double? distanceKm;
  double? currentPrice;

  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  int placeCount = 1;

  final VehicleService _vehicleService = VehicleService();
  List<Vehicle> _driverVehicles = [];
  Vehicle? _selectedVehicle;

  final String apiKey = 'e80bab52-948d-4148-9f15-f56591cca16a';
  final String routeApiKey =
      '5b3ce3597851110001cf62489839c0fa729b43278c806b8b3197872e';

  @override
  void initState() {
    super.initState();
    _fetchRoute();
    _fetchVehicles();
  }

  Future<void> _fetchVehicles() async {
    try {
      _vehicleService.getMyVehicles().listen((vehicles) {
        setState(() {
          _driverVehicles = vehicles;
          //auto-select the first vehicle if available and none is selected
          if (_selectedVehicle == null && _driverVehicles.isNotEmpty) {
            _selectedVehicle = _driverVehicles.first;
          } else if (_selectedVehicle != null &&
              !_driverVehicles.contains(_selectedVehicle)) {
            // If the previously selected vehicle was deleted, clear selection
            _selectedVehicle = null;
          }
        });
      });
    } catch (e) {
      showErrorSnackbar(context, 'Failed to load vehicles: $e');
    }
  }

  

  Future<bool> confirmRide() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      // creator infos
      final userDoc =
          await _firestore.collection('users').doc(currentUser!.uid).get();
      final userData = userDoc.data();

      // Save ride details to Firestore
      // Generate a new doc reference to get the ID
      final newRideRef = _firestore.collection('rides').doc();
      final rideId = newRideRef.id;

      // Save ride details with ID inside
      await newRideRef.set({
        'ride_id': rideId, // Store the ID inside the document
        'userId': currentUser.uid,
        'userName': userData?['name'] ?? 'unknown',
        'pickUp': {
          'latitude': widget.pickUp.latitude,
          'longitude': widget.pickUp.longitude,
        },
        'dropOff': {
          'latitude': widget.dropOff.latitude,
          'longitude': widget.dropOff.longitude,
        },
        'pickUpName': widget.pickUpName,
        'destinationName': widget.destinationName,
        'distanceKm': distanceKm,
        'price': currentPrice,
        'date': selectedDate,
        'time':
            selectedTime != null
                ? '${selectedTime!.hour.toString().padLeft(2, '0')}:${selectedTime!.minute.toString().padLeft(2, '0')}'
                : null,
        'timestamp': FieldValue.serverTimestamp(),
        'status': 'pending',
        'placeCount': placeCount,
        'vehicle': {
          'vehicleMake': _selectedVehicle?.make,
          'vehicleModel': _selectedVehicle?.model,
          'vehicleId': _selectedVehicle?.id,
          'maxPlaces': _selectedVehicle?.capacity,
        },
        'leftPlace': placeCount,
        'bookedPlaces': 0
      });

      return true;
    } catch (e) {
      print('Error confirming ride: $e');
      return false;
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );
    if (picked != null) setState(() => selectedDate = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      
    );
    if (picked != null) setState(() => selectedTime = picked);
  }

  Future<void> _fetchRoute() async {
    final start = widget.pickUp;
    final end = widget.dropOff;

    final url = Uri.parse(
      'https://api.openrouteservice.org/v2/directions/driving-car'
      '?api_key=$routeApiKey'
      '&start=${start.longitude},${start.latitude}'
      '&end=${end.longitude},${end.latitude}',
    );

    try {
      final response = await http.get(url);

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final coords = data['features'][0]['geometry']['coordinates'];
        final distance =
            data['features'][0]['properties']['segments'][0]['distance'];

        setState(() {
          routePoints =
              coords
                  .map<LatLng>((point) => LatLng(point[1], point[0]))
                  .toList();
          distanceKm = distance / 1000;

          double rawPrice = RideUtils.calculateRidePrice(distanceKm);
          currentPrice =
              (rawPrice / 10).round() * 10; // Round to nearest 10 DZD

          _mapController.move(
            LatLng(35.6, -0.6),
            11.5,
          ); // atrick to center tha map
          _showLoading = false; //  Hide loading once route is ready
        });
      } else {
        print('Failed to fetch route data.');
      }
    } catch (e) {
      print('Error fetching route: $e');
    }
  }

  // show the adjustment sheet
  void showPriceAdjustmentSheet(BuildContext context) {
    final range = RideUtils.getNegotiablePriceRange(
      distanceKm,
      marginPercent: 20,
    );

    // Round values to nearest 10 (10 dzd hia sghira)
    int base = (range['base']! / 10).round() * 10;
    int min = (range['min']! / 10).floor() * 10;
    int max = (range['max']! / 10).ceil() * 10;

    int tempPrice = base;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Adjust Ride Price (DZD)',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    '$tempPrice DZD',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 30),
                  Row(
                    children: [
                      Expanded(
                        child: Slider(
                          min: min.toDouble(),
                          max: max.toDouble(),
                          divisions: ((max - min) ~/ 10),
                          value: tempPrice.toDouble(),
                          onChanged: (value) {
                            setModalState(() {
                              tempPrice = value.round();
                            });
                          },
                          label: '$tempPrice DZD',
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            currentPrice = tempPrice.toDouble();
                          });
                          Navigator.pop(context);
                        },
                        icon: Icon(Icons.check),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showEditPlacesSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        int tempPlaceCount = placeCount;
        int effectiveMaxCapacity = _selectedVehicle?.capacity ?? 0;

        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (effectiveMaxCapacity == 0)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Text(
                        'Please select a vehicle first to set places.',
                        style: TextStyle(color: Colors.red, fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  // Plus/Minus and count row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // - Button (icon only)
                      IconButton(
                        onPressed:
                            tempPlaceCount > 0
                                ? () => setModalState(() => tempPlaceCount--)
                                : null,
                        icon: Icon(
                          Icons.remove_circle_outline,
                          size: 50,
                          color: tempPlaceCount > 0 ? Colors.blue : Colors.grey,
                        ),
                      ),

                      // Count in the center
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Text(
                          '$tempPlaceCount',
                          style: TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      // + Button (icon only)
                      IconButton(
                        onPressed:
                            tempPlaceCount < effectiveMaxCapacity
                                ? () => setModalState(() => tempPlaceCount++)
                                : null,
                        icon: Icon(
                          Icons.add_circle_outline,
                          size: 50,
                          color:
                              tempPlaceCount < effectiveMaxCapacity
                                  ? Colors.blue
                                  : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  if (effectiveMaxCapacity > 0)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        'Max: $effectiveMaxCapacity places (based on selected vehicle)',
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ),

                  SizedBox(height: 32),

                  // Confirm Button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 80),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() => placeCount = tempPlaceCount);
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          backgroundColor: Colors.blue,
                        ),
                        child: Text(
                          'Confirm',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    final tileLayerUrl =
        isDark
            ? 'https://tiles.stadiamaps.com/tiles/alidade_smooth_dark/{z}/{x}/{y}{r}.png?api_key=$apiKey'
            : 'https://tiles.stadiamaps.com/tiles/alidade_smooth/{z}/{x}/{y}{r}.png?api_key=$apiKey';
    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: widget.dropOff,
              initialZoom: 13.0,
            ),
            children: [
              TileLayer(
                urlTemplate: tileLayerUrl,
                userAgentPackageName: 'com.example.app',
              ),
              if (!_showLoading)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: widget.pickUp,
                      width: 40,
                      height: 40,
                      child: Icon(Icons.location_history, color: Colors.blue),
                    ),
                    Marker(
                      point: widget.dropOff,
                      width: 40,
                      height: 40,
                      child: Icon(Icons.location_on, color: Colors.blue),
                    ),
                  ],
                ),
              if (routePoints.isNotEmpty)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: routePoints,
                      strokeWidth: 4.0,
                      color: Colors.blue,
                    ),
                  ],
                ),
            ],
          ),
          if (_showLoading) // Show loader on top
            const Center(child: CircularProgressIndicator(color: Colors.blue)),

          Positioned(
            top: 20,
            left: 10,
            child: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: Icon(LucideIcons.arrowLeft, color: Colors.blue),
            ),
          ),

          Positioned(
            bottom: 10,
            left: 10,
            right: 10,
            child: Container(
              decoration: BoxDecoration(
                color:
                    themeNotifier.value == ThemeMode.light
                        ? Colors.white
                        : Colors.grey[900],
                borderRadius: BorderRadius.circular(14),
              ),

              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${widget.pickUpName} → ${widget.destinationName}',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    if (distanceKm != null)
                      Text(
                        'Distance: ${distanceKm!.toStringAsFixed(2)} km',
                        style: TextStyle(fontSize: 16),
                      ),
                    SizedBox(height: 16),
                    if (currentPrice != null)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.attach_money,
                                color: Colors.blue,
                                size: 20,
                              ),
                              Text(
                                'Price: ${currentPrice!.toInt()} DZD',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.blue,
                                ),
                              ),
                            ],
                          ),
                          TextButton(
                            onPressed: () {
                              showPriceAdjustmentSheet(context);
                            },
                            child: Text('Adjust Price'),
                          ),
                        ],
                      ),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: _pickDate,
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                vertical: 12,
                                horizontal: 16,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Text(
                                selectedDate != null
                                    ? '${selectedDate!.toLocal()}'.split(' ')[0]
                                    : 'Select Date',
                                style: TextStyle(fontSize: 14),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: GestureDetector(
                            onTap: _pickTime,
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                vertical: 12,
                                horizontal: 16,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Text(
                                selectedTime != null
                                    ? selectedTime!.format(context)
                                    : 'Select Time',
                                style: TextStyle(fontSize: 14),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),

                    _driverVehicles.isEmpty
                        ? Text(
                          // Display message if no vehicles are added
                          'No vehicles added. Please add a vehicle first.',
                          style: TextStyle(color: Colors.red),
                        )
                        : DropdownButtonFormField<Vehicle>(
                          value: _selectedVehicle,
                          decoration: InputDecoration(
                            labelText: 'Select Your Vehicle',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            prefixIcon: Icon(Icons.car_rental),
                          ),
                          items:
                              _driverVehicles.map((vehicle) {
                                return DropdownMenuItem(
                                  value: vehicle,
                                  child: Text(
                                    '${vehicle.make} ${vehicle.model}',
                                  ),
                                );
                              }).toList(),
                          onChanged: (Vehicle? newValue) {
                            setState(() {
                              _selectedVehicle = newValue;// Update place count when vehicle changes
                            });
                          },
                          validator: (value) {
                            if (value == null) {
                              return 'Please select a vehicle';
                            }
                            return null;
                          },
                        ),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Places: $placeCount',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            if (_selectedVehicle == null) {
                              // ✨ NEW Check
                              showErrorSnackbar(
                                context,
                                'Please select a vehicle first to adjust places.',
                              );
                              return;
                            }
                            _showEditPlacesSheet(
                              context,
                            ); // ✅ No need to pass maxCapacity now, as it's fetched from _selectedVehicle inside the sheet.
                          },
                          child: Text('Adjust Places'),
                        ),
                      ],
                    ),

                    SizedBox(height: 20),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          //! async to wait the server later
                          if (selectedDate == null || selectedTime == null) {
                            showErrorSnackbar(
                              context,
                              'Please select both date and time before confirming.',
                            );
                            return;
                          } else if (placeCount == 0) {
                            showErrorSnackbar(
                              context,
                              'please set place count',
                            );
                            return;
                          } else if (_selectedVehicle == null) {
                            showErrorSnackbar(
                              context,
                              'Please select a vehicle for this ride.',
                            );
                            return;
                          }
                         
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder:
                                (_) => Center(
                                  child: CircularProgressIndicator(
                                    color: Colors.blue,
                                  ),
                                ),
                          );
                          //a var to take the result
                          bool success = await confirmRide();

                          //Dismiss the loading dialog
                          Navigator.of(context).pop();

                          if (success) {
                            //Pop all pages and show a snackbar on home page
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MainNavigator(),
                              ),
                            );
                            showSuccessSnackbar(
                              context,
                              'Ride confirmed successfully!',
                            );
                          } else {
                            //Stay on the same page and show error
                            showErrorSnackbar(
                              context,
                              'Failed to confirm ride. Please try again.',
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: Text(
                          'Confirm Ride',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
