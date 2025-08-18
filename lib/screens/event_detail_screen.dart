// lib/screens/event_detail_screen.dart
import 'package:flutter/material.dart';
import '../models/event.dart';

class EventDetailScreen extends StatelessWidget {
  final Event event;
  EventDetailScreen({required this.event});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(event.title)),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              event.title,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text("${event.location} • ${event.date}"),
            Spacer(),
            ElevatedButton(
              child: Text("Book Seats"),
              onPressed: () {
                Navigator.pushNamed(context, '/seats', arguments: event);
              },
            ),
          ],
        ),
      ),
    );
  }
}
