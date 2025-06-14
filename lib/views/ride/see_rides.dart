import 'package:carpooling/services/booking_service.dart';
import 'package:carpooling/themes/costum_reusable.dart';
import 'package:carpooling/views/profile/users_profiles.dart';
import 'package:carpooling/views/ride/utils/ride_utils.dart';
import 'package:carpooling/widgets/snackbar_utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/chat_services.dart';
import '../messages/message_page.dart';

class SeeRidesPage extends StatefulWidget {
  final String destinationLocation;
  final LatLng? initialPickupLocation;
  final Future<List<Map<String, dynamic>>> Function(String)
  fetchSuggestionsCallback;
  final double distanceInKm;
  final LatLng destinationCoords;

  SeeRidesPage({
    required this.destinationLocation,
    required this.fetchSuggestionsCallback,
    this.initialPickupLocation,
    required this.distanceInKm,
    required this.destinationCoords,
    super.key,
  });

  @override
  State<SeeRidesPage> createState() => _SeeRidesPageState();
}

class _SeeRidesPageState extends State<SeeRidesPage> {
  late TextEditingController pickupController;
  List<Map<String, dynamic>> suggestions = [];
  LatLng? selectedPickupCoords;
  String? pickupAddress;
  bool _isLoading = false;
  bool _isBookingLoading = false;
  bool isValidateLocation = false;
  int? currentPrice;

  @override
  void initState() {
    super.initState();
    pickupController = TextEditingController(
      text: widget.initialPickupLocation != null ? "Current Location" : '',
    );
    selectedPickupCoords = widget.initialPickupLocation;
  }

  @override
  void dispose() {
    pickupController.dispose();
    super.dispose();
  }

  void onPickupChanged(String input) async {
    if (input.isEmpty) {
      setState(() {
        suggestions = [];
      });
      return;
    }
    final fetchedSuggestions = await widget.fetchSuggestionsCallback(input);
    setState(() {
      suggestions = fetchedSuggestions;
    });
  }

  void onSuggestionSelected(Map<String, dynamic> suggestion) {
    setState(() {
      pickupController.text = suggestion['name'];
      selectedPickupCoords = LatLng(suggestion['lat'], suggestion['lon']);
      suggestions = [];
    });
    FocusScope.of(context).unfocus();
  }

  Future<bool> isValidLocation(String input) async {
    // to check if the input is a correct location
    try {
      if (input.trim().isEmpty) return false;

      List<Location> locations = await locationFromAddress(input);
      return locations.isNotEmpty;
    } catch (e) {
      print('Invalid location: $e');
      return false;
    }
  }

  int placeCount = 1; // Default number of places
  void showRequestRideBottomSheet() {
    final priceRange = RideUtils.getNegotiablePriceRange(widget.distanceInKm);
    double? min = (priceRange['min']! / 10).floor() * 10;
    double? max = (priceRange['max']! / 10).ceil() * 10;
    int tempPrice = (priceRange['base']! / 10).round() * 10;

    DateTime selectedDateTime = DateTime.now();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 6,
                        margin: EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.grey.shade400,
                        ),
                      ),
                    ),
                    Text('Request Ride', style: TextStyle(fontSize: 20)),
                    SizedBox(height: 20),
                    Text('Destination:'),
                    SizedBox(height: 5),
                    Text(
                      widget.destinationLocation,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 20),
                    Text('Pickup Location:'),
                    SizedBox(height: 5),
                    TextField(
                      controller: pickupController,
                      decoration: InputDecoration(
                        errorText:
                            pickupController.text == 'Current Location'
                                ? null
                                : isValidateLocation
                                ? null
                                : 'Invalid location',
                        hintText: 'Search pickup location',
                        contentPadding: EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 20,
                        ),
                        border: roundedInputBorder(14.0),
                        enabledBorder: roundedInputBorder(14.0),
                        focusedBorder: roundedInputBorder(14.0),
                      ),

                      onChanged: (value) {
                        setSheetState(() async {
                          onPickupChanged(value);
                          isValidateLocation = await isValidLocation(value);
                        });
                      },
                    ),

                    if (suggestions.isNotEmpty)
                      ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: suggestions.length,
                        itemBuilder: (context, index) {
                          final suggestion = suggestions[index];
                          return ListTile(
                            title: Text(suggestion['name']),
                            onTap: () {
                              onSuggestionSelected(suggestion);
                              setSheetState(() {});
                            },
                          );
                        },
                      ),
                    SizedBox(height: 20),
                    Text(
                      'Set Your Price:',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Slider(
                            min: min.toDouble(),
                            max: max.toDouble(),
                            divisions: ((max - min) ~/ 10),
                            value: tempPrice.toDouble(),
                            onChanged: (value) {
                              setSheetState(() {
                                tempPrice = value.round();
                              });
                            },
                            label: '$tempPrice DZD',
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            setSheetState(() {
                              currentPrice = tempPrice;
                            });
                            setState(() {});
                          },
                          icon: Icon(Icons.check),
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),

                    Text('Date & Time:'),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () async {
                              final date = await showDatePicker(
                                context: context,
                                initialDate: selectedDateTime,
                                firstDate: DateTime.now(),
                                lastDate: DateTime.now().add(
                                  Duration(days: 365),
                                ),
                              );
                              if (date == null) return;
                              setSheetState(() {
                                selectedDateTime = DateTime(
                                  date.year,
                                  date.month,
                                  date.day,
                                  selectedDateTime.hour,
                                  selectedDateTime.minute,
                                );
                              });
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                vertical: 16,
                                horizontal: 20,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                '${selectedDateTime.year}-${selectedDateTime.month.toString().padLeft(2, '0')}-${selectedDateTime.day.toString().padLeft(2, '0')}',
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: GestureDetector(
                            onTap: () async {
                              final time = await showTimePicker(
                                context: context,
                                initialTime: TimeOfDay.fromDateTime(
                                  selectedDateTime,
                                ),
                              );
                              if (time == null) return;
                              setSheetState(() {
                                selectedDateTime = DateTime(
                                  selectedDateTime.year,
                                  selectedDateTime.month,
                                  selectedDateTime.day,
                                  time.hour,
                                  time.minute,
                                );
                              });
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                vertical: 16,
                                horizontal: 20,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                '${selectedDateTime.hour.toString().padLeft(2, '0')}:${selectedDateTime.minute.toString().padLeft(2, '0')}', //! to learn
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Number of Places: $placeCount',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        TextButton(
                          onPressed:
                              () =>
                                  _showEditPlacesSheet(context, setSheetState),
                          child: Text('Edit'),
                        ),
                      ],
                    ),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text('Cancel'),
                        ),
                        SizedBox(width: 12),
                        TextButton(
                          style: TextButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () async {
                            final currentUser =
                                FirebaseAuth.instance.currentUser;

                            if (currentUser == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'You must be logged in to request a ride.',
                                  ),
                                ),
                              );
                              return;
                            }

                            final pickupName = pickupController.text;
                            final destination = widget.destinationLocation;
                            final datetimeStr =
                                '${selectedDateTime.toLocal()}'.split('.')[0];
                            if (await isValidLocation(pickupName) ||
                                pickupName == 'Current Location') {
                              try {
                                final currentUser =
                                    FirebaseAuth.instance.currentUser;
                                // creator infos
                                final userDoc =
                                    await FirebaseFirestore.instance
                                        .collection('users')
                                        .doc(currentUser!.uid)
                                        .get();
                                final userData = userDoc.data();

                                DocumentReference requestedRideRef =
                                    await FirebaseFirestore.instance
                                        .collection('ride_requests')
                                        .add({
                                          'userId': currentUser.uid,
                                          'userName':
                                              userData?['name'] ?? 'unknown',
                                          'distanceKm': widget.distanceInKm,
                                          'pickupName':
                                              pickupName == 'Current Location'
                                                  ? pickupAddress
                                                  : pickupName,

                                          'pickupLat':
                                              selectedPickupCoords?.latitude,
                                          'pickupLon':
                                              selectedPickupCoords?.longitude,
                                          'destinationLat':
                                              widget.destinationCoords.latitude,
                                          'destinationLon':
                                              widget
                                                  .destinationCoords
                                                  .longitude,
                                          'destinationName': destination,
                                          'timestamp': selectedDateTime,
                                          'status': 'pending',
                                          'createdAt': Timestamp.now(),
                                          'price': tempPrice,
                                          'isRequested': true,
                                          'placeCount': placeCount,
                                        });
                                String requestedRideId = requestedRideRef.id;

                                // Update the document with its own ID
                                await requestedRideRef.update({
                                  'ride_id': requestedRideId,
                                });

                                Navigator.pop(context);

                                showSuccessSnackbar(
                                  context,
                                  'Ride requested:\nFrom: $pickupName\nTo: $destination\nAt: $datetimeStr',
                                );
                              } catch (e) {
                                showErrorSnackbar(
                                  context,
                                  'Error requesting ride: $e',
                                );
                              }
                            } else {}
                          },

                          child: Text('Request'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showEditPlacesSheet(
    BuildContext context,
    void Function(void Function()) setSheetState,
  ) {
    // TODO: //! tolearn
    int tempPlaceCount = placeCount;

    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed:
                            tempPlaceCount > 1
                                ? () => setModalState(() => tempPlaceCount--)
                                : null,
                        icon: Icon(
                          Icons.remove_circle_outline,
                          size: 50,
                          color: tempPlaceCount > 1 ? Colors.blue : Colors.grey,
                        ),
                      ),
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
                      IconButton(
                        onPressed:
                            tempPlaceCount < 8
                                ? () => setModalState(() => tempPlaceCount++)
                                : null,
                        icon: Icon(
                          Icons.add_circle_outline,
                          size: 50,
                          color: tempPlaceCount < 8 ? Colors.blue : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 32),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 80),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          setSheetState(() => placeCount = tempPlaceCount);
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

  Color? _getStatusColor(String? status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser!.uid;
    final destinationFilter = widget.destinationLocation.trim().toLowerCase();
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 10),
            Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(LucideIcons.arrowLeft),
                ),
                const SizedBox(width: 8),
                Text(
                  'Available Rides',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            // Expanded list of rides
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream:
                    FirebaseFirestore.instance
                        .collection('rides')
                        .orderBy('date', descending: false)
                        .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  if (!snapshot.hasData) {
                    return Center(child: Text('No available rides!'));
                  }

                  final filteredAndAvailableRides =
                      snapshot.data!.docs.where((rideDoc) {
                        final rideData = rideDoc.data() as Map<String, dynamic>;

                        final String ridePublisherId = rideData['userId'] ?? '';
                        final List<dynamic> bookedByList =
                            rideData['bookedBy'] ?? []; // Ensure it's not null
                        final int leftPlaces =
                            (rideData['leftPlace'] as num?)?.toInt() ?? 0;
                        // Assuming 'active' is the status for bookable rides

                        // Exclude rides published by the current user (you can't book your own)
                        if (ridePublisherId == currentUserId) {
                          return false;
                        }

                        // Exclude rides already booked by the current user
                        if (bookedByList.contains(currentUserId)) {
                          return false;
                        }

                        //  Exclude rides with no available seats
                        if (leftPlaces <= 0) {
                          return false;
                        }
                        final rideDestination =
                            (rideData['destinationName'] ?? '')
                                .toString()
                                .trim()
                                .toLowerCase();
                        if (!rideDestination.contains(destinationFilter)) {
                          return false; // Exclude rides not matching the destination filter
                        }

                        return true; // If all filters pass, include this ride
                      }).toList();
                  if (filteredAndAvailableRides.isEmpty) {
                    return const Center(child: Text('No available rides'));
                  }

                  return ListView.builder(
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                    itemCount: filteredAndAvailableRides.length,
                    itemBuilder: (context, index) {
                      final ride = filteredAndAvailableRides[index];
                      final data = ride.data() as Map<String, dynamic>;

                      final pickupName = data['pickUpName'] ?? 'Unknown pickup';
                      final destinationName =
                          data['destinationName'] ?? 'Unknown destination';
                      final timestamp = data['date'] as Timestamp?;
                      final dateTime = timestamp?.toDate() ?? DateTime.now();

                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24),
                            color: Theme.of(context).cardColor,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 6,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) => UserProfilePage(
                                            userId: data['userId'],
                                          ),
                                    ),
                                  );
                                },
                                style: TextButton.styleFrom(padding: EdgeInsets.all(0)),
                                child: Text(
                                  'Published by ${data['userName'] ?? 'Unknown'}',
                                  style: Theme.of(context).textTheme.labelLarge,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '$pickupName → $destinationName',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (data['price'] != null)
                                Text(
                                  '${data['price']} DZD',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                    color: Colors.green,
                                  ),
                                ),
                              const SizedBox(height: 8),
                              Text(
                                'Date: ${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}',
                              ),
                              Text(
                                'Time: ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}',
                              ),
                              if (data['distanceKm'] != null)
                                Text(
                                  'Distance: ${data['distanceKm'].toStringAsFixed(2)} km',
                                ),

                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Text(
                                    'Status: ',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    data['status'] ?? 'unknown',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: _getStatusColor(data['status']),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () async {
                                        setState(() {
                                          _isBookingLoading = true;
                                        });
                                        try {
                                          await BookingService.bookRide(
                                            rideId: data['ride_id'],
                                          );
                                          setState(() {
                                          _isBookingLoading = false;
                                        });
                                          showSuccessSnackbar(context, 'Ride booked successfully!');
                                        } on Exception catch (e) {
                                          
                                          showErrorSnackbar(context, 'Booking failed: ${e.toString().replaceFirst('Exception: ', '')}');
                                          // Log the error for debugging
                                        } 
                                        
                                      },
                                      style: ElevatedButton.styleFrom(
                                        elevation: 0,
                                        backgroundColor: Colors.blue,
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            18,
                                          ),
                                        ),
                                      ),
                                      child: _isBookingLoading? Padding(
                                        padding: const EdgeInsets.all(3.0),
                                        child: CircularProgressIndicator(color: Colors.white,),
                                      ) : const Text('Take this Ride'),
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                  OutlinedButton(
                                    onPressed: () async {
                                      // get the current user id
                                      final currentUserId =
                                          FirebaseAuth
                                              .instance
                                              .currentUser!
                                              .uid;
                                      final driverId = data['userId'];
                                      final rideId = ride.id;

                                      //create or get chat for this ride
                                      final chatDocRef =
                                          await ChatService.createOrGetChat(
                                            rideId: rideId,
                                            driverId: driverId,
                                            passengerId: currentUserId,
                                          );

                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder:
                                              (_) => MessagePage(
                                                chatId: chatDocRef.id,
                                                rideId: rideId,
                                                otherUserId: driverId,
                                              ),
                                        ),
                                      );
                                    },
                                    style: OutlinedButton.styleFrom(
                                      padding: EdgeInsets.symmetric(
                                        vertical: 15,
                                        horizontal: 8,
                                      ),
                                      foregroundColor: Colors.blue,
                                      side: const BorderSide(
                                        color: Colors.blue,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(18),
                                      ),
                                    ),
                                    child: const Text('Message Publisher'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),

            TextButton(
              style: TextButton.styleFrom(
                fixedSize: Size(310, 55),
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              onPressed: () async {
                
                setState(() {_isLoading = true;});
                Position position = await Geolocator.getCurrentPosition(
                  desiredAccuracy: LocationAccuracy.high,
                );
                double lat = position.latitude;
                double lng = position.longitude;

                List<Placemark> placemarks = await placemarkFromCoordinates(
                  lat,
                  lng,
                );
                Placemark place = placemarks[0];

                pickupAddress =
                    "${place.street}, ${place.locality}, ${place.administrativeArea}, ${place.country}";
                
                setState(() {_isLoading = false;});

                showRequestRideBottomSheet();
              },
              child:
                  _isLoading
                      ? CircularProgressIndicator(color: Colors.white)
                      : const Text(
                        'Post a ride request',
                        style: TextStyle(fontSize: 16),
                      ),
            ),
          ],
        ),
      ),
    );
  }
}
