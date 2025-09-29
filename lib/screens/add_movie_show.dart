// lib/screens/add_movie_show.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/show.dart';
import '../models/movie.dart';

class AddMovieShowScreen extends StatefulWidget {
  @override
  _AddMovieShowScreenState createState() => _AddMovieShowScreenState();
}

class _AddMovieShowScreenState extends State<AddMovieShowScreen> {
  final _formKey = GlobalKey<FormState>();
  final _showtimesController = TextEditingController();

  String? _selectedMovieId;
  String? _selectedTheaterId;
  String? _selectedLanguage;
  int? _selectedScreenNo;
  DateTime? _selectedDate;

  List<String> _availableLanguages = [];
  int _totalScreens = 0;

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: Colors.blueAccent),
      filled: true,
      fillColor: Colors.grey.shade100,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.blueAccent, width: 2),
      ),
    );
  }

  Future<List<Movie>> _fetchMovies() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('movies')
        .get();
    return snapshot.docs
        .map((doc) => Movie.fromMap(doc.id, doc.data()))
        .toList();
  }

  Future<List<Map<String, dynamic>>> _fetchTheaters() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('theaters')
        .get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      return {
        "id": doc.id,
        "name": data['name'] ?? "Unnamed Theater",
        "screens": data['totalScreens'] ?? 1,
      };
    }).toList();
  }

  Future<void> _addShow() async {
    if (_formKey.currentState!.validate() &&
        _selectedMovieId != null &&
        _selectedTheaterId != null &&
        _selectedLanguage != null &&
        _selectedScreenNo != null &&
        _selectedDate != null) {
      try {
        final docRef = FirebaseFirestore.instance
            .collection('movieShows')
            .doc();

        List<String> showtimes = _showtimesController.text
            .split(",")
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();

        Map<String, List<bool>> createSeatMap(int count) {
          return {for (var time in showtimes) time: List.filled(count, false)};
        }

        final show = Show(
          id: docRef.id,
          mediaItemId: _selectedMovieId!,
          theaterId: _selectedTheaterId!,
          screenNo: _selectedScreenNo!,
          languages: [_selectedLanguage!],
          showtimes: showtimes,
          date: _selectedDate!,
          executiveSeats: createSeatMap(40),
          clubSeats: createSeatMap(40),
          royalSeats: createSeatMap(30),
          reclinerSeats: createSeatMap(20),
        );

        await docRef.set(show.toMap());

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("✅ Movie Show added successfully")),
        );
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("❌ Error: $e")));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("⚠️ Please fill all required fields")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Add Movie Show",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
        elevation: 6,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Movie dropdown
              FutureBuilder<List<Movie>>(
                future: _fetchMovies(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData)
                    return Center(child: CircularProgressIndicator());
                  return DropdownButtonFormField<String>(
                    value: _selectedMovieId,
                    decoration: _inputDecoration("Select Movie", Icons.movie),
                    items: snapshot.data!
                        .map(
                          (item) => DropdownMenuItem<String>(
                            value: item.id,
                            child: Text(item.name),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedMovieId = value;
                        final movie = snapshot.data!.firstWhere(
                          (element) => element.id == value,
                        );
                        _availableLanguages = movie.language;
                        _selectedLanguage = null;
                      });
                    },
                    validator: (v) =>
                        v == null ? "Please select a Movie" : null,
                  );
                },
              ),
              const SizedBox(height: 12),

              // Language dropdown
              DropdownButtonFormField<String>(
                value: _selectedLanguage,
                decoration: _inputDecoration("Select Language", Icons.language),
                items: _availableLanguages
                    .map(
                      (lang) =>
                          DropdownMenuItem(value: lang, child: Text(lang)),
                    )
                    .toList(),
                onChanged: (val) => setState(() => _selectedLanguage = val),
                validator: (v) => v == null ? "Please select a language" : null,
              ),
              const SizedBox(height: 12),

              // Theater dropdown
              FutureBuilder<List<Map<String, dynamic>>>(
                future: _fetchTheaters(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData)
                    return Center(child: CircularProgressIndicator());
                  return DropdownButtonFormField<String>(
                    value: _selectedTheaterId,
                    decoration: _inputDecoration(
                      "Select Theater",
                      Icons.theaters,
                    ),
                    items: snapshot.data!
                        .map(
                          (item) => DropdownMenuItem<String>(
                            value: item['id'] as String,
                            child: Text(item['name'] as String),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedTheaterId = value;
                        final theater = snapshot.data!.firstWhere(
                          (element) => element['id'] == value,
                        );
                        _totalScreens = theater['screens'];
                        _selectedScreenNo = null;
                      });
                    },
                    validator: (v) =>
                        v == null ? "Please select a Theater" : null,
                  );
                },
              ),
              const SizedBox(height: 12),

              // Screen number dropdown
              DropdownButtonFormField<int>(
                value: _selectedScreenNo,
                decoration: _inputDecoration(
                  "Select Screen Number",
                  Icons.screen_share,
                ),
                items: List.generate(_totalScreens, (index) => index + 1)
                    .map(
                      (screen) => DropdownMenuItem<int>(
                        value: screen,
                        child: Text("Screen $screen"),
                      ),
                    )
                    .toList(),
                onChanged: (val) => setState(() => _selectedScreenNo = val),
                validator: (v) => v == null ? "Please select a screen" : null,
              ),
              const SizedBox(height: 12),

              // Date picker
              InkWell(
                onTap: () async {
                  final today = DateTime.now();
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: today,
                    firstDate: today,
                    lastDate: DateTime(today.year + 2),
                  );
                  if (picked != null) setState(() => _selectedDate = picked);
                },
                child: InputDecorator(
                  decoration: _inputDecoration(
                    "Select Show Date",
                    Icons.calendar_today,
                  ),
                  child: Text(
                    _selectedDate == null
                        ? "Choose date"
                        : "${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}",
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Showtimes
              TextFormField(
                controller: _showtimesController,
                decoration: _inputDecoration(
                  "Showtimes (comma separated)",
                  Icons.schedule,
                ),
                validator: (v) => v!.isEmpty ? "Enter showtimes" : null,
              ),
              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _addShow,
                  child: const Text(
                    "Add Movie Show",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
