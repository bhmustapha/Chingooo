import 'package:carpooling/main.dart';
import 'package:carpooling/views/messages/chat_services.dart';
import 'package:carpooling/views/ride/utils/ride_utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MessagePage extends StatefulWidget {
  final String chatId;
  final String rideId;
  final String otherUserId;

  const MessagePage({
    required this.chatId,
    required this.rideId,
    required this.otherUserId,
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

  String? _otherUserName;
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
            .orderBy('timestamp', descending: true) //!!!!!!!!!!!!!!!!!!
            .snapshots(); //! to learn

    _userStream =
        FirebaseFirestore.instance
            .collection('users')
            .doc(widget.otherUserId)
            .snapshots();
    _rideStream =
        FirebaseFirestore.instance
            .collection('rides')
            .doc(widget.rideId)
            .snapshots();
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
    bool isMe = message['sender_id'] == currentUserId;
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: EdgeInsets.all(12),
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
            topLeft: Radius.circular(12),
            topRight: Radius.circular(12),
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

    int base = (range['base']! / 10).round() * 10;
    int min = (range['min']! / 10).floor() * 10;
    int max = (range['max']! / 10).ceil() * 10;

    int tempPrice = base;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
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
                  Text(
                    'Adjust Ride Price (DZD)',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20),
                  Text(
                    '$tempPrice DZD',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 30),
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
                          await FirebaseFirestore.instance
                              .collection('rides')
                              .doc(widget.rideId)
                              .update({'price': tempPrice});
                          setState(() {
                            price = tempPrice.toDouble();
                          });
                          Navigator.pop(context);
                        },
                        icon: Icon(Icons.check),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
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
          if (isDriver) IconButton(icon: Icon(Icons.money), onPressed: () {showPriceAdjustmentSheet(context); print(distanceInKm);}),
        ],

        title: StreamBuilder<DocumentSnapshot>(
          stream: _userStream,
          builder: (context, userSnapshot) {
            return StreamBuilder<DocumentSnapshot>(
              stream: _rideStream,
              builder: (context, rideSnapshot) {
                if (!userSnapshot.hasData || !rideSnapshot.hasData) {
                  return Text('Loading...');
                }

                final userDoc = userSnapshot.data!;
                final rideDoc = rideSnapshot.data!;

                final userData = userDoc.data() as Map<String, dynamic>?;
                final rideData = rideDoc.data() as Map<String, dynamic>?;

                if (userData == null) {
                  return Text('User not found');
                }

                if (rideData == null) {
                  return Text('Ride not found');
                }
                final fetchedDistance =
                    (rideData['distanceKm'] ?? 0);
                final fetchedPrice = (rideData['price'] ?? 0);

                if (fetchedDistance != distanceInKm || fetchedPrice != price) {
                  WidgetsBinding.instance.addPostFrameCallback((_) { //! to learn 
                    setState(() {
                      distanceInKm = fetchedDistance; // 🌍 Updated from DB
                      price = fetchedPrice; // 💰 Updated from DB
                    });
                  });
                }

                final name = userData['name'] ?? 'User';
                final destination = rideData['destinationName'] ?? 'Unknown';
                final driverId = rideData['userId'];
                final currentPrice = rideData['price'];

                final newIsDriver =
                    (driverId == currentUserId); // 3lah: to avoid rebuild loops
                if (newIsDriver != isDriver) {
                  // ida kanou the same ma dir wlw wla tdkhol fi loop
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    setState(() {
                      isDriver = newIsDriver;
                    });
                  });
                }

                final isOtherDriver = (driverId == widget.otherUserId);

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$name ${isOtherDriver ? "(Driver)" : ""}',
                      style: TextStyle(fontSize: 16),
                    ),
                    Text(
                      'To: $destination ($currentPrice DZD)',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
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
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              //! to learn
              stream: _messagesStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text('No messages yet'));
                }

                final docs = snapshot.data!.docs;
                return ListView.builder(
                  reverse: true, //!!!!!!!!!!!!!!!!!!
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
          Divider(height: 1),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.only(left: 18),
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide(
                          color: const Color.fromARGB(255, 241, 241, 241),
                          width: 2,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide(
                          color: const Color.fromARGB(255, 241, 241, 241),
                          width: 2,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide(color: Colors.blue, width: 2),
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
                  icon: Icon(LucideIcons.send, color: Colors.blue),
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
