//! to learn !!!!!!!!!!!

import 'package:carpooling/services/booking_service.dart';
import 'package:carpooling/services/chat_services.dart';
import 'package:carpooling/views/messages/message_page.dart';
import 'package:carpooling/views/profile/users_profiles.dart';
import 'package:carpooling/widgets/snackbar_utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // Import for date formatting

class RequestedRidesPage extends StatefulWidget {
  const RequestedRidesPage({super.key});

  @override
  State<RequestedRidesPage> createState() => _RequestedRidesPageState();
}

class _RequestedRidesPageState extends State<RequestedRidesPage> {
  String _searchQuery = '';
  double _minPrice = 0;
  double _maxPrice = 5000;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  int _minPlaces = 0;
  int _maxPlaces = 8;

  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ridesRef = FirebaseFirestore.instance.collection('ride_requests');
    final currentUserId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Custom Header
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Requested Rides',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Search Input Field and Filter Button
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search by place or name...',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Theme.of(context).cardColor,
                      ),
                      onChanged: (value) {
                        setState(() {
                          _searchQuery =
                              value.toLowerCase(); // Case-insensitive search
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () async {
                      // Changed to async here
                      final result = await _showFilterDialog(
                        context,
                      ); // Await the result

                      // Only apply filters if result is not null (i.e., "Apply Filters" was pressed)
                      if (result != null) {
                        setState(() {
                          _minPrice = result['minPrice'];
                          _maxPrice = result['maxPrice'];
                          _selectedDate = result['selectedDate'];
                          _selectedTime = result['selectedTime'];
                          _minPlaces = result['minPlaces'];
                          _maxPlaces = result['maxPlaces'];
                          // Note: Search query is updated directly by TextField's onChanged
                        });
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 15,
                      ),
                    ),
                    icon: const Icon(Icons.filter_list),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Ride List from Firestore
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: ridesRef.snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(
                        child: Text("No requested rides found."),
                      );
                    }

                    final allRequestedRides =
                        snapshot.data!.docs
                            .where(
                              (doc) =>
                                  (doc.data()
                                      as Map<String, dynamic>)['userId'] !=
                                  currentUserId,
                            )
                            .toList();

                    // Apply all filters
                    final filteredRides =
                        allRequestedRides.where((ride) {
                          final data = ride.data() as Map<String, dynamic>;
                          final pickupName =
                              (data['pickUpName'] as String?)?.toLowerCase() ??
                              '';
                          final destinationName =
                              (data['destinationName'] as String?)
                                  ?.toLowerCase() ??
                              '';
                          final userName =
                              (data['userName'] as String?)?.toLowerCase() ??
                              '';
                          final price =
                              (data['price'] as num?)?.toDouble() ?? 0.0;
                          final timestamp = data['date'] as Timestamp?;
                          final rideDateTime = timestamp?.toDate();
                          final placeCount = (data['placeCount'] as int?) ?? 0;

                          // Debugging: Print current filter values and ride data
                          print('--- Ride Data ---');
                          print(
                            'Pickup: $pickupName, Dest: $destinationName, User: $userName',
                          );
                          print(
                            'Price: $price, Timestamp: $rideDateTime, PlaceCount: $placeCount',
                          );
                          print('--- Filter Values ---');
                          print('Search Query: $_searchQuery');
                          print('Min Price: $_minPrice, Max Price: $_maxPrice');
                          print(
                            'Selected Date: $_selectedDate, Selected Time: $_selectedTime',
                          );
                          print(
                            'Min Places: $_minPlaces, Max Places: $_maxPlaces',
                          );

                          // Text search filter
                          final matchesText =
                              _searchQuery
                                  .isEmpty || // Added condition for empty search query
                              pickupName.contains(_searchQuery) ||
                              destinationName.contains(_searchQuery) ||
                              userName.contains(_searchQuery);

                          // Price filter
                          final matchesPrice =
                              price >= _minPrice && price <= _maxPrice;

                          // Date filter
                          final matchesDate =
                              _selectedDate == null ||
                              (rideDateTime != null &&
                                  _selectedDate!.year == rideDateTime.year &&
                                  _selectedDate!.month == rideDateTime.month &&
                                  _selectedDate!.day == rideDateTime.day);

                          // Time filter
                          final matchesTime =
                              _selectedTime == null ||
                              (rideDateTime != null &&
                                  _selectedTime!.hour == rideDateTime.hour &&
                                  _selectedTime!.minute == rideDateTime.minute);

                          // Places filter
                          final matchesPlaces =
                              (placeCount >= _minPlaces &&
                                  placeCount <= _maxPlaces);

                          // Debugging: Print individual filter results
                          print('matchesText: $matchesText');
                          print('matchesPrice: $matchesPrice');
                          print('matchesDate: $matchesDate');
                          print('matchesTime: $matchesTime');
                          print('matchesPlaces: $matchesPlaces');
                          print(
                            'Overall match: ${matchesText && matchesPrice && matchesDate && matchesTime && matchesPlaces}',
                          );
                          print('---------------------');

                          return matchesText &&
                              matchesPrice &&
                              matchesDate &&
                              matchesTime &&
                              matchesPlaces;
                        }).toList();

                    if (filteredRides.isEmpty) {
                      return const Center(
                        child: Text("No matching requested rides found."),
                      );
                    }

                    return ListView.separated(
                      itemCount: filteredRides.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final ride = filteredRides[index];
                        final data = ride.data() as Map<String, dynamic>;
                        final timestamp = data['date'] as Timestamp?;
                        final dateTime = timestamp?.toDate() ?? DateTime.now();
                        final displayPlaceCount = data['placeCount'] ?? 'N/A';

                        return Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24),
                            color: Theme.of(context).cardColor,
                            boxShadow: const [
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
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                ),
                                child: Text(
                                  'Published by ${data['userName']}',
                                  style: Theme.of(context).textTheme.labelLarge,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${data['pickupName']} → ${data['destinationName']}',
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),

                              // Ride Price
                              Text(
                                '${data['price'].toString()} DZD',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.green,
                                ),
                              ),

                              const SizedBox(height: 8),
                              Text('Date: ${_formatDate(dateTime)}'),
                              Text('Time: ${_formatTime(dateTime)}'),
                              Text('Places: $displayPlaceCount'),
                              const SizedBox(height: 8),

                              // Status
                              Row(
                                children: [
                                  const Text(
                                    'Status: ',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    data['status'],
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: _getStatusColor(data['status']),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),

                              // Buttons
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () async {
                                        // This is the new logic for "Take this Ride"
                                        try {
                                          // Make sure ride.id is the ID of the ride_request document
                                          await BookingService.acceptRideRequest(
                                            rideRequestId: ride.id,
                                          );
                                          showSuccessSnackbar(
                                            context,
                                            'Ride request accepted successfully!',
                                          );
                                          // You might want to refresh the list or navigate away here
                                          // For now, the stream builder will naturally update once Firestore changes
                                        } catch (e) {
                                          showErrorSnackbar(
                                            context,
                                            'Failed to accept ride request: ${e.toString()}',
                                          );
                                          print(
                                            "Error accepting ride request: $e",
                                          ); // For detailed debugging
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
                                      child: const Text("Take this Ride"),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  OutlinedButton(
                                    onPressed: () async {
                                      final driverId = currentUserId;
                                      final rideId = ride.id;

                                      final chatDocRef =
                                          await ChatService.createOrGetChat(
                                            rideId: rideId,
                                            driverId: driverId,
                                            passengerId: data['userId'],
                                            isRideRequest: true,
                                          );

                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder:
                                              (_) => MessagePage(
                                                chatId: chatDocRef.id,
                                                rideId: rideId,
                                                otherUserId: data['userId'],
                                                isRideRequest: true,
                                              ),
                                        ),
                                      );
                                    },
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
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
                                    child: const Text("Message Publisher"),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- Utility Functions ---

  static Color? _getStatusColor(String? status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.green;
      case 'rejected':
        return Colors.red;

      default:
        return null;
    }
  }

  String _formatDate(DateTime date) => DateFormat('yyyy-MM-dd').format(date);

  String _formatTime(DateTime date) => DateFormat('HH:mm').format(date);

  // --- Filter Dialog ---

  Future<Map<String, dynamic>?> _showFilterDialog(BuildContext context) async {
    double tempMinPrice = _minPrice;
    double tempMaxPrice = _maxPrice;
    DateTime? tempSelectedDate = _selectedDate;
    TimeOfDay? tempSelectedTime = _selectedTime;
    int tempMinPlaces = _minPlaces;
    int tempMaxPlaces = _maxPlaces;

    return await showDialog<Map<String, dynamic>?>(
      // Specify return type
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Filter Rides'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Price Range (DZD)'),
                    RangeSlider(
                      values: RangeValues(tempMinPrice, tempMaxPrice),
                      min: 0,
                      max: 5000,
                      divisions: 50,
                      labels: RangeLabels(
                        tempMinPrice.round().toString(),
                        tempMaxPrice.round().toString(),
                      ),
                      onChanged: (values) {
                        setState(() {
                          tempMinPrice = values.start;
                          tempMaxPrice = values.end;
                        });
                      },
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Min: ${tempMinPrice.round()}'),
                        Text('Max: ${tempMaxPrice.round()}'),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Date Picker
                    ListTile(
                      title: Text(
                        'Date: ${tempSelectedDate != null ? DateFormat('yyyy-MM-dd').format(tempSelectedDate!) : 'Any'}',
                      ),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () async {
                        final pickedDate = await showDatePicker(
                          context: context,
                          initialDate: tempSelectedDate ?? DateTime.now(),
                          firstDate: DateTime.now().subtract(
                            const Duration(days: 365),
                          ),
                          lastDate: DateTime.now().add(
                            const Duration(days: 365),
                          ),
                        );
                        if (pickedDate != null) {
                          setState(() {
                            tempSelectedDate = pickedDate;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),

                    // Time Picker
                    ListTile(
                      title: Text(
                        'Time: ${tempSelectedTime != null ? tempSelectedTime!.format(context) : 'Any'}',
                      ),
                      trailing: const Icon(Icons.access_time),
                      onTap: () async {
                        final pickedTime = await showTimePicker(
                          context: context,
                          initialTime: tempSelectedTime ?? TimeOfDay.now(),
                        );
                        if (pickedTime != null) {
                          setState(() {
                            tempSelectedTime = pickedTime;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),

                    // Min Places Input with Buttons
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Minimum Places'),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              iconSize: 36,
                              padding: const EdgeInsets.all(12),
                              style: ButtonStyle(
                                minimumSize: MaterialStateProperty.all(
                                  const Size(50, 50),
                                ),
                                shape: MaterialStateProperty.all(
                                  const CircleBorder(),
                                ),
                              ),
                              icon: const Icon(Icons.remove),
                              onPressed:
                                  tempMinPlaces > 0
                                      ? () {
                                        setState(() {
                                          tempMinPlaces--;
                                          if (tempMinPlaces > tempMaxPlaces) {
                                            tempMaxPlaces = tempMinPlaces;
                                          }
                                        });
                                      }
                                      : null,
                            ),
                            SizedBox(
                              width: 80,
                              child: Text(
                                tempMinPlaces.toString(),
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineMedium
                                    ?.copyWith(fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            IconButton(
                              iconSize: 36,
                              padding: const EdgeInsets.all(12),
                              style: ButtonStyle(
                                minimumSize: MaterialStateProperty.all(
                                  const Size(50, 50),
                                ),
                                shape: MaterialStateProperty.all(
                                  const CircleBorder(),
                                ),
                              ),
                              icon: const Icon(Icons.add),
                              onPressed:
                                  tempMinPlaces < 8
                                      ? () {
                                        setState(() {
                                          tempMinPlaces++;
                                        });
                                      }
                                      : null,
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Max Places Input with Buttons
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Maximum Places'),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              iconSize: 36,
                              padding: const EdgeInsets.all(12),
                              style: ButtonStyle(
                                minimumSize: MaterialStateProperty.all(
                                  const Size(50, 50),
                                ),
                                shape: MaterialStateProperty.all(
                                  const CircleBorder(),
                                ),
                              ),
                              icon: const Icon(Icons.remove),
                              onPressed:
                                  tempMaxPlaces > 0
                                      ? () {
                                        setState(() {
                                          tempMaxPlaces--;
                                          if (tempMaxPlaces < tempMinPlaces) {
                                            tempMinPlaces = tempMaxPlaces;
                                          }
                                        });
                                      }
                                      : null,
                            ),
                            SizedBox(
                              width: 80,
                              child: Text(
                                tempMaxPlaces.toString(),
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineMedium
                                    ?.copyWith(fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            IconButton(
                              iconSize: 36,
                              padding: const EdgeInsets.all(12),
                              style: ButtonStyle(
                                minimumSize: MaterialStateProperty.all(
                                  const Size(50, 50),
                                ),
                                shape: MaterialStateProperty.all(
                                  const CircleBorder(),
                                ),
                              ),
                              icon: const Icon(Icons.add),
                              onPressed:
                                  tempMaxPlaces < 8
                                      ? () {
                                        setState(() {
                                          tempMaxPlaces++;
                                        });
                                      }
                                      : null,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(dialogContext, null); // Return null on Cancel
                  },
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    // Return a map of the temporary filter values
                    Navigator.pop(dialogContext, {
                      'minPrice': tempMinPrice,
                      'maxPrice': tempMaxPrice,
                      'selectedDate': tempSelectedDate,
                      'selectedTime': tempSelectedTime,
                      'minPlaces': tempMinPlaces,
                      'maxPlaces': tempMaxPlaces,
                    });
                  },
                  child: const Text('Apply Filters'),
                ),
                TextButton(
                  onPressed: () {
                    // Return map with default/cleared values
                    Navigator.pop(dialogContext, {
                      'minPrice': 0.0,
                      'maxPrice': 5000.0,
                      'selectedDate': null,
                      'selectedTime': null,
                      'minPlaces': 0,
                      'maxPlaces': 8,
                    });
                  },
                  child: const Text('Clear Filters'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
