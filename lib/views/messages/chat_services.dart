import 'package:cloud_firestore/cloud_firestore.dart';

class ChatService {
  static final FirebaseFirestore firestore = FirebaseFirestore.instance;

  // Create or get chat for a ride 
  static Future<DocumentReference> createOrGetChat({
    required String rideId,
    required String driverId,
    required String passengerId,
  }) async {
    // check if a chat for this ride already exists
    final querySnapshot =
        await firestore
            .collection('conversations')
            .where('ride_id', isEqualTo: rideId)
            .limit(1)
            .get();

    if (querySnapshot.docs.isNotEmpty) {
      // Chat already exists, return existing document reference
      return querySnapshot.docs.first.reference;
    }

    // Chat doesn't exist — create new chat document with auto-generated ID
    final newChatRef = firestore.collection('conversations').doc();

    await newChatRef.set({
      'ride_id': rideId,
      'driver_id': driverId,
      'passenger_id': passengerId,
      'last_message': '',
      'last_timestamp': FieldValue.serverTimestamp(),
      'participants': [driverId, passengerId], // Optional but useful
    });

    return newChatRef;
  }

  // Send a message in the chat
  static Future<void> sendMessage({
    required String chatId, 
    required String senderId,
    required String text,
  }) async {
    final chatRef = firestore.collection('conversations').doc(chatId);

    await chatRef.collection('messages').add({
      'sender_id': senderId,
      'text': text,
      'timestamp': FieldValue.serverTimestamp(),
    });

    await chatRef.update({
      'last_message': text,
      'last_timestamp': FieldValue.serverTimestamp(),
    });
  }

  // Get real-time messages by chatId (not rideId)
  Stream<QuerySnapshot> getMessages(String chatId) {
    return firestore
        .collection('conversations')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp')
        .snapshots();
  }
}
