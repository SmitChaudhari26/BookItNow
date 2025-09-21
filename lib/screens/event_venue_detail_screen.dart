// lib/screens/event_venue_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/event_venue.dart';
import '../models/event_ticket.dart';
import 'event_ticket_qr_screen.dart';

class EventVenueDetailScreen extends StatefulWidget {
  final EventVenue venue;
  const EventVenueDetailScreen({required this.venue, Key? key})
    : super(key: key);

  @override
  State<EventVenueDetailScreen> createState() => _EventVenueDetailScreenState();
}

class _EventVenueDetailScreenState extends State<EventVenueDetailScreen> {
  bool booking = false;

  Future<void> _bookTicket(int count) async {
    setState(() => booking = true);

    final venueRef = FirebaseFirestore.instance
        .collection('eventVenues')
        .doc(widget.venue.id);

    try {
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final snapshot = await transaction.get(venueRef);
        if (!snapshot.exists) throw Exception("Venue does not exist");

        final data = snapshot.data()!;
        final bookedCount = data['bookedCount'] ?? 0;
        final capacity = data['capacity'] ?? 0;

        if (bookedCount + count > capacity) {
          throw Exception("Not enough seats available");
        }

        // Update booked count
        transaction.update(venueRef, {'bookedCount': bookedCount + count});

        // Create single ticket with ticketCount
        final userId = FirebaseAuth.instance.currentUser?.uid ?? "guest";
        final eventDoc = await FirebaseFirestore.instance
            .collection("events")
            .doc(widget.venue.eventId)
            .get();
        final eventName = eventDoc.exists ? eventDoc["name"] : "Unknown Event";

        final docRef = FirebaseFirestore.instance
            .collection('eventTickets')
            .doc();
        final ticket = EventTicket(
          id: docRef.id,
          userId: userId,
          eventId: widget.venue.eventId,
          eventName: eventName,
          venueId: widget.venue.id,
          venueName: widget.venue.venueName,
          dateTime: widget.venue.dateTime,
          createdAt: DateTime.now(),
          ticketCount: count, // set number of tickets
        );

        transaction.set(docRef, ticket.toMap());

        // Navigate to QR screen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => EventTicketQRScreen(tickets: [ticket]),
          ),
        );
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }

    setState(() => booking = false);
  }

  void _showBookingDialog() {
    int count = 1;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("How many tickets?"),
        content: StatefulBuilder(
          builder: (context, setState) => Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: () {
                  if (count > 1) setState(() => count--);
                },
                icon: Icon(Icons.remove),
              ),
              Text(count.toString(), style: TextStyle(fontSize: 18)),
              IconButton(
                onPressed: () {
                  if (count < widget.venue.capacity - widget.venue.bookedCount)
                    setState(() => count++);
                },
                icon: Icon(Icons.add),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _bookTicket(count);
            },
            child: Text("Book"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final venue = widget.venue;

    return Scaffold(
      appBar: AppBar(title: Text("Venue Details")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              venue.venueName,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text("${venue.venueLocation}"),
            SizedBox(height: 8),
            Text("Language: ${venue.language}"),
            SizedBox(height: 8),
            Text(
              "Date: ${venue.dateTime.day}/${venue.dateTime.month}/${venue.dateTime.year}",
            ),
            Text(
              "Time: ${venue.dateTime.hour}:${venue.dateTime.minute.toString().padLeft(2, '0')}",
            ),
            SizedBox(height: 8),
            Text("Capacity: ${venue.capacity}"),
            Text("Booked: ${venue.bookedCount}"),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: booking ? null : _showBookingDialog,
              child: booking
                  ? CircularProgressIndicator(color: Colors.white)
                  : Text("Book Ticket"),
            ),
          ],
        ),
      ),
    );
  }
}
