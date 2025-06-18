import 'package:carpooling/services/notifications_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:latlong2/latlong.dart';

final _firestore = FirebaseFirestore.instance;
final _auth = FirebaseAuth.instance;

class BookingService {
  // Existing method (for driver offering ride, passenger booking it) - No changes here
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
      int leftPlaces = (rideData['leftPlace'] as num?)?.toInt() ?? totalCapacity;

      List<String> bookedByUsers = (rideData['bookedBy'] as List<dynamic>?)?.cast<String>() ?? [];

      if (bookedByUsers.contains(userId)) {
        throw Exception("You have already booked this ride.");
      }

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

      if (leftPlaces <= 0) {
        throw Exception("Sorry, this ride is fully booked (no places left).");
      }

      placesCurrentlyBooked++;
      leftPlaces--;

      transaction.update(rideRef, {
        'bookedPlaces': placesCurrentlyBooked,
        'leftPlace': leftPlaces,
        'bookedBy': FieldValue.arrayUnion([userId]),
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
      final Timestamp date = rideData['date'] is Timestamp
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

      final notificationsSettings = await NotificationsService.getNotificationSettings(driverId);
      if (notificationsSettings['rideUpdates'] == true ) {
        await NotificationsService.sendOneSignalNotification(userId: driverId, title: 'New Booking Request!', message: 'your ride to $dropoffAddress is booked by $passengerName');
      }
    });
  }

  // UPDATED METHOD: For a driver accepting a passenger's ride request
  static Future<void> acceptRideRequest({required String rideRequestId}) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      throw Exception("Driver not authenticated.");
    }

    final driverId = currentUser.uid;
    String driverName = "Unknown Driver";

    // 1. Get Driver's Name
    try {
      DocumentSnapshot driverDoc = await _firestore.collection('users').doc(driverId).get();
      if (driverDoc.exists) {
        final driverData = driverDoc.data() as Map<String, dynamic>?;
        driverName = driverData?['name'] ?? 'Unknown Driver';
      }
    } catch (e) {
      print("Error fetching driver name: $e");
      // Optionally rethrow or handle more robustly
    }

    // Use a transaction for atomic updates to ride_request and bookings
    await _firestore.runTransaction((transaction) async {
      final rideRequestRef = _firestore.collection('ride_requests').doc(rideRequestId);
      final rideRequestSnapshot = await transaction.get(rideRequestRef);

      if (!rideRequestSnapshot.exists) {
        throw Exception("Ride request with ID $rideRequestId not found.");
      }

      final rideRequestData = rideRequestSnapshot.data();
      if (rideRequestData == null) {
        throw Exception("Ride request data is empty.");
      }

      final String passengerId = rideRequestData['userId']; // User who made the request is the passenger
      String passengerName = rideRequestData['userName'] ?? "Unknown Passenger";

      final int requestedPlaces = (rideRequestData['placeCount'] as num).toInt();

      // Check if driver is attempting to accept their own request (shouldn't happen here)
      if (driverId == passengerId) {
        throw Exception("You cannot accept your own ride request.");
      }

      // Check if this driver has already accepted this specific ride request
      final existingBookingForThisRequest = await _firestore
          .collection('bookings')
          .where('rideId', isEqualTo: rideRequestId) // Note: Using 'rideId' in bookings to link to rideRequestId
          .where('driverId', isEqualTo: driverId)
          .get();

      if (existingBookingForThisRequest.docs.isNotEmpty) {
        throw Exception("You have already accepted this ride request.");
      }

      // Important: Check if another driver has already accepted this request
      final currentRequestStatus = rideRequestData['status'];
      if (currentRequestStatus != 'pending') {
         throw Exception("This ride request has already been ${currentRequestStatus}.");
      }

      // 2. Get Driver's Vehicle and Check Capacity
      final vehiclesSnapshot = await _firestore.collection('users').doc(driverId).collection('vehicles').get();

      if (vehiclesSnapshot.docs.isEmpty) {
        throw Exception("You do not have a registered vehicle. Please add one to accept rides.");
      }

      // For simplicity, assume the first vehicle found is the one to use.
      final vehicleData = vehiclesSnapshot.docs.first.data();
      final int maxSeatsInVehicle = (vehicleData['capacity'] as num?)?.toInt() ?? 0; // Changed to 'capacity'
      final String vehicleMake = vehicleData['make'] ?? 'N/A';
      final String vehicleModel = vehicleData['model'] ?? 'N/A';
      final String vehicleId = vehiclesSnapshot.docs.first.id; // The document ID of the vehicle

      if (requestedPlaces > maxSeatsInVehicle) {
        throw Exception("Your vehicle's maximum places ($maxSeatsInVehicle) are less than the requested places ($requestedPlaces).");
      }

      // 3. Create the Booking Document in 'bookings' collection
      final LatLng pickupLocation = LatLng(
        rideRequestData['pickupLat'] ?? 0.0, // Using updated field name: pickupLat
        rideRequestData['pickupLon'] ?? 0.0, // Using updated field name: pickupLon
      );
      final LatLng dropoffLocation = LatLng(
        rideRequestData['destinationLat'] ?? 0.0, // Using updated field name: destinationLat
        rideRequestData['destinationLon'] ?? 0.0, // Using updated field name: destinationLon
      );
      final String pickupAddress = rideRequestData['pickupName'];
      final String dropoffAddress = rideRequestData['destinationName'];
      final Timestamp date = rideRequestData['timestamp'] is Timestamp
              ? rideRequestData['timestamp']
              : Timestamp.fromDate(DateTime.parse(rideRequestData['timestamp'].toString()));

      final double price = (rideRequestData['price'] as num).toDouble();
      final double distanceKm = (rideRequestData['distanceKm'] as num?)?.toDouble() ?? 0.0;


      final bookingData = {
        'isRideRequest' : true,
        'rideId': rideRequestId, // Link to the original ride request (using its ID)
        'passengerId': passengerId,
        'passengerName': passengerName,
        'driverId': driverId,
        'driverName': driverName,
        'seatsBooked': requestedPlaces, // Number of places requested by the passenger
        'status': 'confirmed', // Driver accepts, so status is confirmed
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
          'vehicleId': vehicleId, // Add vehicle ID
        }
      };

      // Set the new booking document
      transaction.set(_firestore.collection('bookings').doc(), bookingData);

      // 4. Update the ride_request status to 'accepted'
      transaction.update(rideRequestRef, {
        'status': 'accepted', // Mark as accepted
        'acceptedByDriverId': driverId, // Record which driver accepted
        'acceptedAt': FieldValue.serverTimestamp(),
      });
      final notificationsSettings = await NotificationsService.getNotificationSettings(passengerId);
      if (notificationsSettings['rideUpdates'] == true ) {
        await NotificationsService.sendOneSignalNotification(userId: passengerId, title: 'New Booking !', message: 'your ride request to $dropoffAddress is booked by $driverName');
      }
    });
  }
}