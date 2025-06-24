import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:carpooling/models/vehicle.dart'; 

class VehicleService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get the current user's ID
  String? get currentUserId => _auth.currentUser?.uid;

  // Collection reference for vehicles (stored under a user's subcollection)
  CollectionReference<Map<String, dynamic>> _userVehiclesCollection(String userId) {
    return _firestore.collection('users').doc(userId).collection('vehicles');
  }

  // Add a new vehicle
  Future<void> addVehicle(Vehicle vehicle, String num) async {
    if (currentUserId == null) {
      throw Exception("User not logged in.");
    }
    await _userVehiclesCollection(currentUserId!).add(vehicle.toFirestore()); // to firestore returns a map (string, dunamyc)
    await _firestore.collection('users').doc(currentUserId).update({
      'role' : 'driver',
      'n_national' : num
    });
  }

  // Get a stream of vehicles for the current user
  Stream<List<Vehicle>> getMyVehicles() {
    if (currentUserId == null) {
      return Stream.value([]); // Return an empty stream if no user is logged in
    }
    return _userVehiclesCollection(currentUserId!)
        .orderBy('timestamp', descending: true) // Order by creation time
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Vehicle.fromFirestore(doc.data(), doc.id);
      }).toList();
    });
  }

  // Delete a vehicle
  Future<void> deleteVehicle(String vehicleId) async {
    if (currentUserId == null) {
      throw Exception("User not logged in.");
    }
    await _userVehiclesCollection(currentUserId!).doc(vehicleId).delete();
  }

  
}