// lib/screens/seat_selection_screen.dart
import 'package:flutter/material.dart';
import '../models/event.dart';

class SeatSelectionScreen extends StatefulWidget {
  final Event event;
  SeatSelectionScreen({required this.event});

  @override
  _SeatSelectionScreenState createState() => _SeatSelectionScreenState();
}

class _SeatSelectionScreenState extends State<SeatSelectionScreen> {
  List<int> selectedSeats = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Select Seats")),
      body: GridView.builder(
        padding: EdgeInsets.all(16),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 6,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemCount: 30,
        itemBuilder: (context, index) {
          bool isSelected = selectedSeats.contains(index);
          return GestureDetector(
            onTap: () {
              setState(() {
                isSelected
                    ? selectedSeats.remove(index)
                    : selectedSeats.add(index);
              });
            },
            child: Container(
              decoration: BoxDecoration(
                color: isSelected ? Colors.green : Colors.grey,
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        label: Text("Confirm (${selectedSeats.length})"),
        onPressed: () {
          Navigator.pushReplacementNamed(context, '/tickets');
        },
      ),
    );
  }
}
