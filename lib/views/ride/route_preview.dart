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

  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  final String apiKey = 'e80bab52-948d-4148-9f15-f56591cca16a';
  final String routeApiKey =
      '5b3ce3597851110001cf62489839c0fa729b43278c806b8b3197872e';

  @override
  void initState() {
    super.initState();
    _fetchRoute();
  }

  //! confirm ride function
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
        'date': selectedDate,
        'time':
            selectedTime != null
                ? '${selectedTime!.hour.toString().padLeft(2, '0')}:${selectedTime!.minute.toString().padLeft(2, '0')}'
                : null,
        'timestamp': FieldValue.serverTimestamp(),
        'status': 'pending',
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
          final bounds = LatLngBounds(
            start, // Start location
            end, // End location
          );
          _mapController.move(bounds.center, 11.5);
          _showLoading = false; //  Hide loading once route is ready
        });
      } else {
        print('Failed to fetch route data.');
      }
    } catch (e) {
      print('Error fetching route: $e');
    }
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
              initialCenter: widget.pickUp,
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
                      child: Icon(Icons.location_on, color: Colors.blue),
                    ),
                    Marker(
                      point: widget.dropOff,
                      width: 40,
                      height: 40,
                      child: Icon(Icons.location_on, color: Colors.red),
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
                          }
                          //! show loading
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

                          // Proceed with confirmation logic
                          print(
                            'Confirm Ride: $selectedDate at ${selectedTime!.format(context)}',
                          );
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
