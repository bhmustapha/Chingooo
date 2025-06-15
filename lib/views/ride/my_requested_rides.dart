import 'package:carpooling/views/messages/specific_ride_chat_list.dart';
import 'package:carpooling/views/ride/utils/ride_utils.dart';
import 'package:carpooling/widgets/snackbar_utils.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RideRequestsPage extends StatefulWidget {
  RideRequestsPage({super.key});

  @override
  State<RideRequestsPage> createState() => _DriverRideRequestsPageState();
}

class _DriverRideRequestsPageState extends State<RideRequestsPage> {
  double? currentPrice;
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(title: const Text("Your Ride Requests"), elevation: 0),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection('ride_requests')
                .where('userId', isEqualTo: currentUserId)
                .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text("Something went wrong."));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text("You haven't published any ride requests yet."),
            );
          }

          final rideRequests = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(10),
            itemCount: rideRequests.length,
            itemBuilder: (context, index) {
              final rideRequest = rideRequests[index];
              final data = rideRequest.data() as Map<String, dynamic>;
              final rideRequestId = rideRequest.id;

              final pickupName = data['pickUpName'] ?? 'Unknown pickup';
              final destinationName =
                  data['destinationName'] ?? 'Unknown destination';
              final timestamp = data['date'] as Timestamp?;
              final dateTime = timestamp?.toDate() ?? DateTime.now();

              return FutureBuilder<QuerySnapshot>(
                future:
                    FirebaseFirestore.instance
                        .collection('conversations')
                        .where('ride_id', isEqualTo: rideRequestId)
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
                            'You published this ride request',
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
                              '${(data['price'] as num).toStringAsFixed(0)} DZD',
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
                              'Distance: ${(data['distanceKm'] as num).toStringAsFixed(2)} km',
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
                                    () => _showEditSheet(
                                      context,
                                      rideRequestId,
                                      data,
                                    ),
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
                                          title: const Text(
                                            "Delete Ride Request",
                                          ),
                                          content: const Text(
                                            "Are you sure you want to delete this ride request?",
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
                                    final conversationsSnapshot =
                                        await FirebaseFirestore.instance
                                            .collection('conversations')
                                            .where(
                                              'ride_id',
                                              isEqualTo: rideRequestId,
                                            )
                                            .get();

                                    final batch =
                                        FirebaseFirestore.instance.batch();

                                    for (final doc
                                        in conversationsSnapshot.docs) {
                                      batch.delete(doc.reference);
                                    }

                                    final rideRequestRef = FirebaseFirestore
                                        .instance
                                        .collection('ride_requests')
                                        .doc(rideRequestId);
                                    batch.delete(rideRequestRef);

                                    await batch.commit();

                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          "Ride request and related conversations deleted",
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
                                            rideId: rideRequestId,
                                            destinationName:
                                                data['destinationName'],
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
    void Function(double) onPriceChanged,
  ) {
    final range = RideUtils.getNegotiablePriceRange(
      distanceKm,
      marginPercent: 20,
    );

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
                    'Adjust Ride Request Price (DZD)',
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
                        icon: const Icon(Icons.check),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
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
                            tempPlaceCount <
                                    8 // Assuming a max of 8 places
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
    String rideRequestId,
    Map<String, dynamic> rideData,
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
                    'Edit Ride Request',
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
                      }, tempPlaceCount);
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
                              (rideData['distanceKm'] as num?)?.toDouble() ??
                                  0.0,
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
                    trailing: const Icon(
                      Icons.calendar_today,
                      color: Colors.blue,
                    ),
                    onTap: () async {
                      final pickedDate = await showDatePicker(
                        context: context,
                        initialDate: selectedDateTime,
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2100),
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
                  const SizedBox(height: 12),
                  ListTile(
                    title: Text('Time: ${_formatTime(selectedDateTime)}'),
                    trailing: const Icon(Icons.access_time, color: Colors.blue),
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
                      onPressed: () async {
                        setModalState(() {
                          isLoading = true;
                        });
                        try {
                          await FirebaseFirestore.instance
                              .collection('ride_requests')
                              .doc(rideRequestId)
                              .update({
                                'placeCount': tempPlaceCount,
                                'price': currentPrice,
                                'timestamp': Timestamp.fromDate(selectedDateTime),
                              });
                    
                          if (mounted) {
                            Navigator.pop(context);
                            showSuccessSnackbar(
                              context,
                              "Ride request updated successfully",
                            );
                          }
                        } catch (e) {
                          if (mounted) {
                            showErrorSnackbar(context, "Failed to update: $e");
                          }
                        } finally {
                          setModalState(() {
                            isLoading = false;
                          });
                        }
                      },
                      
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
                      child:
                          isLoading
                              ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                              : const Text(
                                'Save Changes',
                                style: TextStyle(fontSize: 15),
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

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'accepted':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    return "${date.year}-${_padZero(date.month)}-${_padZero(date.day)}";
  }

  String _formatTime(DateTime date) {
    return "${_padZero(date.hour)}:${_padZero(date.minute)}";
  }

  String _padZero(int number) {
    return number.toString().padLeft(2, '0');
  }
}
