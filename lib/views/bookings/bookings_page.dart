import 'package:carpooling/components/container.dart';
import 'package:carpooling/views/ride/my_requested_rides.dart';
import 'package:carpooling/views/ride/my_rides.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:  Column(
        mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => DriverRidesPage()),
                );
              },
              child: Center(child: Text('My rides')),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => DriverRideRequestsPage()),
                );
              },
              child: Center(child: Text('My requested rides')),
            ),
          ],
        ),
      
    );
  }
}
