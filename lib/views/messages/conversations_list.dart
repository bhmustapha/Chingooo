import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'message_page.dart';

class ChatListPage extends StatelessWidget {
  final currentUserId = FirebaseAuth.instance.currentUser!.uid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 24),
            Text(
              'Messages',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
            ),
            SizedBox(height: 15),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream:
                    FirebaseFirestore.instance
                        .collection('conversations')
                        .where('participants', arrayContains: currentUserId).orderBy('last_timestamp', descending: true)
                        .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(child: Text("No conversations yet."));
                  }

                  final chatDocs = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: chatDocs.length,
                    itemBuilder: (context, index) {
                      final doc = chatDocs[index];
                      final data = doc.data() as Map<String, dynamic>;
                      final chatId = doc.id;
                      final isDriver = data['driver_id'] == currentUserId;
                      final otherUserId =
                          isDriver ? data['passenger_id'] : data['driver_id'];

                      return FutureBuilder<DocumentSnapshot>(
                        future:
                            FirebaseFirestore.instance
                                .collection('users')
                                .doc(otherUserId)
                                .get(),
                        builder: (context, userSnapshot) {
                          if (!userSnapshot.hasData) {
                            return ListTile(title: Text("Loading..."));
                          }

                          final userData =
                              userSnapshot.data!.data()
                                  as Map<String, dynamic>?;
                          final friendName = userData?['name'] ?? 'User';

                          return FutureBuilder<DocumentSnapshot>(
                            //  fetch the ride or ride_request document to get destination
                            future:
                                FirebaseFirestore.instance
                                    .collection(
                                      data['is_ride_request'] == true
                                          ? 'ride_requests'
                                          : 'rides',
                                    )
                                    .doc(data['ride_id'])
                                    .get(),
                            builder: (context, rideSnapshot) {
                              //  extract destination from fetched ride document
                              final destination =
                                  rideSnapshot.hasData
                                      ? (rideSnapshot.data?.get(
                                            'destinationName',
                                          ) ??
                                          '')
                                      : '';

                              return ListTile(
                                leading: CircleAvatar(
                                  radius: 28,
                                  child: Text(
                                    friendName[0].toUpperCase(),
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                title: Text(
                                  friendName,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (destination.isNotEmpty)
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          top: 4.0,
                                        ),
                                        child: Text(
                                          'Ride to: $destination',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ),
                                    SizedBox(height: 4),
                                    Text(
                                      data['last_message'] ?? '',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                                trailing: Text(
                                  _formatTimestamp(data['last_timestamp']),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) => MessagePage(
                                            chatId: chatId,
                                            rideId: data['ride_id'],
                                            otherUserId: otherUserId,
                                            isRideRequest:
                                                data['is_ride_request'] == true,
                                          ),
                                    ),
                                  );
                                },
                              );
                            },
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // helper function for timestamp
  String _formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return '';
    final date = timestamp.toDate();
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return "${date.hour}:${date.minute.toString().padLeft(2, '0')}";
    } else if (difference.inDays == 1) {
      return "Yesterday";
    } else {
      return "${date.day}/${date.month}/${date.year}";
    }
  }
}
