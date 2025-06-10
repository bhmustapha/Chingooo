import 'package:carpooling/services/chat_services.dart';
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
      case 'confirmed':
        return Colors.blue;
      case 'in progress':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  Widget buildBookedRideCard(Map<String, dynamic> data, String rideId, bool isDriver) {
    final dateTime = (data['date'] as Timestamp?)?.toDate() ?? DateTime.now();
    final String partnerName = isDriver ? (data['']) : null;

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
            Text(
              'Published by ${data['userName'] ?? 'Unknown'}',
              style: Theme.of(context).textTheme.labelLarge,
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
            Text(
                'Date: ${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}'),
            Text(
                'Time: ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}'),
            if (data['distanceKm'] != null)
              Text('Distance: ${data['distanceKm'].toStringAsFixed(2)} km'),
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
            
          ],
        ),
      ),
    );
  }

  Widget buildBookedRidesList({required bool isDriver}) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('rides') //! change collection
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
          final userId = data['userId'];
          return isDriver
              ? userId == currentUserId
              : userId != currentUserId; // passenger view
        }).toList();

        if (rides.isEmpty) {
          return Center(
            child: Text('No available rides'),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 10),
          itemCount: rides.length,
          itemBuilder: (context, index) {
            final ride = rides[index];
            final data = ride.data() as Map<String, dynamic>;
            return buildBookedRideCard(data, ride.id, isDriver);
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
        elevation: 0,
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          buildBookedRidesList(isDriver: false),
          buildBookedRidesList(isDriver: true),
        ],
      ),
    );
  }
}
