import 'package:carpooling/themes/costum_reusable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../messages/chat_services.dart';
import '../messages/message_page.dart';

class SeeRidesPage extends StatefulWidget {
  final String destinationLocation;
  final LatLng? initialPickupLocation;
  final Future<List<Map<String, dynamic>>> Function(String)
  fetchSuggestionsCallback;

  SeeRidesPage({
    required this.destinationLocation,
    required this.fetchSuggestionsCallback,
    this.initialPickupLocation,
    super.key,
  });

  @override
  State<SeeRidesPage> createState() => _SeeRidesPageState();
}

class _SeeRidesPageState extends State<SeeRidesPage> {
  late TextEditingController pickupController;
  List<Map<String, dynamic>> suggestions = [];
  LatLng? selectedPickupCoords;

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

  void showRequestRideBottomSheet() {
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
                        onPickupChanged(value);
                        setSheetState(() {});
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
                                '${selectedDateTime.hour.toString().padLeft(2, '0')}:${selectedDateTime.minute.toString().padLeft(2, '0')}',
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 30),
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
                          onPressed: () {
                            String pickupName = pickupController.text;
                            String destination = widget.destinationLocation;
                            String datetimeStr =
                                '${selectedDateTime.toLocal()}'.split('.')[0];

                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Ride requested:\nFrom: $pickupName\nTo: $destination\nAt: $datetimeStr',
                                ),
                                duration: Duration(seconds: 4),
                              ),
                            );
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
                  if (!snapshot.hasData) {
                    return Center(child: Text('No available rides!'));
                  }

                  final destinationFilter =
                      widget.destinationLocation.trim().toLowerCase();
                  final filteredRides =
                      snapshot.data!.docs.where((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        final rideDestination =
                            (data['destinationName'] ?? '')
                                .toString()
                                .trim()
                                .toLowerCase();
                        return rideDestination.contains(destinationFilter);
                      }).toList();

                  final currentUserId = FirebaseAuth.instance.currentUser!.uid;

                  final notUserRides =
                      filteredRides.where((ride) {
                        final data = ride.data() as Map<String, dynamic>;
                        return data['userId'] != currentUserId;
                      }).toList();

                  if (notUserRides.isEmpty) {
                    return Center(
                      child: Text('No rides to $destinationFilter'),
                    );
                  }

                  return ListView.builder(
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                    itemCount: notUserRides.length,
                    itemBuilder: (context, index) {
                      final ride = notUserRides[index];
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
                              Text(
                                'Published by ${data['userName'] ?? 'Unknown'}',
                                style: Theme.of(context).textTheme.labelLarge,
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
                                      onPressed: () {
                                        // Your "Take this Ride" logic
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
                                      child: const Text('Take this Ride'),
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
              onPressed: showRequestRideBottomSheet,
              child: const Text(
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
