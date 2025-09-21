// lib/screens/event_ticket_qr_screen.dart
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../models/event_ticket.dart';
import 'home_screen.dart'; // replace with your actual Home screen

class EventTicketQRScreen extends StatelessWidget {
  final List<EventTicket> tickets;
  const EventTicketQRScreen({required this.tickets, Key? key})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Redirect to Home screen and clear previous routes
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => HomeScreen()),
          (route) => false,
        );
        return false; // Prevent default back behavior
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text("Your Tickets"),
          automaticallyImplyLeading: true,
        ),
        body: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: tickets.length,
          itemBuilder: (_, index) {
            final ticket = tickets[index];

            final qrData = {
              "userId": ticket.userId,
              "eventName": ticket.eventName,
              "venueName": ticket.venueName,
              "dateTime":
                  "${ticket.dateTime.day}/${ticket.dateTime.month}/${ticket.dateTime.year} "
                  "${ticket.dateTime.hour}:${ticket.dateTime.minute.toString().padLeft(2, '0')}",
              "ticketCount": ticket.ticketCount,
            }.toString();

            return Card(
              margin: EdgeInsets.symmetric(vertical: 8),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    QrImageView(
                      data: qrData,
                      version: QrVersions.auto,
                      size: 200,
                    ),
                    SizedBox(height: 8),
                    Text(
                      "User ID: ${ticket.userId}\n"
                      "Event: ${ticket.eventName}\n"
                      "Venue: ${ticket.venueName}\n"
                      "Date: ${ticket.dateTime.day}/${ticket.dateTime.month}/${ticket.dateTime.year}\n"
                      "Time: ${ticket.dateTime.hour}:${ticket.dateTime.minute.toString().padLeft(2, '0')}\n"
                      "Tickets: ${ticket.ticketCount}",
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
