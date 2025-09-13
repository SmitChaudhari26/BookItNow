// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/movie.dart';
//import '../models/event.dart';
import 'movie_detail_screen.dart';

class HomeScreen extends StatelessWidget {
  /// Fetch movies that have shows
  Future<List<Movie>> _fetchMovies() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('movies')
        .get();

    List<Movie> movieList = [];
    for (var doc in snapshot.docs) {
      final movie = Movie.fromMap(doc.id, doc.data());

      // Check if movie has at least one show
      final showsSnapshot = await FirebaseFirestore.instance
          .collection('movieShows')
          .where('mediaItemId', isEqualTo: movie.id)
          .get();

      if (showsSnapshot.docs.isNotEmpty) {
        movieList.add(movie);
      }
    }
    return movieList;
  }

  /// Fetch events that have shows
  // Future<List<Event>> _fetchEvents() async {
  //   final snapshot = await FirebaseFirestore.instance
  //       .collection('events')
  //       .get();

  //   List<Event> eventList = [];
  //   for (var doc in snapshot.docs) {
  //     final event = Event.fromMap(doc.id, doc.data());

  //     // Check if event has at least one show
  //     final showsSnapshot = await FirebaseFirestore.instance
  //         .collection('shows')
  //         .where('mediaItemId', isEqualTo: event.id)
  //         .get();

  //     if (showsSnapshot.docs.isNotEmpty) {
  //       eventList.add(event);
  //     }
  //   }
  //   return eventList;
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("BookItNow")),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Movies Section
              Text(
                "Movies",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 12),
              FutureBuilder<List<Movie>>(
                future: _fetchMovies(),
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

              ElevatedButton.icon(
                icon: Icon(Icons.movie),
                label: Text("Add Theater"),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                  textStyle: TextStyle(fontSize: 20),
                ),
                onPressed: () {
                  Navigator.pushNamed(context, '/addTheater');
                },
              ),
              SizedBox(height: 20),
              ElevatedButton.icon(
                icon: Icon(Icons.event),
                label: Text("Add Show"),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                  textStyle: TextStyle(fontSize: 20),
                ),
                onPressed: () {
                  Navigator.pushNamed(context, '/addShow');
                },
              ),
              SizedBox(height: 20),
              ElevatedButton.icon(
                icon: Icon(Icons.event),
                label: Text("Add Meadia Item"),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                  textStyle: TextStyle(fontSize: 20),
                ),
                onPressed: () {
                  Navigator.pushNamed(context, '/addMovie');
                },
              ),

              // Events Section
              Text(
                "Events",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 12),
              // FutureBuilder<List<Event>>(
              //   future: _fetchEvents(),
              //   builder: (context, snapshot) {
              //     if (!snapshot.hasData) return CircularProgressIndicator();
              //     if (snapshot.data!.isEmpty)
              //       return Text("No events available.");

              //     return SizedBox(
              //       height: 280,
              //       child: ListView.builder(
              //         scrollDirection: Axis.horizontal,
              //         itemCount: snapshot.data!.length,
              //         itemBuilder: (context, index) {
              //           final event = snapshot.data![index];
              //           return GestureDetector(
              //             onTap: () {
              //               Navigator.push(
              //                 context,
              //                 MaterialPageRoute(
              //                   builder: (_) => MediaDetailScreen(media: event),
              //                 ),
              //               );
              //             },
              //             child: Container(
              //               width: 180,
              //               margin: EdgeInsets.only(right: 12),
              //               decoration: BoxDecoration(
              //                 border: Border.all(color: Colors.black),
              //                 borderRadius: BorderRadius.circular(8),
              //               ),
              //               child: Column(
              //                 crossAxisAlignment: CrossAxisAlignment.start,
              //                 children: [
              //                   Container(
              //                     height: 180,
              //                     width: double.infinity,
              //                     decoration: BoxDecoration(
              //                       borderRadius: BorderRadius.vertical(
              //                         top: Radius.circular(8),
              //                       ),
              //                       image: event.image.isNotEmpty
              //                           ? DecorationImage(
              //                               image: NetworkImage(event.image),
              //                               fit: BoxFit.cover,
              //                             )
              //                           : null,
              //                       color: Colors.grey[300],
              //                     ),
              //                     child: event.image.isEmpty
              //                         ? Icon(
              //                             Icons.event,
              //                             size: 80,
              //                             color: Colors.grey[700],
              //                           )
              //                         : null,
              //                   ),
              //                   Padding(
              //                     padding: EdgeInsets.all(8),
              //                     child: Column(
              //                       crossAxisAlignment:
              //                           CrossAxisAlignment.start,
              //                       children: [
              //                         Text(
              //                           event.name,
              //                           style: TextStyle(
              //                             fontWeight: FontWeight.bold,
              //                           ),
              //                         ),
              //                         SizedBox(height: 4),
              //                         Text(
              //                           "${event.certificate} | ${event.language}", // single language
              //                           style: TextStyle(
              //                             fontSize: 12,
              //                             color: Colors.grey[700],
              //                           ),
              //                         ),
              //                       ],
              //                     ),
              //                   ),
              //                 ],
              //               ),
              //             ),
              //           );
              //         },
              //       ),
              //     );
              //   },
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
