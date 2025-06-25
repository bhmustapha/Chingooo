import 'package:carpooling/services/chat_services.dart';
import 'package:carpooling/services/notifications_service.dart';
import 'package:carpooling/views/messages/message_page.dart';
import 'package:carpooling/views/profile/users_profiles.dart';
import 'package:flutter/gestures.dart';
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
bool _isLoading = false;
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

  void _showMessageDialog(String title, String message) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  Future<void> _cancelBooking(String bookingId, String rideId) async {
    try {
      await FirebaseFirestore.instance
          .collection('bookings')
          .doc(bookingId)
          .delete();

           DocumentSnapshot rideSnapshot = await FirebaseFirestore.instance
        .collection('rides')
        .doc(rideId)
        .get();

        int leftPlaces = rideSnapshot.get('leftPlace');
        leftPlaces ++;

        int bookedPlaces = rideSnapshot.get('bookedPlaces');
        bookedPlaces --;

      // Remove the current user's ID from the 'bookedBy' array in the 'rides' collection
      await FirebaseFirestore.instance.collection('rides').doc(rideId).update({
        'bookedBy': FieldValue.arrayRemove([
          FirebaseAuth.instance.currentUser!.uid,
        ]),
        'leftPlace' : leftPlaces,
        'bookedPlaces' : bookedPlaces,
      });

      _showMessageDialog(
        'Booking Cancelled',
        'Your booking has been successfully cancelled and removed.',
      );
    } catch (e) {
      _showMessageDialog('Error', 'Failed to cancel booking: $e');
    }
  }

  Future<void> _acceptBooking(String bookingId, String passengerId, String destinationName ) async {
    try {
      await FirebaseFirestore.instance
          .collection('bookings')
          .doc(bookingId)
          .update({'status': 'confirmed'});
      _showMessageDialog(
        'Booking Confirmed',
        'The booking has been successfully confirmed.',
      );
      await NotificationsService.sendOneSignalNotification(userId: passengerId, title: 'Booking accepted! 🚗', message: 'Your ride to $destinationName has been accepted!');
    } catch (e) {
      _showMessageDialog('Error', 'Failed to accept booking: $e');
    }
  }

  Future<void> _declineBooking(String bookingId, String passengerId, String destinationName) async {
    try {
      await FirebaseFirestore.instance
          .collection('bookings')
          .doc(bookingId)
          .update({'status': 'cancelled'});
      _showMessageDialog('Booking Declined', 'The booking has been declined.');
      await NotificationsService.sendOneSignalNotification(userId: passengerId, title: 'Booking rejected😥!', message: 'Your ride to $destinationName has been rejected!');
    } catch (e) {
      _showMessageDialog('Error', 'Failed to decline booking: $e');
    }
  }

  Future<void> _markInProgress(String bookingId, String passengerId, String driverId, String destinationName) async {
    try {
      await FirebaseFirestore.instance
          .collection('bookings')
          .doc(bookingId)
          .update({'status': 'in progress'});
      _showMessageDialog('Status Updated', 'Booking is now in progress.');
      await NotificationsService.sendOneSignalNotification(userId: passengerId, title: 'Ride started', message: 'The ride to $destinationName started!');
      await NotificationsService.sendOneSignalNotification(userId: driverId, title: 'Ride started', message: 'The ride to $destinationName started!');
    } catch (e) {
      _showMessageDialog('Error', 'Failed to update status: $e');
    }
  }

  Future<void> _markCompleted(String bookingId, String passengerId, String driverId, String destinationName) async {
    try {
      await FirebaseFirestore.instance
          .collection('bookings')
          .doc(bookingId)
          .update({'status': 'completed'});
      _showMessageDialog('Status Updated', 'Booking marked as completed.');
      await NotificationsService.sendOneSignalNotification(userId: passengerId, title: 'Ride completed', message: 'The ride to $destinationName completed!');
      await NotificationsService.sendOneSignalNotification(userId: driverId, title: 'Ride completed', message: 'The ride to $destinationName completed!');
    } catch (e) {
      _showMessageDialog('Error', 'Failed to update status: $e');
    }
  }

  

  Future<void> _sendMessage(
    String otherUserId,
    String otherUserName,
    String rideId,
    String driverId,
    String passengerId,
  ) async {
    bool isRequestedRide = false;
    
        final bookingSnapshot = await FirebaseFirestore.instance
            .collection('bookings')
            .where('rideId', isEqualTo: rideId) // Assuming rideId here is rideRequestId
            .limit(1) // We only need one booking document if it exists
            .get();

        if (bookingSnapshot.docs.isNotEmpty) {
            final bookingData = bookingSnapshot.docs.first.data();
            // Check if 'isRideRequest' field exists and is true
            if (bookingData.containsKey('isRideRequest') && bookingData['isRideRequest'] == true) {
                isRequestedRide = true;
            }
        }
    
    // Correctly await the Future to get the DocumentReference
    final chatDocRef = await ChatService.createOrGetChat(
      rideId: rideId,
      driverId: driverId,
      passengerId: passengerId,
      isRideRequest: isRequestedRide

      // Add this parameter if your ChatService.createOrGetChat expects it
      // based on your working example, it seems to differentiate ride requests.
    );

    // Get the actual ID from the DocumentReference
    String chatId = chatDocRef.id;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => MessagePage(
              chatId: chatId, // Pass the correct chat ID
              rideId: rideId,
              otherUserId: otherUserId,
              isRideRequest: isRequestedRide,
              // Pass this parameter to MessagePage if it uses it
            ),
      ),
    );
  }

  Widget buildBookedRideCard(
    Map<String, dynamic> bookingData,
    String bookingId,
    bool isDriver,
  ) {
    final rideDetails =
        bookingData['rideDetails'] as Map<String, dynamic>? ?? {};
    final Timestamp? dateTimestamp = rideDetails['date'] as Timestamp?;
    final DateTime dateTime = dateTimestamp?.toDate() ?? DateTime.now();

    final String displayUserName =
        isDriver
            ? bookingData['passengerName'] ?? 'Unknown Passenger'
            : bookingData['driverName'] ?? 'Unknown Driver';
    final String otherUserId =
        isDriver ? bookingData['passengerId'] : bookingData['driverId'];
    final String currentBookingStatus = bookingData['status'] ?? 'pending';

    final String rideId = bookingData['rideId'] ?? '';
    final String driverId = bookingData['driverId'] ?? '';
    final String passengerId = bookingData['passengerId'] ?? '';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: Theme.of(context).cardColor,
          boxShadow: const [
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
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => UserProfilePage(
                          userId: isDriver ? passengerId : driverId,
                        ),
                  ),
                );
              },
              style: TextButton.styleFrom(padding: EdgeInsets.all(0)),
              child: Text(
                isDriver
                    ? 'Booked by: $displayUserName'
                    : 'Driver: $displayUserName',
                style: Theme.of(context).textTheme.labelLarge,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${rideDetails['pickUpName'] ?? 'Unknown'} → ${rideDetails['destinationName'] ?? 'Unknown'}',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            if (rideDetails['price'] != null)
              Text(
                '${rideDetails['price']} DZD',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Colors.green,
                ),
              ),
            Text('Seats Booked: ${bookingData['seatsBooked'] ?? 1}'),
            const SizedBox(height: 8),
            Text(
              'Date: ${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}',
            ),
            Text(
              'Time: ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}',
            ),
            if (rideDetails['distanceKm'] != null)
              Text(
                'Distance: ${rideDetails['distanceKm'].toStringAsFixed(2)} km',
              ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Text(
                  'Status: ',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  currentBookingStatus,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _getStatusColor(currentBookingStatus),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _buildActionButtons(
              bookingId,
              currentBookingStatus,
              isDriver,
              otherUserId,
              displayUserName,
              rideId,
              driverId,
              passengerId,
              rideDetails['destinationName']
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(
    String bookingId,
    String status,
    bool isDriver,
    String otherUserId,
    String otherUserName,
    String rideId,
    String driverId,
    String passengerId,
    String destinationName
  ) {
    List<Widget> buttons = [];

    buttons.add(
      OutlinedButton(
        onPressed: () async {
          _isLoading = true;
          await _sendMessage(
            otherUserId,
            otherUserName,
            rideId,
            driverId,
            passengerId,
          );
          _isLoading = false;
        },
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          side: BorderSide.none,
        ),
        child: _isLoading? CircularProgressIndicator(color: Colors.white,) : Text('Messages'),
      ),
    );

    if (isDriver) {
      switch (status) {
        case 'pending':
          buttons.add(
            OutlinedButton(
              onPressed: () => _acceptBooking(bookingId, passengerId, destinationName),
              style: OutlinedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                side: BorderSide.none,
              ),
              child: Text('Accept'),
            ),
          );
          buttons.add(
            OutlinedButton(
              onPressed: () => _declineBooking(bookingId, passengerId, destinationName),
              style: OutlinedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                side: BorderSide.none,
              ),
              child: Text('Decline'),
            ),
          );
          break;
        case 'confirmed':
          buttons.add(
            OutlinedButton(
              onPressed: () => _markInProgress(bookingId, passengerId, driverId, destinationName),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.purple,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                side: BorderSide.none,
              ),
              child: Text('Mark In Progress'),
            ),
          );
          break;
        case 'in progress':
          buttons.add(
            OutlinedButton(
              onPressed: () => _markCompleted(bookingId, passengerId, driverId, destinationName),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.deepOrange,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                side: BorderSide.none,
              ),
              child: Text(
                'Mark Completed',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          );
          break;
      }
    } else {
      switch (status) {
        case 'pending':
        case 'confirmed':
          buttons.add(
            OutlinedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Confirm Cancellation'),
                      content: const Text(
                        'Are you sure you want to cancel this booking? This action cannot be undone.',
                      ),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('No'),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            _cancelBooking(bookingId, rideId);
                          },
                          child: const Text(
                            'Yes',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.red,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                side: BorderSide.none,
              ),
              child: Text('Cancel Booking'),
            ),
          );
          break;
      }
    }

    return Wrap(spacing: 8.0, runSpacing: 4.0, children: buttons);
  }

  Widget buildBookedRidesList({required bool isDriver}) {
    return StreamBuilder<QuerySnapshot>(
      stream:
          FirebaseFirestore.instance
              .collection('bookings')
              .where('status', isNotEqualTo: 'completed')
              .orderBy('rideDetails.date', descending: false)
              .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No bookings found.'));
        }

        final relevantBookings =
            snapshot.data!.docs.where((doc) {
              final data = doc.data() as Map<String, dynamic>;
              final String passengerId = data['passengerId'] ?? '';
              final String driverId = data['driverId'] ?? '';

              return isDriver
                  ? driverId == currentUserId
                  : passengerId == currentUserId;
            }).toList();

        if (relevantBookings.isEmpty) {
          return Center(
            child: Text(
              isDriver
                  ? 'No rides published by you have bookings yet.'
                  : 'No bookings made by you.',
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 10),
          itemCount: relevantBookings.length,
          itemBuilder: (context, index) {
            final booking = relevantBookings[index];
            final data = booking.data() as Map<String, dynamic>;
            return buildBookedRideCard(data, booking.id, isDriver);
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
            Tab(text: 'My Bookings'),
            Tab(text: 'My Rides Bookings'),
          ],
          labelStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            fontFamily: 'Poppins',
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
