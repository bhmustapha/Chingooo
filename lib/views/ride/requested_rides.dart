import 'package:carpooling/views/messages/chat_services.dart';
import 'package:carpooling/views/messages/message_page.dart';
import 'package:carpooling/widgets/snackbar_utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RequestedRidesPage extends StatelessWidget {
  const RequestedRidesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ridesRef = FirebaseFirestore.instance.collection('ride_requests');

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

                    final currentUserId =
                        FirebaseAuth.instance.currentUser!.uid;
                    final requestedRides =
                        snapshot.data!.docs
                            .where(
                              (doc) =>
                                  (doc.data()
                                      as Map<String, dynamic>)['userId'] !=
                                  currentUserId,
                            )
                            .toList();
                    if (requestedRides.isEmpty) {
                      return const Center(
                        child: Text("No requested rides available for you."),
                      );
                    }

                    return ListView.separated(
                      itemCount: requestedRides.length,
                      separatorBuilder:
                          (_, __) => const SizedBox(height: 12), //! learn
                      itemBuilder: (context, index) {
                        final ride = requestedRides[index];
                        final data = ride.data() as Map<String, dynamic>;
                        final timestamp = data['timestamp'] as Timestamp?;
                        final dateTime = timestamp?.toDate() ?? DateTime.now();

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
                              Text(
                                'Published by ${data['userName']}',
                                style: Theme.of(context).textTheme.labelLarge,
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
                                      onPressed: () {
                                        // TODO: Implement take ride logic
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
                                      final currentUserId =
                                          FirebaseAuth
                                              .instance
                                              .currentUser!
                                              .uid;
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

  String _formatDate(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  String _formatTime(DateTime date) =>
      '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}'; // ! move into seperate file nd make it reusable
}
