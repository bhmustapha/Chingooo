import 'package:carpooling/components/container.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../messages/message_page.dart';

class BookingsPage extends StatelessWidget {
  // a function to generate conversation id
  String generateConversationId(String user1, String user2) {
    final sorted = [user1, user2]..sort();
    return '${sorted[0]}_${sorted[1]}';
  }

  Future<void> onMessageDriverPressed(
    BuildContext context,
    String driverName,
  ) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      // Handle user not logged in
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Please login first')));
      return;
    }
    final passengerId = currentUser.uid;
    final driverId = driverName.replaceAll(' ', '_').toLowerCase();
    // Ideally, you should have real unique IDs for drivers, this is a placeholder!

    final conversationId = generateConversationId(driverId, passengerId);

    final conversationDoc = FirebaseFirestore.instance
        .collection('conversations')
        .doc(conversationId);
    final snapshot = await conversationDoc.get();

    if (!snapshot.exists) {
      await conversationDoc.set({
        'participants': [driverId, passengerId],
        'lastMessage': '',
        'lastMessageTime': FieldValue.serverTimestamp(),
      });
    }

    // Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder:
    //         (context) => MessagePage(
    //           chatId: conversationId,
    //           otherUserId: driverName, //! come later
    //         ),
    //   ),
    // );
  }

  final List<Map<String, dynamic>> bookings = [
    {
      'destination': 'Rodina Hotel',
      'distance': '12.4',
      'date': '2025-05-02',
      'time': '08:30 AM',
      'driver': 'Abdelhak Mohammed',
      'rating': 4.8,
    },
    {
      'destination': 'Airport',
      'distance': '24.1',
      'date': '2025-05-03',
      'time': '06:45 PM',
      'driver': 'Ihab Bentaleb',
      'rating': 4.5,
    },
    {
      'destination': 'Université Oran 1',
      'distance': '7.8',
      'date': '2025-05-04',
      'time': '09:00 AM',
      'driver': 'Djaber Hnifi',
      'rating': 4.9,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 24),
            Center(
              child: Text(
                'My Bookings',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 16),
                itemCount: bookings.length,
                itemBuilder: (context, index) {
                  final ride = bookings[index];
                  return GreyContainer(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: 15,
                        horizontal: 20,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            ride['destination'],
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text("Distance: ${ride['distance']} km"),
                          Text("Date: ${ride['date']}"),
                          Text("Time: ${ride['time']}"),
                          SizedBox(height: 12),
                          Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: Colors.blue[200],
                                child: Text(
                                  ride['driver'][0],
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                              SizedBox(width: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Driver: ${ride['driver']}"),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.star,
                                        color: Colors.amber,
                                        size: 16,
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        "${ride['rating']}",
                                        style: TextStyle(fontSize: 14),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                          SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                onPressed:
                                    () => onMessageDriverPressed(
                                      context,
                                      ride['driver'],
                                    ),
                                style: TextButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  foregroundColor: Colors.white,
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                ),
                                child: Text("Message Driver"),
                              ),

                              SizedBox(width: 8),
                              TextButton(
                                onPressed: () {
                                  // TODO: Cancel booking (show dialog, update backend)
                                },
                                style: TextButton.styleFrom(
                                  backgroundColor: Colors.red[300],
                                  foregroundColor: Colors.white,
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                ),
                                child: Text("Cancel"),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
