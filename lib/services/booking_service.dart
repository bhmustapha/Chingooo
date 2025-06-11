import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:latlong2/latlong.dart';

final _firestore = FirebaseFirestore.instance;
final _auth = FirebaseAuth.instance;

class BookingService {
  static Future<void> bookRide({required String rideId}) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception("User not authenticated");
    }

    final userId = user.uid;

    String passengerName = "Unknown Passenger";
    try {
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(userId).get();
      if (userDoc.exists) {
        final userData = userDoc.data() as Map<String, dynamic>?;
        passengerName = userData?['name'] ?? 'Unknown Passenger';
      }
    } catch (e) {
      print("Error fetching passenger name: $e");
    }

    await _firestore.runTransaction((transaction) async {
      final rideRef = _firestore.collection('rides').doc(rideId);
      final rideSnapshot = await transaction.get(rideRef);

      if (!rideSnapshot.exists) {
        throw Exception("Ride with ID $rideId not found.");
      }

      final rideData = rideSnapshot.data();
      if (rideData == null) {
        throw Exception("Ride data is empty.");
      }

      final String driverId = rideData['userId'];

      String driverName = rideData['userName'] ?? "Unknown Driver";

      final int totalCapacity = (rideData['placeCount'] as num).toInt();
      int placesCurrentlyBooked = (rideData['bookedPlaces'] as num?)?.toInt() ?? 0;
      // Fetch current leftPlace
      int leftPlaces = (rideData['leftPlace'] as num?)?.toInt() ?? totalCapacity;

      // Get the existing bookedBy array, or initialize if null
      List<String> bookedByUsers = (rideData['bookedBy'] as List<dynamic>?)?.cast<String>() ?? [];

      // Check if the user has already booked this ride using the new 'bookedBy' array
      if (bookedByUsers.contains(userId)) {
        throw Exception("You have already booked this ride.");
      }

      // Existing check from 'bookings' collection 
      final existingBookingInBookingsCollection = await _firestore
          .collection('bookings')
          .where('passengerId', isEqualTo: userId)
          .where('rideId', isEqualTo: rideId)
          .get();

      if (existingBookingInBookingsCollection.docs.isNotEmpty) {
        
         throw Exception("You have already booked this ride (checked via bookings collection).");
      }


      if (userId == driverId) {
        throw Exception("You cannot book your own ride.");
      }

      // Check if there's enough capacity using leftPlaces
      if (leftPlaces <= 0) {
        throw Exception("Sorry, this ride is fully booked (no places left).");
      }

      // Decrement leftPlace and increment bookedPlaces
      placesCurrentlyBooked++;
      leftPlaces--;

      // Update the ride document: increment bookedPlaces, decrement leftPlace, and add userId to bookedBy
      transaction.update(rideRef, {
        'bookedPlaces': placesCurrentlyBooked,
        'leftPlace': leftPlaces,
        'bookedBy': FieldValue.arrayUnion([userId]), // add the user id to the booked array
      });

      final LatLng pickupLocation = LatLng(
        (rideData['pickUp'] as Map<String, dynamic>?)?['latitude'] as double? ?? 0.0,
        (rideData['pickUp'] as Map<String, dynamic>?)?['longitude'] as double? ?? 0.0,
      );
      final LatLng dropoffLocation = LatLng(
        (rideData['dropOff'] as Map<String, dynamic>?)?['latitude'] as double? ?? 0.0,
        (rideData['dropOff'] as Map<String, dynamic>?)?['longitude'] as double? ?? 0.0,
      );
      final String pickupAddress = rideData['pickUpName'];
      final String dropoffAddress = rideData['destinationName'];
      final Timestamp date =
          rideData['date'] is Timestamp
              ? rideData['date']
              : Timestamp.fromDate(rideData['date'].toDate());

      final double price = (rideData['price'] as num).toDouble();
      final double distanceKm = (rideData['distanceKm'] as num?)?.toDouble() ?? 0.0;

      final String? vehicleMake = rideData['vehicle']?['vehicleMake'];
      final String? vehicleModel = rideData['vehicle']?['vehicleModel'];
      final String? vehicleId = rideData['vehicle']?['vehicleId'];

      final bookingData = {
        'passengerId': userId,
        'passengerName': passengerName,
        'driverId': driverId,
        'driverName': driverName,
        'rideId': rideId,
        'seatsBooked': 1,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
        'rideDetails': {
          'pickupLocation': {
            'latitude': pickupLocation.latitude,
            'longitude': pickupLocation.longitude,
          },
          'dropoffLocation': {
            'latitude': dropoffLocation.latitude,
            'longitude': dropoffLocation.longitude,
          },
          'pickUpName': pickupAddress,
          'destinationName': dropoffAddress,
          'date': date,
          'price': price,
          'distanceKm': distanceKm,
          'vehicleMake': vehicleMake,
          'vehicleModel': vehicleModel,
          'vehicleId': vehicleId,
        }
      };

      transaction.set(_firestore.collection('bookings').doc(), bookingData);
    });
  }
}