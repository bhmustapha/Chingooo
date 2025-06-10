import 'package:carpooling/views/messages/chat_services.dart';
import 'package:carpooling/views/messages/message_page.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BookingsPage extends StatefulWidget {
  @override
  _BookingsPageState createState() => _BookingsPageState();
}

class _BookingsPageState extends State<BookingsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final currentUserId = FirebaseAuth.instance.currentUser!.uid;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'cancelled':
        return Colors.red;
      case 'confirmed': // ➕ Add new status colors
        return Colors.blue;
      case 'in progress': // ➕ Add new status colors
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  Widget buildRideCard(Map<String, dynamic> data, String rideId, bool isDriver) {
    final dateTime = (data['date'] as Timestamp?)?.toDate() ?? DateTime.now();
    final String partnerName = isDriver ? (data['passengerName'] ?? 'Unknown Passenger') : (data['driverName'] ?? 'Unknown Driver'); // 💡 Identify who the partner is

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: Theme.of(context).cardColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔄 Modified to show relevant partner based on view
            Text(
              isDriver ? 'Passenger: $partnerName' : 'Driver: $partnerName',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold), // ✨ Make partner name bold
            ),
            const SizedBox(height: 8),
            Text(
              '${data['pickUpName'] ?? 'Unknown'} → ${data['destinationName'] ?? 'Unknown'}',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            if (data['price'] != null)
              Text(
                '${data['price']} DZD',
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Colors.green),
              ),
            const SizedBox(height: 8),
            Row( // 📅 Combine Date and Time into a single row for better layout
              children: [
                Icon(Icons.calendar_today, size: 16), // ➕ Date icon
                SizedBox(width: 4),
                Text('Date: ${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}'),
                SizedBox(width: 16), // ↔️ Space between date and time
                Icon(Icons.access_time, size: 16), // ➕ Time icon
                SizedBox(width: 4),
                Text('Time: ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}'),
              ],
            ),
            // ➕ Add Estimated Drop-off Time for passenger view
            if (!isDriver && data['estimatedDropOffTime'] != null) // Assumes you have this field in your ride data
              Text('Estimated Drop-off: ${data['estimatedDropOffTime']}'),

            if (data['distanceKm'] != null)
              Text('Distance: ${data['distanceKm'].toStringAsFixed(2)} km'),
            
            // 🚗 Add Vehicle Information for passenger view
            if (!isDriver && data['vehicleMake'] != null && data['vehicleModel'] != null) // Assumes you have this field in your ride data
              Text('Vehicle: ${data['vehicleMake']} ${data['vehicleModel']}'),
            if (!isDriver && data['licensePlate'] != null) // Assumes you have this field in your ride data
              Text('License Plate: ${data['licensePlate']}'),

            // 💰 Add Payment Status for passenger view or Payout Status for driver view
            if (!isDriver && data['paymentStatus'] != null) // Assumes you have this field in your ride data
              Text('Payment Status: ${data['paymentStatus']}'),
            if (isDriver && data['payoutStatus'] != null) // Assumes you have this field in your ride data
              Text('Payout Status: ${data['payoutStatus']}'),
            if (isDriver && data['paymentMethod'] != null) // Assumes you have this field in your ride data
              Text('Payment Method: ${data['paymentMethod']}'),

            const SizedBox(height: 8),
            Row(
              children: [
                const Text('Status: ',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Text(
                  data['status'] ?? 'unknown',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _getStatusColor(data['status']),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // 📞 Add Action Buttons based on view and status
            if (isDriver) ...[
              // Driver Actions
              if (data['status'] == 'pending') // Example: If ride needs acceptance
                ElevatedButton(
                  onPressed: () {
                    // Logic to accept ride
                    print('Driver accepted ride ${rideId}');
                  },
                  child: Text('Accept Ride'),
                ),
              if (data['status'] == 'confirmed') // Example: If ride is confirmed
                ElevatedButton(
                  onPressed: () {
                    // Logic to navigate to pickup
                    print('Navigate to pickup for ride ${rideId}');
                  },
                  child: Text('Navigate to Pickup'),
                ),
              // 💬 Chat button for both views
              ElevatedButton.icon(
                onPressed: () {
                  // Navigate to chat with passenger/driver
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MessagePage( chatId: '', otherUserId: '', rideId: '', // Make sure you have these emails in your data
                      ),
                    ),
                  );
                },
                icon: Icon(Icons.chat),
                label: Text('Chat with ${isDriver ? 'Passenger' : 'Driver'}'),
              ),
            ] else ...[
              // Passenger Actions
              if (data['status'] == 'pending' || data['status'] == 'confirmed') // Example: If ride is pending or confirmed
                ElevatedButton(
                  onPressed: () {
                    // Logic to cancel ride
                    print('Passenger canceling ride ${rideId}');
                  },
                  child: Text('Cancel Ride'),
                ),
              if (data['status'] == 'completed') // Example: If ride is completed
                ElevatedButton(
                  onPressed: () {
                    // Logic to rate driver
                    print('Passenger rating driver for ride ${rideId}');
                  },
                  child: Text('Rate Driver'),
                ),
              // 💬 Chat button for both views
              ElevatedButton.icon(
                onPressed: () {
                  // Navigate to chat with passenger/driver
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MessagePage( chatId: '', otherUserId: '', rideId: '', // Make sure you have these emails in your data
                      ),
                    ),
                  );
                },
                icon: Icon(Icons.chat),
                label: Text('Chat with ${isDriver ? 'Passenger' : 'Driver'}'),
              ),
            ],
            // 🆔 Add Ride ID for support
            Align( // ➡️ Align to the right
              alignment: Alignment.bottomRight,
              child: Text(
                'Ride ID: $rideId',
                style: Theme.of(context).textTheme.bodySmall, // 🔍 Smaller text
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildRidesList({required bool isDriver}) {
    // ⚠️ IMPORTANT: Your current query filters by userId only.
    // For a proper bookings page, you need to filter rides where:
    // - FOR PASSENGER VIEW: The current user is a 'bookedPassenger' in the ride's passenger list.
    // - FOR DRIVER VIEW: The current user is the 'driverId' of the ride.
    // You'll need to adjust your Firestore query and filtering logic accordingly.
    // The current logic `userId == currentUserId` for driver and `userId != currentUserId` for passenger
    // implies that `userId` refers to the driver who published the ride.
    // If a passenger books a ride, their ID should be added to a list of `bookedPassengers` in the ride document.

    // Here's an example of how you might fetch based on a 'passengers' subcollection or 'bookedPassengers' array
    // This example still uses `userId` as the driver's ID for the driver view.
    // For passenger view, you'd ideally query for rides where `bookedPassengers` array contains `currentUserId`.

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('rides')
          .orderBy('date', descending: false)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No rides found.'));
        }

        final rides = snapshot.data!.docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final rideDriverId = data['userId']; // Assuming 'userId' is the driver's ID
          final List<dynamic> bookedPassengers = data['bookedPassengers'] ?? []; // Assumes array of passenger UIDs

          return isDriver
              ? rideDriverId == currentUserId
              : bookedPassengers.contains(currentUserId); // 🔍 Passenger view: check if current user is among booked passengers
        }).toList();

        if (rides.isEmpty) {
          return Center(
            child: Text('No available rides for this view.'), // ✍️ More specific message
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 10),
          itemCount: rides.length,
          itemBuilder: (context, index) {
            final ride = rides[index];
            final data = ride.data() as Map<String, dynamic>;
            return buildRideCard(data, ride.id, isDriver);
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bookings'),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Passenger'),
            Tab(text: 'Driver'),
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
        controller: _tabController,
        children: [
          buildRidesList(isDriver: false),
          buildRidesList(isDriver: true),
        ],
      ),
    );
  }
}