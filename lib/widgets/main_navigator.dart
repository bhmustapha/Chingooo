// the pages
import 'package:carpooling/views/bookings/bookings_page.dart';
import 'package:carpooling/views/home/home_page.dart';
import 'package:carpooling/views/messages/message_page.dart';
import 'package:carpooling/views/profile/profile_page.dart';

import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class MainNavigator extends StatefulWidget {
  const MainNavigator({super.key});

  @override
  State<MainNavigator> createState() => _MainNavigatorState();
}

class _MainNavigatorState extends State<MainNavigator> {
  int selectedIndex = 0;
  void _onItemPressed(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  final List<Widget> _pages = const [
    HomePage(),
    BookingsPage(),
    MessagesPage(),
    ProfilePage(),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: _onItemPressed,
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: Icon(size: 22, LucideIcons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(size: 22, LucideIcons.ticket),
            label: 'Bookings',
          ),
          BottomNavigationBarItem(
            icon: Icon(size: 22, LucideIcons.messageCircle),
            label: 'messages',
          ),
          BottomNavigationBarItem(
            icon: Icon(size: 22, LucideIcons.userRound),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
