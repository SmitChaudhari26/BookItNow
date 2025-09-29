// lib/screens/home_screen.dart
import 'package:bookitnow/models/event.dart';
import 'package:bookitnow/screens/event_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/movie.dart';
import 'movie_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  String searchQuery = "";

  Future<List<Movie>> _fetchMoviesByLocation([String? location]) async {
    final moviesSnapshot = await FirebaseFirestore.instance.collection('movies').get();
    List<Movie> movieList = [];

    for (var movieDoc in moviesSnapshot.docs) {
      final movie = Movie.fromMap(movieDoc.id, movieDoc.data());
      final showsSnapshot = await FirebaseFirestore.instance
          .collection('movieShows')
          .where('mediaItemId', isEqualTo: movie.id)
          .get();

      bool includeMovie = location == null || location.isEmpty;
      if (!includeMovie) {
        for (var showDoc in showsSnapshot.docs) {
          final showData = showDoc.data();
          final theaterId = showData['theaterId'];
          final theaterDoc = await FirebaseFirestore.instance.collection('theaters').doc(theaterId).get();
          if (theaterDoc.exists &&
              theaterDoc['location'].toString().toLowerCase() == location.toLowerCase()) {
            includeMovie = true;
            break;
          }
        }
      }

      if (includeMovie) movieList.add(movie);
    }
    return movieList;
  }

  Future<List<Event>> _fetchEventsByLocation([String? location]) async {
    final eventsSnapshot = await FirebaseFirestore.instance.collection('events').get();
    List<Event> eventList = [];

    for (var eventDoc in eventsSnapshot.docs) {
      final event = Event.fromMap(eventDoc.id, eventDoc.data());
      final venuesSnapshot = await FirebaseFirestore.instance
          .collection('eventVenues')
          .where('eventId', isEqualTo: event.id)
          .get();

      bool includeEvent = location == null || location.isEmpty;
      if (!includeEvent) {
        for (var venueDoc in venuesSnapshot.docs) {
          final venueData = venueDoc.data();
          if (venueData['venueLocation'].toString().toLowerCase() == location.toLowerCase()) {
            includeEvent = true;
            break;
          }
        }
      }

      if (includeEvent) eventList.add(event);
    }

    return eventList;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("BookItNow", style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: Icon(Icons.history),
            onPressed: () => Navigator.pushNamed(context, '/bookingHistory'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🔹 Search Bar
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: "Search by city (e.g., Nadiad)",
                  prefixIcon: Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    searchQuery = value.trim();
                  });
                },
              ),
              SizedBox(height: 20),

              // Movies Section
              Text("Movies", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              SizedBox(height: 12),
              FutureBuilder<List<Movie>>(
                future: _fetchMoviesByLocation(searchQuery.isEmpty ? null : searchQuery),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
                  if (snapshot.data!.isEmpty) return Text("No movies available.");
                  return SizedBox(
                    height: 280,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        final movie = snapshot.data![index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => MovieDetailScreen(movie: movie)),
                            );
                          },
                          child: Container(
                            width: 180,
                            margin: EdgeInsets.only(right: 12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.3), blurRadius: 6, offset: Offset(0, 3))],
                              color: Colors.white,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  height: 180,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                                    image: movie.image.isNotEmpty
                                        ? DecorationImage(image: NetworkImage(movie.image), fit: BoxFit.cover)
                                        : null,
                                    color: Colors.grey[300],
                                  ),
                                  child: movie.image.isEmpty
                                      ? Icon(Icons.movie, size: 80, color: Colors.grey[700])
                                      : null,
                                ),
                                Padding(
                                  padding: EdgeInsets.all(8),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(movie.name, style: TextStyle(fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                                      SizedBox(height: 4),
                                      Text("${movie.certificate} | ${movie.language.join(', ')}", style: TextStyle(fontSize: 12, color: Colors.grey[700])),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
              SizedBox(height: 24),

              // Events Section
              Text("Events", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              SizedBox(height: 12),
              FutureBuilder<List<Event>>(
                future: _fetchEventsByLocation(searchQuery.isEmpty ? null : searchQuery),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
                  if (snapshot.data!.isEmpty) return Text("No events available.");
                  return SizedBox(
                    height: 280,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        final event = snapshot.data![index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => EventDetailScreen(event: event)),
                            );
                          },
                          child: Container(
                            width: 180,
                            margin: EdgeInsets.only(right: 12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.3), blurRadius: 6, offset: Offset(0, 3))],
                              color: Colors.white,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  height: 180,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                                    image: event.image.isNotEmpty
                                        ? DecorationImage(image: NetworkImage(event.image), fit: BoxFit.cover)
                                        : null,
                                    color: Colors.grey[300],
                                  ),
                                  child: event.image.isEmpty
                                      ? Icon(Icons.event, size: 80, color: Colors.grey[700])
                                      : null,
                                ),
                                Padding(
                                  padding: EdgeInsets.all(8),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(event.name, style: TextStyle(fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                                      SizedBox(height: 4),
                                      Text(event.category.join(', '), style: TextStyle(fontSize: 12, color: Colors.grey[700]), maxLines: 1, overflow: TextOverflow.ellipsis),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
