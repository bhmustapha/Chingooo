import 'package:cloud_firestore/cloud_firestore.dart';

class Vehicle {
  String id; // Unique ID for the vehicle document
  String driverId; // The ID of the user (driver) who owns this vehicle
  String make;
  String model;
  int year;
  String licensePlate;
  String color;
  int capacity; // Number of seats available for passengers

  Vehicle({
    required this.id,
    required this.driverId,
    required this.make,
    required this.model,
    required this.year,
    required this.licensePlate,
    required this.color,
    required this.capacity,
  });

  // Factory constructor to create a Vehicle object from a Firestore document
  factory Vehicle.fromFirestore(Map<String, dynamic> data, String documentId) {
    return Vehicle(
      id: documentId,
      driverId: data['driverId'] as String,
      make: data['make'] as String,
      model: data['model'] as String,
      year: data['year'] as int,
      licensePlate: data['licensePlate'] as String,
      color: data['color'] as String,
      capacity: data['capacity'] as int,
    );
  }

  // Method to convert a Vehicle object to a Firestore document (map)
  Map<String, dynamic> toFirestore() {
    return {
      'driverId': driverId,
      'make': make,
      'model': model,
      'year': year,
      'licensePlate': licensePlate,
      'color': color,
      'capacity': capacity,
      'timestamp': FieldValue.serverTimestamp(),//add a creation timestamp
    };
  }
}