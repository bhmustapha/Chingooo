import 'package:carpooling/main.dart';
import 'package:carpooling/services/booking_service.dart';
import 'package:carpooling/services/chat_services.dart';
import 'package:carpooling/views/profile/users_profiles.dart';
import 'package:carpooling/views/ride/utils/ride_utils.dart';
import 'package:carpooling/widgets/snackbar_utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MessagePage extends StatefulWidget {
  final String chatId;
  final String rideId;
  final String otherUserId;
  final bool isRideRequest;

  const MessagePage({
    required this.chatId,
    required this.rideId,
    required this.otherUserId,
    this.isRideRequest = false,
    super.key,
  });

  @override
  State<MessagePage> createState() => _MessagePageState();
}

class _MessagePageState extends State<MessagePage> {
  late final Stream<QuerySnapshot> _messagesStream; //! learn
  late final Stream<DocumentSnapshot> _userStream;
  late final Stream<DocumentSnapshot> _rideStream;
  bool isDriver = false;

  final currentUserId = FirebaseAuth.instance.currentUser!.uid;
  final TextEditingController _controller = TextEditingController();

  
  double distanceInKm = 0;
  double price = 0;

  @override
  void initState() {
    super.initState();
    _messagesStream =
        FirebaseFirestore.instance
            .collection('conversations')
            .doc(widget.chatId)
            .collection('messages')
            .orderBy('timestamp', descending: true) 
            .snapshots(); //! to learn

    _userStream =
        FirebaseFirestore.instance
            .collection('users')
            .doc(widget.otherUserId)
            .snapshots();

    if (widget.isRideRequest) {
      _rideStream =
          FirebaseFirestore.instance
              .collection('ride_requests')
              .doc(widget.rideId)
              .snapshots();
    } else {
      _rideStream =
          FirebaseFirestore.instance
              .collection('rides')
              .doc(widget.rideId)
              .snapshots();
    }
  }

  void _showRideInfoDialog(BuildContext context) async {
    final docRef = FirebaseFirestore.instance
        .collection(widget.isRideRequest ? 'ride_requests' : 'rides')
        .doc(widget.rideId);

    final docSnap = await docRef.get();

    if (!docSnap.exists) {
      showDialog(
        context: context,
        builder:
            (_) => const AlertDialog(
              title: Text("Error"),
              content: Text("Ride not found."),
            ),
      );
      return;
    }

    final data = docSnap.data() as Map<String, dynamic>;
    final destination = data['destinationName'] ?? 'Unknown';
    final double price = (data['price'] as num?)?.toDouble() ?? 0.0; 
    final double distance = (data['distanceKm'] as num?)?.toDouble() ?? 0.0; 
    final timestamp = data['date']; 

    String formattedDate = 'Unknown';
    String formattedTime = '';

    if (timestamp != null && timestamp is Timestamp) {
      final dateTime = timestamp.toDate();
      formattedDate = "${dateTime.day}/${dateTime.month}/${dateTime.year}";
      formattedTime =
          "${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}";
    }

    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
              title: const Text("Ride Info"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Destination: $destination"),
                  Text("Price: ${price.toStringAsFixed(0)} DZD"),
                  Text("Distance: ${distance.toStringAsFixed(1)} km"),
                  const SizedBox(height: 8),
                  Text("Date: $formattedDate"),
                  Text("Time: $formattedTime"),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Close"),
                ),
              ],
            ),
    );
  }

  void _sendMessage() async {
    final text =
        _controller.text.trim(); // .trim removes whitespace from both ends
    if (text.isNotEmpty) {
      final currentUserId = FirebaseAuth.instance.currentUser!.uid;

      await FirebaseFirestore.instance
          .collection('conversations')
          .doc(widget.chatId)
          .collection('messages')
          .add({
            'text': text,
            'sender_id': currentUserId,
            'timestamp': Timestamp.now(),
          });

      _controller.clear();
    }
  }

  Widget _buildMessageBubble(Map<String, dynamic> message) {
    final senderId = message['sender_id'];
    final isSystem = senderId == 'system';

    if (isSystem) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Center(
          child: Text(
            message['text'],
            style: const TextStyle(
              color: Colors.grey,
              fontStyle: FontStyle.italic,
              fontSize: 13,
            ),
          ),
        ),
      );
    }

    bool isMe = message['sender_id'] == currentUserId;
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: const EdgeInsets.all(12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 1,
        ),
        decoration: BoxDecoration(
          color:
              isMe
                  ? Colors.blue
                  : themeNotifier.value == ThemeMode.light
                  ? Colors.grey[300]
                  : Colors.grey[900],
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(12),
            topRight: const Radius.circular(12),
            bottomLeft: Radius.circular(isMe ? 12 : 0),
            bottomRight: Radius.circular(isMe ? 0 : 12),
          ),
        ),
        child: Text(
          message['text'],
          style: TextStyle(
            color:
                themeNotifier.value == ThemeMode.light
                        ? isMe
                            ? Colors.white
                            : Colors.black
                        : Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w300,
            fontFamily: 'Lato',
          ),
        ),
      ),
    );
  }

  void showPriceAdjustmentSheet(BuildContext context) {
    final range = RideUtils.getNegotiablePriceRange(
      distanceInKm,
      marginPercent: 20,
    );

    int base = (range['base']! / 10).round() * 10; //! round
    int min = (range['min']! / 10).floor() * 10; //! floor
    int max = (range['max']! / 10).ceil() * 10; //! ceil

    int tempPrice = base;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Adjust Ride Price (DZD)',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    '$tempPrice DZD',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 30),
                  Row(
                    children: [
                      Expanded(
                        child: Slider(
                          min: min.toDouble(),
                          max: max.toDouble(),
                          divisions: ((max - min) ~/ 10),
                          value: tempPrice.toDouble(),
                          onChanged: (value) {
                            setModalState(() {
                              tempPrice = value.round();
                            });
                          },
                          label: '$tempPrice DZD',
                        ),
                      ),
                      IconButton(
                        onPressed: () async {
                          final collectionName =
                              widget.isRideRequest ? 'ride_requests' : 'rides';

                          await FirebaseFirestore.instance
                              .collection(collectionName)
                              .doc(widget.rideId)
                              .update({'price': tempPrice});

                          final systemMessage =
                              widget.isRideRequest
                                  ? 'The passenger proposed a new price: $tempPrice DZD'
                                  : 'The driver updated the price to $tempPrice DZD';

                          await FirebaseFirestore.instance
                              .collection('conversations')
                              .doc(widget.chatId)
                              .collection('messages')
                              .add({
                                'text': systemMessage,
                                'sender_id': 'system',
                                'timestamp': Timestamp.now(),
                              });

                          setState(() {
                            price = tempPrice.toDouble();
                          });
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.check),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          StreamBuilder<DocumentSnapshot>(
            stream: _rideStream,
            builder: (context, rideSnapshot) {
              if (!rideSnapshot.hasData || !rideSnapshot.data!.exists) {
                return const SizedBox();
              }
              final rideData = rideSnapshot.data!.data() as Map<String, dynamic>;
              final ownerId = rideData['userId'];

              // Only show adjust price button if current user is the owner 
              if (ownerId == currentUserId) {
                return IconButton(
                  icon: const Icon(Icons.money, color: Colors.blue),
                  onPressed: () {
                    showPriceAdjustmentSheet(context);
                  },
                );
              } 
              return const SizedBox();
            },
          ),
          IconButton(
            icon: const Icon(Icons.phone, color: Colors.blue),
            onPressed: () {
              ChatService.callUser(widget.otherUserId);
            },
          ),
          IconButton(
            icon: const Icon(Icons.info_outline, color: Colors.blue),
            onPressed: () {
              _showRideInfoDialog(context);
            },
          ),
        ],

        title: StreamBuilder<DocumentSnapshot>(
          stream: _userStream,
          builder: (context, userSnapshot) {
            return StreamBuilder<DocumentSnapshot>(
              stream: _rideStream,
              builder: (context, rideSnapshot) {
                if (!userSnapshot.hasData || !rideSnapshot.hasData) {
                  return const Text('Loading...');
                }

                final userDoc = userSnapshot.data!;
                final rideDoc = rideSnapshot.data!;

                final userData = userDoc.data() as Map<String, dynamic>?;
                final rideData = rideDoc.data() as Map<String, dynamic>?;

                if (userData == null) {
                  return const Text('User not found');
                }

                if (rideData == null) {
                  return const Text('Ride not found');
                }
                
                final double fetchedDistance = (rideData['distanceKm'] as num?)?.toDouble() ?? 0.0; 
                final double fetchedPrice = (rideData['price'] as num?)?.toDouble() ?? 0.0; 

                if (fetchedDistance != distanceInKm || fetchedPrice != price) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    //! to learn
                    setState(() {
                      distanceInKm = fetchedDistance;
                      price = fetchedPrice;
                    });
                  });
                }

                final name = userData['name'] ?? 'User';
                final destination = rideData['destinationName'] ?? 'Unknown';
                final driverId =
                    rideData['isRequested'] == true ? '' : rideData['userId'];
                
                final int currentPrice = (rideData['price'] as num?)?.toInt() ?? 0; 

                final newIsDriver =
                    (driverId == currentUserId); // 3lah: to avoid rebuild loops
                if (newIsDriver != isDriver) {
                  // ida kanou the same ma dir wlw wla tdkhol fi loop
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    // !to learn
                    setState(() {
                      isDriver = newIsDriver;
                    });
                  });
                }

                final isOtherDriver = (driverId == widget.otherUserId);

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => UserProfilePage(userId: userData['uid'])));
                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.all(0)
                      ),
                      child: Text('$name ${isOtherDriver ? "(Driver)" : ""}',style: TextStyle(fontSize: 16, color: themeNotifier.value == ThemeMode.light
                  ? Colors.black
                  : Colors.white),),
                    ),
                    Text(
                      'To: $destination ($currentPrice DZD)',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                );
              },
            );
          },
        ),

        elevation: 0,
      ),
      body: Column(
        children: [
          StreamBuilder<DocumentSnapshot>(
            stream: _rideStream,
            builder: (context, rideSnapshot) {
              if (!rideSnapshot.hasData || !rideSnapshot.data!.exists) {
                return const SizedBox.shrink(); // Hide button if no ride data
              }
              final rideData = rideSnapshot.data!.data() as Map<String, dynamic>;
              final ownerId = rideData['userId'];

              final List<dynamic> bookedBy = rideData['bookedBy'] ?? [];
              final bool hasCurrentUserBooked = bookedBy.contains(currentUserId);

              // Show button only if current user is NOT the owner,
              // has NOT already booked it, and it's NOT a ride request.
              if (ownerId != currentUserId && !hasCurrentUserBooked && !widget.isRideRequest) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: SizedBox( // Use SizedBox to make the button full width
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        BookingService.bookRide(rideId: rideData['ride_id']);
                        showSuccessSnackbar(context, 'Ride boocked succefuly!');
                      },
                      label: const Text('Book this Ride'),
                      icon: const Icon(Icons.bookmark_border), 
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15), 
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                );
              }
              return const SizedBox.shrink(); 
            },
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _messagesStream, //! to learn
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No messages yet'));
                }

                final docs = snapshot.data!.docs;
                return ListView.builder(
                  reverse: true,
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final doc = docs[index];
                    final message = {
                      'text': doc['text'],
                      'sender_id': doc['sender_id'],
                      'timestamp': doc['timestamp'],
                    };
                    return _buildMessageBubble(message);
                  },
                );
              },
            ),
          ),
          
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.only(left: 18),
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: const BorderSide(
                          color: Color.fromARGB(255, 241, 241, 241),
                          width: 2,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: const BorderSide(
                          color: Color.fromARGB(255, 241, 241, 241),
                          width: 2,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: const BorderSide(color: Colors.blue, width: 2),
                      ),
                    ),
                    onSubmitted: (value) {
                      ChatService.sendMessage(
                        chatId: widget.chatId,
                        senderId: currentUserId,
                        text: value,
                      );
                      _controller.clear();
                    },
                  ),
                ),
                IconButton(
                  icon: const Icon(LucideIcons.send, color: Colors.blue),
                  onPressed: () {
                    final text = _controller.text.trim();
                    ChatService.sendMessage(
                      chatId: widget.chatId,
                      senderId: currentUserId,
                      text: text,
                    );
                    _controller.clear();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
      
    );
  }
}
