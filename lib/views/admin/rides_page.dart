import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // For date formatting

class RidesAdminPage extends StatefulWidget {
  const RidesAdminPage({super.key});

  @override
  State<RidesAdminPage> createState() => _RidesAdminPageState();
}

class _RidesAdminPageState extends State<RidesAdminPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // Two tabs: All Rides and Ride Requests
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Manage Rides'),
          bottom: const TabBar(
            tabs: [
              Tab(text: ' Rides', icon: Icon(Icons.drive_eta), ), // Corrected tab name
              Tab(text: 'Requests', icon: Icon(Icons.pending_actions)),
            ],
            labelStyle: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            fontFamily: 'Poppins',
            color: Colors.blue
          ),
          indicatorColor: Colors.blue,
          ),
        ),
        body: TabBarView(
          children: [
            // Tab 1: All Rides List
            _buildAllRidesList(), // Corrected function call
            // Tab 2: Ride Requests List
            _buildRideRequestsList(),
          ],
        ),
      ),
    );
  }

  Widget _buildAllRidesList() { // Corrected function name
    return StreamBuilder<QuerySnapshot>(
      // Listen to the 'rides' collection as specified
      stream: _firestore.collection('rides').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No rides found.')); // Corrected message
        }

        // Display all rides
        return ListView.builder(
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final doc = snapshot.data!.docs[index];
            final data = doc.data() as Map<String, dynamic>;

            // Extract ride data
            final String rideId = data['ride_id'] ?? 'N/A';
            final String userName = data['userName'] ?? 'Unknown User';
            final String pickUpName = data['pickUpName'] ?? 'N/A';
            final String destinationName = data['destinationName'] ?? 'N/A';
            final num price = data['price'] ?? 0; // Changed from int to num
            final int placeCount = data['placeCount'] ?? 0;
            // Safely access nested 'vehicle' map
            final Map<String, dynamic>? vehicleData = data['vehicle'] as Map<String, dynamic>?;
            final String vehicleMake = vehicleData?['vehicleMake'] ?? 'N/A';
            final String vehicleModel = vehicleData?['vehicleModel'] ?? 'N/A';
            final String status = data['status'] ?? 'N/A'; // Moved status here to match structure
            final Timestamp? timestamp = data['timestamp'];
            final String formattedDate = timestamp != null
                ? DateFormat('MMM dd,EEEE HH:mm')
                    .format(timestamp.toDate())
                : 'N/A';

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Ride ID: $rideId', style: const TextStyle(fontWeight: FontWeight.bold)),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _confirmAndDeleteRide(doc.id, 'rides'), // Corrected collection name for deletion
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text('User: $userName'),
                    Text('From: $pickUpName'),
                    Text('To: $destinationName'),
                    Text('Price: $price DZD'),
                    Text('Passengers: $placeCount'),
                    Text('Vehicle: $vehicleMake $vehicleModel'),
                    Text('Status: ${status.toUpperCase()}'),
                    Text('Created On: $formattedDate'), // Corrected text
                    
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildRideRequestsList() {
    return StreamBuilder<QuerySnapshot>(
      // Listen to the 'ride_requests' collection
      stream: _firestore.collection('ride_requests').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No ride requests found.'));
        }

        // Display ride requests
        return ListView.builder(
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final doc = snapshot.data!.docs[index];
            final data = doc.data() as Map<String, dynamic>;

            // Extract ride request data
            final String rideId = data['ride_id'] ?? 'N/A';
            final String userName = data['userName'] ?? 'Unknown User';
            final String pickUpName = data['pickUpName'] ?? 'N/A';
            final String destinationName = data['destinationName'] ?? 'N/A';
            final num price = data['price'] ?? 0; // Changed from int to num
            final String status = data['status'] ?? 'N/A';
            final int placeCount = data['placeCount'] ?? 0;
            final Timestamp? createdAt = data['createdAt'];
            final String formattedDate = createdAt != null
                ? DateFormat('MMM dd,EEEE HH:mm')
                    .format(createdAt.toDate())
                : 'N/A';

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Request ID: $rideId', style: const TextStyle(fontWeight: FontWeight.bold)),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _confirmAndDeleteRide(doc.id, 'ride_requests'), // Corrected collection name for deletion
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text('User: $userName'),
                    Text('From: $pickUpName'),
                    Text('To: $destinationName'),
                    Text('Price: $price DZD'),
                    Text('Passengers: $placeCount'),
                    Text('Status: ${status.toUpperCase()}'),
                    Text('Requested On: $formattedDate'),
                   
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // Helper function to show a simple message
  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // Function to show confirmation dialog and delete a ride/request
  Future<void> _confirmAndDeleteRide(String docId, String collectionName) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // User must tap a button to close the dialog
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: Text('Are you sure you want to delete this $collectionName?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(); // Dismiss dialog
              },
            ),
            TextButton(
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
              onPressed: () async {
                Navigator.of(context).pop(); // Dismiss dialog
                try {
                  await _firestore.collection(collectionName).doc(docId).delete();
                  _showMessage(context, '$collectionName deleted successfully!');
                } catch (e) {
                  _showMessage(context, 'Error deleting $collectionName: $e');
                }
              },
            ),
          ],
        );
      },
    );
  }
}
