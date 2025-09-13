import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/movie.dart';
import '../models/show.dart';
import 'showtime_detail_screen.dart';

class MovieDetailScreen extends StatefulWidget {
  final Movie movie;
  const MovieDetailScreen({required this.movie});

  @override
  State<MovieDetailScreen> createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen> {
  Map<String, Map<DateTime, List<Show>>> showsByTheater = {};
  Map<String, DateTime?> selectedDates = {}; // theater -> selected date
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _fetchShows();
  }

  Future<void> _fetchShows() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('movieShows')
        .where('mediaItemId', isEqualTo: widget.movie.id)
        .get();

    Map<String, Map<DateTime, List<Show>>> result = {};

    for (var doc in snapshot.docs) {
      final show = Show.fromMap(doc.id, doc.data());

      // Fetch theater name
      final theaterDoc = await FirebaseFirestore.instance
          .collection('theaters')
          .doc(show.theaterId)
          .get();
      final theaterName = theaterDoc.data()?['name'] ?? "Unknown Theater";

      result.putIfAbsent(theaterName, () => {});
      final dateOnly = DateTime(show.date.year, show.date.month, show.date.day);
      result[theaterName]!.putIfAbsent(dateOnly, () => []);
      result[theaterName]![dateOnly]!.add(show);
    }

    // Sort shows by time for each date
    for (var theater in result.keys) {
      final dates = result[theater]!;
      for (var date in dates.keys) {
        dates[date]!.sort(
          (a, b) => a.showtimes.first.compareTo(b.showtimes.first),
        );
      }
    }

    setState(() {
      showsByTheater = result;
      selectedDates = {
        for (var theater in showsByTheater.keys)
          theater: showsByTheater[theater]!.keys.first,
      };
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.movie.name)),
      body: loading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Movie poster/image
                  Container(
                    width: double.infinity,
                    height: 300,
                    decoration: BoxDecoration(
                      image: widget.movie.image.isNotEmpty
                          ? DecorationImage(
                              image: NetworkImage(widget.movie.image),
                              fit: BoxFit.cover,
                            )
                          : null,
                      color: Colors.grey[300],
                    ),
                    child: widget.movie.image.isEmpty
                        ? Icon(Icons.movie, size: 80, color: Colors.grey[700])
                        : null,
                  ),
                  SizedBox(height: 16),

                  // Movie info
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.movie.name,
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          "${widget.movie.certificate} | ${widget.movie.language.join(', ')} | ${widget.movie.duration} | ${widget.movie.category.join(', ')}",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                          ),
                        ),
                        SizedBox(height: 12),
                        Text(
                          widget.movie.description,
                          style: TextStyle(fontSize: 16),
                        ),
                        SizedBox(height: 24),
                        Text(
                          "Available Shows",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 12),

                        // Shows grouped by theater
                        ...showsByTheater.entries.map((theaterEntry) {
                          final theaterName = theaterEntry.key;
                          final datesMap = theaterEntry.value;
                          final selectedDate = selectedDates[theaterName]!;

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 16),
                              Text(
                                theaterName,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 8),

                              // Date selector
                              SizedBox(
                                height: 50,
                                child: ListView(
                                  scrollDirection: Axis.horizontal,
                                  children: datesMap.keys.map((date) {
                                    final isSelected = date == selectedDate;
                                    return GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          selectedDates[theaterName] = date;
                                        });
                                      },
                                      child: Container(
                                        width: 100,
                                        margin: EdgeInsets.only(right: 8),
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? Colors.red
                                              : Colors.white,
                                          border: Border.all(
                                            color: Colors.black54,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        alignment: Alignment.center,
                                        child: Text(
                                          "${date.day}/${date.month}/${date.year}",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: isSelected
                                                ? Colors.white
                                                : Colors.black,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                              SizedBox(height: 12),

                              // Showtimes for selected date
                              SizedBox(
                                height: 60,
                                child: ListView(
                                  scrollDirection: Axis.horizontal,
                                  children: datesMap[selectedDate]!.expand((
                                    show,
                                  ) {
                                    return show.showtimes.map((time) {
                                      return InkWell(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) =>
                                                  ShowtimeDetailScreen(
                                                    show: show,
                                                    selectedTime: time,
                                                  ),
                                            ),
                                          );
                                        },
                                        child: Container(
                                          width: 100,
                                          margin: EdgeInsets.only(right: 8),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            border: Border.all(
                                              color: Colors.black54,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          alignment: Alignment.center,
                                          child: Text(
                                            time,
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      );
                                    });
                                  }).toList(),
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
