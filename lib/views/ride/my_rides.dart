import 'package:carpooling/views/messages/specific_ride_chat_list.dart';
import 'package:carpooling/views/ride/utils/ride_utils.dart';
import 'package:carpooling/widgets/snackbar_utils.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DriverRidesPage extends StatefulWidget {
  DriverRidesPage({super.key});

  @override
  State<DriverRidesPage> createState() => _DriverRidesPageState();
}

class _DriverRidesPageState extends State<DriverRidesPage> {
  double? currentPrice;
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(title: const Text("Your Published Rides"), elevation: 0),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection('rides')
                .where('userId', isEqualTo: currentUserId)
                .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text("Something went wrong."));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text("You haven't published any rides yet."),
            );
          }

          final driverRides = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(10),
            itemCount: driverRides.length,
            itemBuilder: (context, index) {
              final ride = driverRides[index];
              final data = ride.data() as Map<String, dynamic>;
              final rideId = ride.id;

              final pickupName = data['pickUpName'] ?? 'Unknown pickup';
              final destinationName =
                  data['destinationName'] ?? 'Unknown destination';
              final timestamp = data['date'] as Timestamp?;
              final dateTime = timestamp?.toDate() ?? DateTime.now();

              final int maxPlaces = (data['vehicle']?['maxPlaces'] as num?)?.toInt() ?? 1;


              return FutureBuilder<QuerySnapshot>(
                future:
                    FirebaseFirestore.instance
                        .collection('conversations')
                        .where('ride_id', isEqualTo: rideId)
                        .get(),
                builder: (context, chatSnapshot) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Container(
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
                          const Text(
                            'You published this ride',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '$pickupName → $destinationName',
                            style: const TextStyle(
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
                          Text('Date: ${_formatDate(dateTime)}'),
                          Text('Time: ${_formatTime(dateTime)}'),
                          if (data['distanceKm'] != null)
                            Text(
                              'Distance: ${data['distanceKm'].toStringAsFixed(2)} km',
                            ),
                          Text('Requests: ${data['placeCount']}'),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Text(
                                'Status: ',
                                style: TextStyle(fontWeight: FontWeight.bold),
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
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.edit,
                                  color: Colors.blue,
                                ),
                                onPressed:
                                    () => _showEditSheet(context, rideId, data, maxPlaces),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.blue,
                                ),
                                onPressed: () async {
                                  final confirm = await showDialog<bool>(
                                    context: context,
                                    builder:
                                        (context) => AlertDialog(
                                          title: const Text("Delete Ride"),
                                          content: const Text(
                                            "Are you sure you want to delete this ride?",
                                          ),
                                          actions: [
                                            TextButton(
                                              child: const Text("Cancel"),
                                              onPressed:
                                                  () => Navigator.pop(
                                                    context,
                                                    false,
                                                  ),
                                            ),
                                            TextButton(
                                              child: const Text(
                                                "Delete",
                                                style: TextStyle(
                                                  color: Colors.red,
                                                ),
                                              ),
                                              onPressed:
                                                  () => Navigator.pop(
                                                    context,
                                                    true,
                                                  ),
                                            ),
                                          ],
                                        ),
                                  );

                                  if (confirm == true) {
                                    // Delete conversations related to this ride
                                    final conversationsSnapshot =
                                        await FirebaseFirestore
                                            .instance //! to learn
                                            .collection('conversations')
                                            .where('ride_id', isEqualTo: rideId)
                                            .get();

                                    final batch =
                                        FirebaseFirestore.instance.batch();

                                    for (final doc
                                        in conversationsSnapshot.docs) {
                                      batch.delete(doc.reference);
                                    }

                                    // Delete the ride document
                                    final rideRef = FirebaseFirestore.instance
                                        .collection('rides')
                                        .doc(rideId);
                                    batch.delete(rideRef);

                                    await batch.commit();

                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          "Ride and related conversations deleted",
                                        ),
                                      ),
                                    );
                                  }
                                },
                              ),
                              OutlinedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 14,
                                  ),
                                  side: BorderSide(color: Colors.transparent),
                                ),

                                child: Text('Messages'),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) => RideConversationsPage(
                                            rideId: ride.id,
                                            destinationName: data['destinationName'],
                                          ),
                                    ),
                                  );
                                },
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
        },
      ),
    );
  }

  void showPriceAdjustmentSheet(
    BuildContext context,
    double distanceKm,
    void Function(double) onPriceChanged, //!to learn
  ) {
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
      //! to learn
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            //! learn
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
                          onPriceChanged(tempPrice.toDouble());
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
  void _showEditPlacesSheet(
    BuildContext context,
    void Function(int newPlaceCount) onPlacesConfirmed, //! to learn
    int initialPlaceCount,
    int maxAllowedPlaces,
  ) {
    int tempPlaceCount = initialPlaceCount;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
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
                  const Text(
                    'Adjust Number of Seats',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
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
                          style: const TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed:
                            tempPlaceCount <maxAllowedPlaces
                                ? () => setModalState(() => tempPlaceCount++)
                                : null,
                        icon: Icon(
                          Icons.add_circle_outline,
                          size: 50,
                          color: tempPlaceCount < maxAllowedPlaces? Colors.blue : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 80),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          onPlacesConfirmed(tempPlaceCount);
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          backgroundColor: Colors.blue,
                        ),
                        child: const Text(
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

  void _showEditSheet(
    BuildContext context,
    String rideId,
    Map<String, dynamic> rideData,
    int maxPlaces,
  ) {
    DateTime selectedDateTime =
        (rideData['date'] as Timestamp?)?.toDate() ?? DateTime.now();

    currentPrice = (rideData['price'] as num?)?.toDouble();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        int tempPlaceCount = (rideData['placeCount'] as num?)?.toInt() ?? 1;
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: StatefulBuilder(
            builder: (context, setModalState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Edit Ride',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  ListTile(
                    title: Text('Number of Seats: $tempPlaceCount'),
                    trailing: const Icon(Icons.edit, color: Colors.blue),
                    onTap: () {
                      _showEditPlacesSheet(context, (newPlaceCount) {
                        setModalState(() {
                          tempPlaceCount = newPlaceCount;
                        });
                      }, tempPlaceCount,maxPlaces,);
                    },
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        
                        Text(
                          '${currentPrice?.toStringAsFixed(0) ?? 'N/A'} DZD',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () {
                            showPriceAdjustmentSheet(
                              context,
                              (rideData['distanceKm'] as num?)?.toDouble() ?? 0.0,
                              (newPrice) {
                                setModalState(() {
                                  currentPrice = newPrice;
                                });
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  ListTile(
                    title: Text('Date: ${_formatDate(selectedDateTime)}'),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () async {
                      final pickedDate = await showDatePicker(
                        context: context,
                        initialDate: selectedDateTime,
                        firstDate: DateTime.now().subtract(
                          const Duration(days: 365),
                        ),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (pickedDate != null) {
                        setModalState(() {
                          selectedDateTime = DateTime(
                            pickedDate.year,
                            pickedDate.month,
                            pickedDate.day,
                            selectedDateTime.hour,
                            selectedDateTime.minute,
                          );
                        });
                      }
                    },
                  ),
                  ListTile(
                    title: Text('Time: ${_formatTime(selectedDateTime)}'),
                    trailing: const Icon(Icons.access_time),
                    onTap: () async {
                      final pickedTime = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.fromDateTime(selectedDateTime),
                      );
                      if (pickedTime != null) {
                        setModalState(() {
                          selectedDateTime = DateTime(
                            selectedDateTime.year,
                            selectedDateTime.month,
                            selectedDateTime.day,
                            pickedTime.hour,
                            pickedTime.minute,
                          );
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      onPressed: () async {
                        setState(() {
                          isLoading = true;
                        });
                        // Final time of day
                        final rideTime = TimeOfDay.fromDateTime(
                          selectedDateTime,
                        );

                        await FirebaseFirestore.instance
                            .collection('rides')
                            .doc(rideId)
                            .update({
                              'price': currentPrice ?? rideData['price'],
                              'date': Timestamp.fromDate(selectedDateTime),
                              'time':
                                  '${rideTime.hour.toString().padLeft(2, '0')}:${rideTime.minute.toString().padLeft(2, '0')}',
                                  'placeCount': tempPlaceCount,
                            });
                        setState(() {
                          isLoading = false;
                        });
                        Navigator.pop(context);
                        showSuccessSnackbar(context, 'Ride updated');
                        setState(() {}); // To refresh card with new price
                      },
                      child:
                          isLoading
                              ? CircularProgressIndicator(color: Colors.white)
                              : const Text(
                                'Save Changes',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  String _formatDate(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  String _formatTime(DateTime date) =>
      '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'approved':
        return Colors.green;
      case 'completed':
        return Colors.grey;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.black;
    }
  }
}
