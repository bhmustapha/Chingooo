import 'package:carpooling/main.dart';
import 'package:carpooling/views/messages/chat_services.dart';
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

  String? _otherUserName;
  final currentUserId = FirebaseAuth.instance.currentUser!.uid;
  final TextEditingController _controller = TextEditingController();

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
          color: isMe ? Colors.blue : themeNotifier.value == ThemeMode.light? Colors.grey : Colors.grey[900],
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
            color: themeNotifier.value == ThemeMode.light ? Colors.black : Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w200,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: StreamBuilder<DocumentSnapshot>(
          stream: _userStream,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Text('Loading...');
            }
            if (snapshot.hasError) {
              return Text('Error loading name');
            }

            final data = snapshot.data!;
            final name = data['name'] ?? 'User';
            return Text(name);
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
