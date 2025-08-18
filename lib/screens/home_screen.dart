// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import '../models/event.dart';

class HomeScreen extends StatelessWidget {
  final List<Event> events = [
    Event(
      id: "1",
      title: "Avengers: Endgame",
      location: "PVR Cinema",
      date: "Aug 20, 7:00 PM",
    ),
    Event(
      id: "2",
      title: "Rock Concert",
      location: "City Stadium",
      date: "Aug 22, 8:00 PM",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("BookItNow")),
      body: ListView.builder(
        itemCount: events.length,
        itemBuilder: (context, index) {
          final event = events[index];
          return ListTile(
            title: Text(event.title),
            subtitle: Text("${event.location} • ${event.date}"),
            onTap: () {
              Navigator.pushNamed(context, '/event', arguments: event);
            },
          );
        },
      ),
    );
  }
}
