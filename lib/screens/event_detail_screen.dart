// lib/screens/event_detail_screen.dart
import 'package:bookitnow/screens/event_venue_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/event.dart';
import '../models/event_venue.dart';

class EventDetailScreen extends StatefulWidget {
  final Event event;
  const EventDetailScreen({required this.event, Key? key}) : super(key: key);

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  List<EventVenue> venues = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _fetchVenues();
  }

  Future<void> _fetchVenues() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('eventVenues')
        .where('eventId', isEqualTo: widget.event.id)
        .get();

    final fetchedVenues = snapshot.docs
        .map((doc) => EventVenue.fromMap(doc.id, doc.data()))
        .toList();

    setState(() {
      venues = fetchedVenues;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.event.name)),
      body: loading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Event Poster
                  Container(
                    width: double.infinity,
                    height: 300,
                    decoration: BoxDecoration(
                      image: widget.event.image.isNotEmpty
                          ? DecorationImage(
                              image: NetworkImage(widget.event.image),
                              fit: BoxFit.cover,
                            )
                          : null,
                      color: Colors.grey[300],
                    ),
                    child: widget.event.image.isEmpty
                        ? Icon(Icons.event, size: 80, color: Colors.grey[700])
                        : null,
                  ),
                  SizedBox(height: 16),

                  // Event Info
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.event.name,
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          "${widget.event.certificate} | ${widget.event.language} | ${widget.event.duration} | ${widget.event.category.join(', ')}",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                          ),
                        ),
                        SizedBox(height: 12),
                        Text(
                          widget.event.description,
                          style: TextStyle(fontSize: 16),
                        ),
                        SizedBox(height: 24),

                        Text(
                          "Available Venues",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 12),

                        // Venues list
                        venues.isEmpty
                            ? Text("No venues available yet")
                            : Column(
                                children: venues.map((venue) {
                                  return Card(
                                    margin: EdgeInsets.symmetric(vertical: 8),
                                    child: ListTile(
                                      title: Text(
                                        "${venue.venueName}, ${venue.venueLocation}",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      subtitle: Text(
                                        "${venue.language} | ${venue.dateTime.day}/${venue.dateTime.month}/${venue.dateTime.year} "
                                        "at ${venue.dateTime.hour}:${venue.dateTime.minute.toString().padLeft(2, '0')}\n"
                                        "Capacity: ${venue.capacity} | Booked: ${venue.bookedCount}",
                                      ),
                                      trailing: Icon(Icons.arrow_forward_ios),
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                EventVenueDetailScreen(
                                                  venue: venue,
                                                ),
                                          ),
                                        );
                                      },
                                    ),
                                  );
                                }).toList(),
                              ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
