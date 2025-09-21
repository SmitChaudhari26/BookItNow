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

  /// Fetch movies with shows in a given location
  Future<List<Movie>> _fetchMoviesByLocation(String location) async {
    final moviesSnapshot = await FirebaseFirestore.instance
        .collection('movies')
        .get();

    List<Movie> movieList = [];
    for (var movieDoc in moviesSnapshot.docs) {
      final movie = Movie.fromMap(movieDoc.id, movieDoc.data());

      // Get shows for this movie
      final showsSnapshot = await FirebaseFirestore.instance
          .collection('movieShows')
          .where('mediaItemId', isEqualTo: movie.id)
          .get();

      bool hasShowInLocation = false;

      for (var showDoc in showsSnapshot.docs) {
        final showData = showDoc.data();
        final theaterId = showData['theaterId'];

        // Fetch theater for this show
        final theaterDoc = await FirebaseFirestore.instance
            .collection('theaters')
            .doc(theaterId)
            .get();

        if (theaterDoc.exists &&
            theaterDoc['location'].toString().toLowerCase() ==
                location.toLowerCase()) {
          hasShowInLocation = true;
          break;
        }
      }

      if (hasShowInLocation) {
        movieList.add(movie);
      }
    }

    return movieList;
  }

  /// Fetch events with venues in a given location
  Future<List<Event>> _fetchEventsByLocation(String location) async {
    final eventsSnapshot = await FirebaseFirestore.instance
        .collection('events')
        .get();

    List<Event> eventList = [];
    for (var eventDoc in eventsSnapshot.docs) {
      final event = Event.fromMap(eventDoc.id, eventDoc.data());

      // Check if this event has a venue in the given location
      final venuesSnapshot = await FirebaseFirestore.instance
          .collection('eventVenues')
          .where('eventId', isEqualTo: event.id)
          .get();

      bool hasVenueInLocation = false;

      for (var venueDoc in venuesSnapshot.docs) {
        final venueData = venueDoc.data();
        if (venueData['venueLocation'].toString().toLowerCase() ==
            location.toLowerCase()) {
          hasVenueInLocation = true;
          break;
        }
      }

      if (hasVenueInLocation) {
        eventList.add(event);
      }
    }

    return eventList;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("BookItNow"),
        actions: [
          IconButton(
            icon: Icon(Icons.history),
            onPressed: () {
              Navigator.pushNamed(context, '/bookingHistory');
            },
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
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
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
              Text(
                "Movies",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 12),
              FutureBuilder<List<Movie>>(
                future: searchQuery.isEmpty
                    ? Future.value([]) // 🔹 empty when no search
                    : _fetchMoviesByLocation(searchQuery),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return CircularProgressIndicator();
                  if (snapshot.data!.isEmpty)
                    return Text("No movies available.");

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
                              MaterialPageRoute(
                                builder: (_) => MovieDetailScreen(movie: movie),
                              ),
                            );
                          },
                          child: Container(
                            width: 180,
                            margin: EdgeInsets.only(right: 12),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.black),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  height: 180,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(8),
                                    ),
                                    image: movie.image.isNotEmpty
                                        ? DecorationImage(
                                            image: NetworkImage(movie.image),
                                            fit: BoxFit.cover,
                                          )
                                        : null,
                                    color: Colors.grey[300],
                                  ),
                                  child: movie.image.isEmpty
                                      ? Icon(
                                          Icons.movie,
                                          size: 80,
                                          color: Colors.grey[700],
                                        )
                                      : null,
                                ),
                                Padding(
                                  padding: EdgeInsets.all(8),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        movie.name,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        "${movie.certificate} | ${movie.language.join(', ')}",
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[700],
                                        ),
                                      ),
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
              Text(
                "Events",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 12),
              FutureBuilder<List<Event>>(
                future: searchQuery.isEmpty
                    ? Future.value([]) // 🔹 empty when no search
                    : _fetchEventsByLocation(searchQuery),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return CircularProgressIndicator();
                  if (snapshot.data!.isEmpty)
                    return Text("No events available.");

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
                              MaterialPageRoute(
                                builder: (_) => EventDetailScreen(event: event),
                              ),
                            );
                          },
                          child: Container(
                            width: 180,
                            margin: EdgeInsets.only(right: 12),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.black),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  height: 180,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(8),
                                    ),
                                    image: event.image.isNotEmpty
                                        ? DecorationImage(
                                            image: NetworkImage(event.image),
                                            fit: BoxFit.cover,
                                          )
                                        : null,
                                    color: Colors.grey[300],
                                  ),
                                  child: event.image.isEmpty
                                      ? Icon(
                                          Icons.event,
                                          size: 80,
                                          color: Colors.grey[700],
                                        )
                                      : null,
                                ),
                                Padding(
                                  padding: EdgeInsets.all(8),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        event.name,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        event.category.join(', '),
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[700],
                                        ),
                                      ),
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
