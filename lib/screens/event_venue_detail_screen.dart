// lib/screens/event_venue_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
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
  late Razorpay _razorpay;
  int selectedTicketCount = 1;

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();

    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  // Razorpay Handlers
  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    _bookTicket(
      selectedTicketCount,
    ); // Book tickets only after successful payment
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Payment failed: ${response.message}")),
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("External wallet: ${response.walletName}")),
    );
  }

  // Open Razorpay Checkout
  void _openCheckout(int amountInRupees) {
    var options = {
      'key':
          'rzp_test_your_Api_Key', // Replace with your Razorpay Test Key ID
      'amount': amountInRupees * 100, // amount in paise
      'name': 'Event Booking',
      'description': widget.venue.venueName,
      'prefill': {
        'contact': '9876543210',
        'email': 'test@example.com',
      }, //5123 4567 8901 2346
      'external': {
        'wallets': ['paytm'],
      },
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  // Booking function (after payment)
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

        // Create ticket
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
          ticketCount: count,
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

  // Show ticket count dialog
  void _showBookingDialog() {
    selectedTicketCount = 1;

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
                  if (selectedTicketCount > 1)
                    setState(() => selectedTicketCount--);
                },
                icon: Icon(Icons.remove),
              ),
              Text(
                selectedTicketCount.toString(),
                style: TextStyle(fontSize: 18),
              ),
              IconButton(
                onPressed: () {
                  if (selectedTicketCount <
                      widget.venue.capacity - widget.venue.bookedCount)
                    setState(() => selectedTicketCount++);
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
              // Suppose ticket price is ₹500 per ticket
              int totalAmount = selectedTicketCount * 500;
              _openCheckout(totalAmount); // Open Razorpay payment
            },
            child: Text("Pay & Book Tickets"),
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
