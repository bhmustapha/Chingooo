import 'package:carpooling/widgets/navigation_bar.dart';
import 'package:flutter/material.dart';

class BookingsPage extends StatefulWidget {
  const BookingsPage({super.key});

  @override
  State<BookingsPage> createState() => _BookingsPageState();
}

class _BookingsPageState extends State<BookingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('Bookings Page'),
      ),
      bottomNavigationBar: BottomNavBar(),
    );
  }
}