// lib/screens/event_ticket_qr_screen.dart
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../models/event_ticket.dart';
import 'home_screen.dart'; // replace with your actual Home screen

class EventTicketQRScreen extends StatelessWidget {
  final List<EventTicket> tickets;
  const EventTicketQRScreen({required this.tickets, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => HomeScreen()),
          (route) => false,
        );
        return false;
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
              elevation: 6,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              margin: EdgeInsets.symmetric(vertical: 12),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    // ✅ QR in its own box
                    Card(
                      color: Colors.grey.shade50,
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: QrImageView(
                          data: qrData,
                          version: QrVersions.auto,
                          size: 180,
                        ),
                      ),
                    ),
                    SizedBox(height: 16),

                    // ✅ Ticket details inside styled container
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Text(
                        "🎤 Event: ${ticket.eventName}\n"
                        "📍 Venue: ${ticket.venueName}\n"
                        "📅 Date: ${ticket.dateTime.day}/${ticket.dateTime.month}/${ticket.dateTime.year}\n"
                        "⏰ Time: ${ticket.dateTime.hour}:${ticket.dateTime.minute.toString().padLeft(2, '0')}\n"
                        "🎟 Tickets: ${ticket.ticketCount}",
                        textAlign: TextAlign.left,
                        style: TextStyle(fontSize: 16, height: 1.5),
                      ),
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
