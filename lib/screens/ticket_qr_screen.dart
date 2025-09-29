import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../models/ticket.dart';
import 'home_screen.dart'; // replace with your actual Home screen

class TicketQrScreen extends StatelessWidget {
  final Ticket ticket;

  const TicketQrScreen({required this.ticket});

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
          title: Text("Your Ticket"),
          automaticallyImplyLeading: true,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // ✅ QR inside a styled box
              Card(
                elevation: 6,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                margin: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: QrImageView(
                    data: ticket.qrData,
                    version: QrVersions.auto,
                    size: 220.0,
                  ),
                ),
              ),
              SizedBox(height: 20),
              // Ticket details
              Container(
                margin: EdgeInsets.symmetric(horizontal: 24),
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.grey.shade100,
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Text(
                  "🎬 Movie: ${ticket.movieName}\n"
                  "🏛 Theater: ${ticket.theaterName}\n"
                  "📍 City: ${ticket.cityName}\n"
                  "📅 Date: ${ticket.dateTime}\n"
                  "⏰ ShowTime: ${ticket.showTime}\n"
                  "🎟 Section: ${ticket.seatSection}\n"
                  "💺 Seats: ${ticket.seatNumbers.join(', ')}",
                  textAlign: TextAlign.left,
                  style: TextStyle(fontSize: 16, height: 1.5),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
