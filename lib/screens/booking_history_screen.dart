// lib/screens/booking_history_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/ticket.dart';
import '../models/event_ticket.dart';
import 'ticket_qr_screen.dart';
import 'event_ticket_qr_screen.dart';

class BookingHistoryScreen extends StatelessWidget {
  const BookingHistoryScreen({super.key});

  Future<Map<String, dynamic>> _fetchAllTickets() async {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    print("Fetching tickets for userId: $userId\n");

    // Movie Tickets
    final movieSnapshot = await FirebaseFirestore.instance
        .collection('tickets')
        .where('userId', isEqualTo: userId)
        .get();
    final movieTickets = movieSnapshot.docs
        .map((doc) => Ticket.fromMap(doc.data()))
        .toList();

    print("Fetched ${movieTickets.length} movie tickets\n");

    // Event Tickets
    final eventSnapshot = await FirebaseFirestore.instance
        .collection('eventTickets')
        .where('userId', isEqualTo: userId)
        .get();
    final eventTickets = eventSnapshot.docs
        .map((doc) => EventTicket.fromMap(doc.id, doc.data()))
        .toList();

    print("Fetched ${eventTickets.length} event tickets\n");

    return {'movies': movieTickets, 'events': eventTickets};
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Booking History")),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _fetchAllTickets(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return Center(child: CircularProgressIndicator());

          final movieTickets = snapshot.data!['movies'] as List<Ticket>;
          final eventTickets = snapshot.data!['events'] as List<EventTicket>;

          if (movieTickets.isEmpty && eventTickets.isEmpty) {
            return Center(child: Text("No tickets booked yet."));
          }

          return SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (movieTickets.isNotEmpty) ...[
                  Text(
                    "Movie Tickets",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  ...movieTickets.map((t) => _movieTicketTile(context, t)),
                  SizedBox(height: 16),
                ],
                if (eventTickets.isNotEmpty) ...[
                  Text(
                    "Event Tickets",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  ...eventTickets.map((t) => _eventTicketTile(context, t)),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _movieTicketTile(BuildContext context, Ticket ticket) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      child: ListTile(
        title: Text(ticket.movieName),
        subtitle: Text(
          "Theater: ${ticket.theaterName}, Time: ${ticket.showTime}, Date: ${ticket.dateTime.day}/${ticket.dateTime.month}/${ticket.dateTime.year}",
        ),
        trailing: Icon(Icons.qr_code),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => TicketQrScreen(ticket: ticket)),
          );
        },
      ),
    );
  }

  Widget _eventTicketTile(BuildContext context, EventTicket ticket) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      child: ListTile(
        title: Text(ticket.eventName),
        subtitle: Text(
          "Venue: ${ticket.venueName}, Date: ${ticket.dateTime.day}/${ticket.dateTime.month}/${ticket.dateTime.year}",
        ),
        trailing: Icon(Icons.qr_code),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => EventTicketQRScreen(tickets: [ticket]),
            ),
          );
        },
      ),
    );
  }
}
