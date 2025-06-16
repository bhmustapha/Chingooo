import 'package:flutter/material.dart';

class LinkedAccountsPage extends StatefulWidget {
  const LinkedAccountsPage({super.key});

  @override
  State<LinkedAccountsPage> createState() => _LinkedAccountsPageState();
}

class _LinkedAccountsPageState extends State<LinkedAccountsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Linked accounts'),
        elevation: 0,
      ),
      body: Center(child: Text('Coming soon'),),
    );
  }
}