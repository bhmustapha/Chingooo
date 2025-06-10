import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BookingService {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  Future<void> bookRide({
    required String rideId,
    required String driverId,
    required GeoPoint pickupLocation,
    required GeoPoint dropoffLocation,
    required String pickupAddress,
    required String dropoffAddress,
    required Timestamp date,
    required double price,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception("User not authenticated");
    }

    final userId = user.uid;

    // Check for existing booking
    final existing = await _firestore
        .collection('bookings')
        .where('userId', isEqualTo: userId)
        .where('rideId', isEqualTo: rideId)
        .get();

    if (existing.docs.isNotEmpty) {
      throw Exception("You have already booked this ride.");
    }

    final bookingData = {
      'userId': userId,
      'rideId': rideId,
      'driverId': driverId,
      'pickupLocation': pickupLocation,
      'dropoffLocation': dropoffLocation,
      'pickupAddress': pickupAddress,
      'dropoffAddress': dropoffAddress,
      'date': date,
      'price': price,
      'status': 'booked',
      'createdAt': FieldValue.serverTimestamp(),
    };

    await _firestore.collection('bookings').add(bookingData);
  }
}
