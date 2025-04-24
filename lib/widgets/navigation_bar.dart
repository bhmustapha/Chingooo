import 'package:flutter/material.dart';
import 'package:carpooling/views/home/home_page.dart';

import '../views/bookings/bookings_page.dart';


class BottomNavBar extends StatefulWidget {
  const BottomNavBar({super.key});

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {

  var selectedIndex = 0;
  
  void _onItemPressed(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
          currentIndex: selectedIndex,
          onTap: (index) {
            switch (index) {
              case 0:
             /* Navigator.pushReplacement(
  context,
  PageRouteBuilder(
    pageBuilder: (context, animation1, animation2) => const HomePage(),
    transitionDuration: Duration.zero,
    reverseTransitionDuration: Duration.zero,
  ),
);*/           Navigator.pushReplacementNamed(context, '/home');
              
              break;
              case 1:
              /*Navigator.pushReplacement(
  context,
  PageRouteBuilder(
    pageBuilder: (context, animation1, animation2) => const BookingsPage(),
    transitionDuration: Duration.zero,
    reverseTransitionDuration: Duration.zero,
  ),
);*/
              Navigator.pushReplacementNamed(context, '/bookings');
              break;
              case 2:
              Navigator.pushReplacementNamed(context, '/messages');
              break;
              case 3:
              Navigator.pushReplacementNamed(context, '/profile');
              break;
            }
          },

          backgroundColor: Colors.white,
          selectedItemColor: const Color.fromARGB(255, 31, 145, 245),
          unselectedItemColor: const Color.fromARGB(255, 104, 184, 250),
          selectedIconTheme: IconThemeData(size: 16),
          unselectedIconTheme: IconThemeData(size: 20),

          type: BottomNavigationBarType.fixed,
          items: [
            BottomNavigationBarItem(
              icon: Icon(
                Icons.search,
                ),
              label : 'Search'
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.roundabout_right_rounded,
                ),
              label: 'Bookings' 
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.message,
                ),
              label: 'messages',
              ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.person,
                ),
              label: 'Profile',
              )
          ],
        
    );
  }
}