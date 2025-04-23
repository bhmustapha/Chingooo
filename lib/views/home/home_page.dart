import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  var selectedIndex = 0;
  
  void _onItemPressed(int index) {
    setState(() {
      selectedIndex = index;
    });
  }
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
    children: [
      Image.asset(
        'assets/images/map.jpeg',
        height: double.infinity,
        width: double.infinity,  
      ),
      // Bottom navigation bar positioned over the container
     Positioned(
  left: 16,
  right: 16,
  bottom: 24,
  child: Center(
    child: ClipRRect( // 9nouta mdwrin
      borderRadius: BorderRadius.circular(20),
      
      child: Container( 
        width: 200,
        child: BottomNavigationBar(
          
          currentIndex: selectedIndex,
          onTap: _onItemPressed,
          selectedFontSize: 14,
          unselectedFontSize: 12,
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.directions_car),
              label: 'Bookings',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    ),
  ),
),

    ],
  ),
);
  }
}