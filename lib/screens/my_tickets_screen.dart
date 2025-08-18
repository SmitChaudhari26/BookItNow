// lib/screens/my_tickets_screen.dart
import 'package:flutter/material.dart';

class MyTicketsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("My Tickets")),
      body: Center(child: Text("Your booked tickets will appear here.")),
    );
  }
}
