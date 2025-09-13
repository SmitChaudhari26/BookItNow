// lib/screens/showtime_detail_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';
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
  Set<String> selectedSeats = {}; // ✅ Track selected seats

  @override
  void initState() {
    super.initState();
    // Get seat list only for the selected showtime
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
  }

  Widget _buildSeatRow(String type, List<bool> seats) {
    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: seats.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 10, // ✅ 10 seats per row
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
                    ? Colors
                          .blue // selected seat
                    : Colors.green, // available seat
                width: 2,
              ),
              borderRadius: BorderRadius.circular(6),
            ),
            alignment: Alignment.center,
            child: Text(
              "${index + 1}", // seat number
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

  void _bookSeats() async {
    final userId = FirebaseAuth.instance.currentUser!.uid; // ✅ get current user

    // 1️⃣ Fetch movie name from movie ID
    final movieDoc = await FirebaseFirestore.instance
        .collection("movies")
        .doc(widget.show.mediaItemId)
        .get();
    final movieName = movieDoc.exists ? movieDoc["name"] : "Unknown Movie";

    // 2️⃣ Fetch theater name from theater ID
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

    final ticket = Ticket(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      userId: userId,
      movieName: movieName,
      theaterName: theaterName,
      cityName: cityName,
      showTime: widget.selectedTime,
      seatSection: selectedSeats.first.split("-")[0],
      seatNumbers: selectedSeats
          .map((s) => int.parse(s.split("-")[1]))
          .toList(),
    );

    final ticketRef = FirebaseFirestore.instance
        .collection("tickets")
        .doc(ticket.id);

    // Save ticket
    await ticketRef.set(ticket.toMap());

    // Update booked seats safely
    final showRef = FirebaseFirestore.instance
        .collection("movieShows")
        .doc(widget.show.id);

    Map<String, List<bool>> updatedSeats(
      String section,
      Map<String, dynamic> seatsMap,
    ) {
      final map = Map<String, List<bool>>.from(seatsMap[section] ?? {});
      if (!map.containsKey(widget.selectedTime)) {
        map[widget.selectedTime] = List.filled(
          seatsMap[section]?.values.first.length ?? 0,
          false,
        );
      }
      return map;
    }

    final executive = updatedSeats("executiveSeats", widget.show.toMap());
    final club = updatedSeats("clubSeats", widget.show.toMap());
    final royal = updatedSeats("royalSeats", widget.show.toMap());
    final recliner = updatedSeats("reclinerSeats", widget.show.toMap());

    // Mark selected seats as booked
    for (var seat in selectedSeats) {
      final section = seat.split("-")[0];
      final seatNum = int.parse(seat.split("-")[1]) - 1;

      switch (section) {
        case "Executive":
          executive[widget.selectedTime]![seatNum] = true;
          break;
        case "Club":
          club[widget.selectedTime]![seatNum] = true;
          break;
        case "Royal":
          royal[widget.selectedTime]![seatNum] = true;
          break;
        case "Recliner":
          recliner[widget.selectedTime]![seatNum] = true;
          break;
      }
    }

    // Push updated seat info to Firestore safely
    await showRef.set({
      "executiveSeats": executive,
      "clubSeats": club,
      "royalSeats": royal,
      "reclinerSeats": recliner,
    }, SetOptions(merge: true));

    // Navigate to QR screen
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => TicketQrScreen(ticket: ticket)),
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
            // ✅ Projection Screen at the top
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

            // ✅ Seats below the screen
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

            // ✅ Legend for clarity
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

      // ✅ Book Button
      bottomNavigationBar: selectedSeats.isNotEmpty
          ? Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  minimumSize: Size(double.infinity, 50),
                ),
                onPressed: _bookSeats,
                child: Text(
                  "Book ${selectedSeats.length} Seat(s)",
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            )
          : null,
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
}
