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
          title: Text("Your Ticket"),
          automaticallyImplyLeading: true, // ✅ show back button
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              QrImageView(
                data: ticket.qrData,
                version: QrVersions.auto,
                size: 250.0,
              ),
              SizedBox(height: 20),
              Text(
                "Movie: ${ticket.movieName}\n"
                "Theater: ${ticket.theaterName}\n"
                "City: ${ticket.cityName}\n"
                "Date: ${ticket.dateTime}\n"
                "ShowTime: ${ticket.showTime}\n"
                "Section: ${ticket.seatSection}\n"
                "Seats: ${ticket.seatNumbers.join(', ')}",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
