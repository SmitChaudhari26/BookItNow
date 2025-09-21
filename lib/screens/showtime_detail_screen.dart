// lib/screens/showtime_detail_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../models/show.dart';
import '../models/ticket.dart';
import 'ticket_qr_screen.dart';

class ShowtimeDetailScreen extends StatefulWidget {
  final Show show;
  final String selectedTime;

  const ShowtimeDetailScreen({required this.show, required this.selectedTime});

  @override
  _ShowtimeDetailScreenState createState() => _ShowtimeDetailScreenState();
}

class _ShowtimeDetailScreenState extends State<ShowtimeDetailScreen> {
  late Map<String, List<bool>> seatsMap;
  Set<String> selectedSeats = {};
  late Razorpay _razorpay;

  @override
  void initState() {
    super.initState();

    seatsMap = {
      "Executive": List<bool>.from(
        widget.show.executiveSeats[widget.selectedTime]!,
      ),
      "Club": List<bool>.from(widget.show.clubSeats[widget.selectedTime]!),
      "Royal": List<bool>.from(widget.show.royalSeats[widget.selectedTime]!),
      "Recliner": List<bool>.from(
        widget.show.reclinerSeats[widget.selectedTime]!,
      ),
    };

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
    _bookSeats();
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Payment failed: ${response.message}")),
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("External Wallet: ${response.walletName}")),
    );
  }

  void _openCheckout(int amountInRupees) {
    var options = {
      'key': 'rzp_test_your_key', // Replace with your Razorpay Test Key
      'amount': amountInRupees * 100, // in paise
      'name': 'Movie Booking',
      'description': widget.show.mediaItemId,
      'prefill': {'contact': '9876543210', 'email': 'test@example.com'},
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

  void _bookSeats() async {
    final userId = FirebaseAuth.instance.currentUser!.uid;

    // Fetch movie & theater details
    final movieDoc = await FirebaseFirestore.instance
        .collection("movies")
        .doc(widget.show.mediaItemId)
        .get();
    final movieName = movieDoc.exists ? movieDoc["name"] : "Unknown Movie";

    final theaterDoc = await FirebaseFirestore.instance
        .collection("theaters")
        .doc(widget.show.theaterId)
        .get();
    final theaterName = theaterDoc.exists
        ? theaterDoc["name"]
        : "Unknown Theater";
    final cityName = theaterDoc.exists
        ? theaterDoc["location"]
        : "Unknown City";

    // Calculate total amount

    // Create ticket
    final ticket = Ticket(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      userId: userId,
      movieName: movieName,
      theaterName: theaterName,
      cityName: cityName,
      dateTime: widget.show.date,
      showTime: widget.selectedTime,
      seatSection: selectedSeats.first.split("-")[0],
      seatNumbers: selectedSeats
          .map((s) => int.parse(s.split("-")[1]))
          .toList(),
    );

    final ticketRef = FirebaseFirestore.instance
        .collection("tickets")
        .doc(ticket.id);
    await ticketRef.set(ticket.toMap());

    // Update booked seats
    final showRef = FirebaseFirestore.instance
        .collection("movieShows")
        .doc(widget.show.id);

    for (var seat in selectedSeats) {
      final section = seat.split("-")[0];
      final seatNum = int.parse(seat.split("-")[1]) - 1;
      seatsMap[section]![seatNum] = true;
    }

    await showRef.set({
      "executiveSeats": {"${widget.selectedTime}": seatsMap["Executive"]},
      "clubSeats": {"${widget.selectedTime}": seatsMap["Club"]},
      "royalSeats": {"${widget.selectedTime}": seatsMap["Royal"]},
      "reclinerSeats": {"${widget.selectedTime}": seatsMap["Recliner"]},
    }, SetOptions(merge: true));

    // Navigate to QR screen
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => TicketQrScreen(ticket: ticket)),
    );
  }

  Widget _buildSeatRow(String type, List<bool> seats) {
    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: seats.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 10,
        crossAxisSpacing: 6,
        mainAxisSpacing: 6,
      ),
      itemBuilder: (context, index) {
        final booked = seats[index];
        final seatId = "$type-${index + 1}";
        final isSelected = selectedSeats.contains(seatId);

        return GestureDetector(
          onTap: booked
              ? null
              : () {
                  setState(() {
                    if (isSelected) {
                      selectedSeats.remove(seatId);
                    } else {
                      selectedSeats.add(seatId);
                    }
                  });
                },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(
                color: booked
                    ? Colors.red
                    : isSelected
                    ? Colors.blue
                    : Colors.green,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(6),
            ),
            alignment: Alignment.center,
            child: Text(
              "${index + 1}",
              style: TextStyle(
                color: booked
                    ? Colors.red
                    : isSelected
                    ? Colors.blue
                    : Colors.green,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _legendBox(Color color, String text) {
    return Row(
      children: [
        Container(
          width: 20,
          height: 20,
          margin: EdgeInsets.only(right: 6),
          decoration: BoxDecoration(
            border: Border.all(color: color, width: 2),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        Text(text),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.show.mediaItemId} - ${widget.selectedTime}"),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: double.infinity,
                height: 40,
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Text(
                  "Projection Screen",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
            ...seatsMap.entries.map((entry) {
              final type = entry.key;
              final seats = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      type,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    _buildSeatRow(type, seats),
                  ],
                ),
              );
            }).toList(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _legendBox(Colors.green, "Available"),
                _legendBox(Colors.blue, "Selected"),
                _legendBox(Colors.red, "Booked"),
              ],
            ),
            SizedBox(height: 80),
          ],
        ),
      ),
      bottomNavigationBar: selectedSeats.isNotEmpty
          ? Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  minimumSize: Size(double.infinity, 50),
                ),
                onPressed: () {
                  // Calculate dynamic price
                  Map<String, int> seatPrices = {
                    "Executive": 100,
                    "Club": 150,
                    "Royal": 250,
                    "Recliner": 400,
                  };

                  int totalAmount = selectedSeats.fold(0, (sum, seatId) {
                    final type = seatId.split("-")[0];
                    return sum + (seatPrices[type] ?? 0);
                  });

                  _openCheckout(totalAmount);
                },
                child: Text(
                  "Pay & Book ${selectedSeats.length} Seat(s)",
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            )
          : null,
    );
  }
}
