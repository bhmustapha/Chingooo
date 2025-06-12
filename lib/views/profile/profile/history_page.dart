import 'package:carpooling/widgets/snackbar_utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:async/async.dart'; // For StreamZip to combine streams
import 'package:carpooling/services/chat_services.dart';
import 'package:carpooling/views/messages/message_page.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final String currentUserId = FirebaseAuth.instance.currentUser!.uid;

  late final Stream<QuerySnapshot> _passengerBookingsStream;
  late final Stream<QuerySnapshot> _driverBookingsStream;
  late final Stream<List<QuerySnapshot>> _combinedBookingsStream;

  @override
  void initState() {
    super.initState();

    _passengerBookingsStream = FirebaseFirestore.instance
        .collection('bookings')
        .where('passengerId', isEqualTo: currentUserId)
        .orderBy('createdAt', descending: true)
        .snapshots();

    _driverBookingsStream = FirebaseFirestore.instance
        .collection('bookings')
        .where('driverId', isEqualTo: currentUserId)
        .orderBy('createdAt', descending: true)
        .snapshots();

    _combinedBookingsStream = StreamZip([
      _passengerBookingsStream,
      _driverBookingsStream,
    ]);
  }

  String _formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return 'N/A';
    final date = timestamp.toDate();
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      String period = date.hour < 12 ? 'AM' : 'PM';
      int hour = date.hour % 12;
      if (hour == 0) hour = 12; // 12 AM/PM
      return 'Today at ${hour}:${date.minute.toString().padLeft(2, '0')} $period';
    } else if (difference.inDays == 1) {
      return 'Yesterday at ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } else {
      final monthNames = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      return '${monthNames[date.month - 1]} ${date.day}, ${date.year}';
    }
  }

  Future<bool> _hasUserRatedBooking(String bookingId, String raterId) async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('ratings')
        .where('bookingId', isEqualTo: bookingId)
        .where('raterId', isEqualTo: raterId)
        .limit(1) //! to learn
        .get();
    return querySnapshot.docs.isNotEmpty;
  }

  void _showRatingDialog(BuildContext context, String bookingId, String rideId, String ratedUserId, String ratedUserName) {
    double currentRating = 3.0; // Default rating
    TextEditingController commentController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return Dialog( // Changed from AlertDialog to Dialog for more customizability
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 10,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch, // Stretch children horizontally
                children: [
                  Text(
                    'Rate $ratedUserName',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue, // A more vibrant title color
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 15),
                  const Text(
                    'How was your experience with this user?',
                    style: TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 25),
                  // Rating Slider with a more prominent display
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.05), // Light background for the rating section
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.blue.withOpacity(0.1)),
                    ),
                    child: StatefulBuilder(
                      builder: (context, setDialogState) {
                        return Column(
                          children: [
                            SliderTheme( 
                              data: SliderTheme.of(context).copyWith(
                                activeTrackColor: Colors.amber, // Gold for active track
                                inactiveTrackColor: Colors.grey[300],
                                thumbColor: Colors.amber, // Gold for thumb
                                overlayColor: Colors.amber.withOpacity(0.2),
                                valueIndicatorColor: Colors.amber.shade700,
                                trackHeight: 6.0,
                                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12.0),
                                overlayShape: const RoundSliderOverlayShape(overlayRadius: 25.0),
                              ),
                              child: Slider(
                                value: currentRating,
                                min: 1.0,
                                max: 5.0,
                                divisions: 4,
                                label: currentRating.round().toString(),
                                onChanged: (value) {
                                  setDialogState(() {
                                    currentRating = value;
                                  });
                                },
                              ),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(5, (index) {
                                return Icon(
                                  index < currentRating.round() ? Icons.star : Icons.star_border,
                                  color: Colors.amber, // Star color
                                  size: 30,
                                );
                              }),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              '${currentRating.round()} Stars',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 25),
                  TextField(
                    controller: commentController,
                    decoration: InputDecoration(
                      labelText: 'Optional Comment',
                      alignLabelWithHint: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15), // More rounded text field
                        borderSide: BorderSide(color: Colors.blue.withOpacity(0.5)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: const BorderSide(color: Colors.blue, width: 2.0),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide(color: Colors.transparent)),
                      hintText: 'Share your thoughts on the experience...',
                      
                    ),
                    maxLines: 4,
                    keyboardType: TextInputType.multiline,
                    textCapitalization: TextCapitalization.sentences,
                  ),
                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end, 
                    children: <Widget>[
                      TextButton(
                        child: const Text(
                          'Cancel',
                          style: TextStyle(color: Colors.grey, fontSize: 16),
                        ),
                        onPressed: () {
                          Navigator.of(dialogContext).pop();
                        },
                      ),
                      const SizedBox(width: 10),
                      OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)), 
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          side: BorderSide.none
                        ),
                        child: const Text('Submit Rating'),
                        onPressed: () async {
                          if (currentRating == 0) { // Basic validation
                            showErrorSnackbar(dialogContext, 'Please select a rating!');
                            return;
                          }
                          await _submitRating(
                            bookingId: bookingId,
                            rideId: rideId,
                            raterId: currentUserId,
                            ratedUserId: ratedUserId,
                            rating: currentRating.round(),
                            comment: commentController.text.trim(),
                          );
                          Navigator.of(dialogContext).pop();
                          showSuccessSnackbar(context, 'Rating submitted successfully!');
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

 Future<void> _updateUserAverageRating(String userId, int newRating) async {
    try {
      final userRef = FirebaseFirestore.instance.collection('users').doc(userId);
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final userDoc = await transaction.get(userRef);

        if (userDoc.exists) {
          final userData = userDoc.data() as Map<String, dynamic>;
          double currentAverage = (userData['averageRating'] as num?)?.toDouble() ?? 0.0;
          int ratingsCount = (userData['ratingsCount'] as int?) ?? 0;

          double newTotalSum = (currentAverage * ratingsCount) + newRating;
          int newRatingsCount = ratingsCount + 1;
          double newAverage = newTotalSum / newRatingsCount;

          transaction.update(userRef, {
            'averageRating': newAverage,
            'ratingsCount': newRatingsCount,
          });
        } else {
          // If user document doesn't exist (shouldn't happen for rated user),
          // initialize with the first rating.
          transaction.set(userRef, {
            'averageRating': newRating.toDouble(),
            'ratingsCount': 1,
            // You might want to add other default user fields here if it's a new user
            // e.g., 'name': 'Unknown User', 'email': 'N/A'
          }, SetOptions(merge: true)); // Use merge to avoid overwriting existing data
        }
      });
      print('Average rating updated for user $userId');
    } catch (e) {
      print('Error updating average rating for user $userId: $e');
      // Consider showing a less intrusive message or logging this error
    }
  }


// Modify your existing _submitRating function like this:
Future<void> _submitRating({
  required String bookingId,
  required String rideId,
  required String raterId,
  required String ratedUserId,
  required int rating,
  String? comment,
}) async {
  try {
    await FirebaseFirestore.instance.collection('ratings').add({
      'bookingId': bookingId,
      'rideId': rideId,
      'raterId': raterId,
      'ratedUserId': ratedUserId,
      'rating': rating,
      'comment': comment,
      'timestamp': Timestamp.now(),
    });

    // Call the new helper function to update the rated user's average rating
    await _updateUserAverageRating(ratedUserId, rating);

  } catch (e) {
    print('Error submitting rating: $e');
    showErrorSnackbar(context, 'Failed to submit rating: $e');
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Booking History'),
        elevation: 0,
      ),
      body: StreamBuilder<List<QuerySnapshot>>(
        stream: _combinedBookingsStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
                child: Text('No booking history found yet.'));
          }

          List<DocumentSnapshot> allBookingDocs = [];
          Set<String> processedBookingIds = {};

          for (var querySnapshot in snapshot.data!) {
            for (var doc in querySnapshot.docs) {
              if (!processedBookingIds.contains(doc.id)) {
                allBookingDocs.add(doc);
                processedBookingIds.add(doc.id);
              }
            }
          }

          allBookingDocs.sort((a, b) {
            final Timestamp? timestampA = a.data() is Map ? (a.data() as Map<String, dynamic>)['createdAt'] as Timestamp? : null;
            final Timestamp? timestampB = b.data() is Map ? (b.data() as Map<String, dynamic>)['createdAt'] as Timestamp? : null;

            if (timestampA == null && timestampB == null) return 0;
            if (timestampA == null) return 1;
            if (timestampB == null) return -1;

            return timestampB.compareTo(timestampA);
          });

          if (allBookingDocs.isEmpty) {
            return const Center(child: Text('No booking history found yet.'));
          }

          return ListView.builder(
            itemCount: allBookingDocs.length,
            itemBuilder: (context, index) {
              final bookingDoc = allBookingDocs[index];
              final bookingData = bookingDoc.data() as Map<String, dynamic>;
              final String bookingId = bookingDoc.id;
              final String rideId = bookingData['rideId'] ?? '';
              final String passengerId = bookingData['passengerId'] ?? '';
              final String driverId = bookingData['driverId'] ?? '';
              final Timestamp? bookingTimestamp = bookingData['createdAt'] as Timestamp?;
              final String? bookingStatus = bookingData['status'] as String?;

              final String otherUserId = (passengerId == currentUserId) ? driverId : passengerId;
              final bool isCurrentUserManager = (driverId == currentUserId);

              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance.collection('users').doc(otherUserId).get(),
                builder: (context, userSnapshot) {
                  String otherUserName = 'Unknown User';
                  if (userSnapshot.connectionState == ConnectionState.done && userSnapshot.hasData) {
                    final userData = userSnapshot.data!.data() as Map<String, dynamic>?;
                    otherUserName = userData?['name'] ?? 'Unknown User';
                  } else if (userSnapshot.hasError) {
                    otherUserName = 'Error User';
                  }

                  return FutureBuilder<DocumentSnapshot>(
                    future: FirebaseFirestore.instance.collection('rides').doc(rideId).get(),
                    builder: (context, rideSnapshot) {
                      String destinationName = 'Unknown Destination';
                      String price = 'N/A';

                      if (rideSnapshot.connectionState == ConnectionState.done && rideSnapshot.hasData) {
                        final rideData = rideSnapshot.data!.data() as Map<String, dynamic>?;
                        destinationName = rideData?['destinationName'] ?? 'Unknown Destination';
                        price = (rideData?['price'] as num?)?.toStringAsFixed(0) ?? 'N/A';
                      } else if (rideSnapshot.hasError) {
                        destinationName = 'Error Destination';
                      }

                      return FutureBuilder<bool>(
                        future: _hasUserRatedBooking(bookingId, currentUserId),
                        builder: (context, ratedSnapshot) {
                          final bool hasUserRated = ratedSnapshot.data ?? false;

                          final bool showRateButton = bookingStatus == 'completed' &&
                                                     otherUserId != currentUserId &&
                                                     !hasUserRated;

                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            elevation: 2,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            child: InkWell(
                              onTap: () async {
                                String chatServiceDriverId = isCurrentUserManager ? currentUserId : otherUserId;
                                String chatServicePassengerId = isCurrentUserManager ? otherUserId : currentUserId;

                                String chatId = await ChatService.createOrGetChat(
                                  rideId: rideId,
                                  driverId: chatServiceDriverId,
                                  passengerId: chatServicePassengerId,
                                ).toString();

                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => MessagePage(
                                      chatId: chatId,
                                      rideId: rideId,
                                      otherUserId: otherUserId,
                                      isRideRequest: false,
                                    ),
                                  ),
                                );
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Opening chat for booking to $destinationName')),
                                );
                              },
                              borderRadius: BorderRadius.circular(12),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            isCurrentUserManager ? 'Driver for ${otherUserName}' : 'Booked with ${otherUserName}',
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          _formatTimestamp(bookingTimestamp),
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Destination: $destinationName',
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Price: $price DZD',
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                    if (bookingStatus != null) ...[
                                      const SizedBox(height: 8),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: bookingStatus == 'completed'
                                                  ? Colors.green.withOpacity(0.1)
                                                  : bookingStatus == 'cancelled'
                                                      ? Colors.red.withOpacity(0.1)
                                                      : Colors.blue.withOpacity(0.1),
                                              borderRadius: BorderRadius.circular(5),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  bookingStatus == 'completed'
                                                      ? Icons.check_circle_outline
                                                      : bookingStatus == 'cancelled'
                                                          ? Icons.cancel_outlined
                                                          : Icons.info_outline,
                                                  size: 16,
                                                  color: bookingStatus == 'completed'
                                                      ? Colors.green[700]
                                                      : bookingStatus == 'cancelled'
                                                          ? Colors.red[700]
                                                          : Colors.blue[700],
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  bookingStatus.toUpperCase(),
                                                  style: TextStyle(
                                                    color: bookingStatus == 'completed'
                                                        ? Colors.green[700]
                                                        : bookingStatus == 'cancelled'
                                                            ? Colors.red[700]
                                                            : Colors.blue[700],
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),

                                          if (showRateButton)
                                            OutlinedButton.icon(
                                              onPressed: () {
                                                _showRatingDialog(
                                                  context,
                                                  bookingId,
                                                  rideId,
                                                  otherUserId,
                                                  otherUserName,
                                                );
                                              },
                                              icon: const Icon(Icons.star_half, size: 20),
                                              label: const Text('Rate User'),
                                              style: OutlinedButton.styleFrom(
                                                backgroundColor: Colors.orange,
                                                foregroundColor: Colors.white,
                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                                textStyle: const TextStyle(fontSize: 13),
                                                side: BorderSide.none
                                              ),
                                            ),
                                        ],
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}