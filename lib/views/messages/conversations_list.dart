import 'package:flutter/material.dart';
import 'message_page.dart';

class ChatListPage extends StatelessWidget {
  //! simulated list ( bdlha bl backend)
  final List<Map<String, dynamic>> chatList = [
    {
      'conversationId': '1',
      'friendName': 'Abdellah Bns',
      'lastMessage': 'Win rak wasel??',
      'timestamp': '10:24 AM',
    },
    {
      'conversationId': '2',
      'friendName': 'Hamid Djilali',
      'lastMessage': 'Chhal souma talia khouya?',
      'timestamp': 'Yesterday',
    },
    {
      'conversationId': '3',
      'friendName': 'Fatima Ben',
      'lastMessage': 'Ma nrkbch mea rjel khouya',
      'timestamp': 'Mon', 
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 24),
            Text(
              'Messages',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w700,
              ),
            ),
        
            Expanded(
              child: ListView.builder(
                itemCount: chatList.length,
                itemBuilder: (context, index) {
                  final chat = chatList[index];
                  return ListTile(
                    leading: CircleAvatar(child: Text(chat['friendName'][0])),
                    title: Text(chat['friendName']),
                    subtitle: Text(chat['lastMessage']),
                    trailing: Text(
                      chat['timestamp'],
                      style: TextStyle(fontSize: 12),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => MessagePage(
                                conversationId: chat['conversationId'],
                                friendName: chat['friendName'],
                              ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
