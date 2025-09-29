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
      appBar: AppBar(
        title: const Text(
          "Booking History",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
        elevation: 6,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _fetchAllTickets(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final movieTickets = snapshot.data!['movies'] as List<Ticket>;
          final eventTickets = snapshot.data!['events'] as List<EventTicket>;

          if (movieTickets.isEmpty && eventTickets.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.event_busy, size: 60, color: Colors.grey),
                  SizedBox(height: 12),
                  Text(
                    "No tickets booked yet.",
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (movieTickets.isNotEmpty) ...[
                  const Text(
                    "Movie Tickets",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...movieTickets.map((t) => _movieTicketTile(context, t)),
                  const SizedBox(height: 16),
                ],
                if (eventTickets.isNotEmpty) ...[
                  const Text(
                    "Event Tickets",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent,
                    ),
                  ),
                  const SizedBox(height: 8),
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.blue.shade50,
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        title: Text(
          ticket.movieName,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        subtitle: Text(
          "Theater: ${ticket.theaterName}\n"
          "Time: ${ticket.showTime}\n"
          "Date: ${ticket.dateTime.day}/${ticket.dateTime.month}/${ticket.dateTime.year}",
        ),
        trailing: const Icon(Icons.qr_code, size: 32, color: Colors.blueAccent),
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.green.shade50,
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        title: Text(
          ticket.eventName,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        subtitle: Text(
          "Venue: ${ticket.venueName}\n"
          "Date: ${ticket.dateTime.day}/${ticket.dateTime.month}/${ticket.dateTime.year}",
        ),
        trailing: const Icon(Icons.qr_code, size: 32, color: Colors.green),
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
