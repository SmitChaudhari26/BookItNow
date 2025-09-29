// lib/screens/add_event_show.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/event.dart';
import '../models/event_venue.dart';

class AddEventShowScreen extends StatefulWidget {
  const AddEventShowScreen({super.key});

  @override
  State<AddEventShowScreen> createState() => _AddEventShowScreenState();
}

class _AddEventShowScreenState extends State<AddEventShowScreen> {
  final _formKey = GlobalKey<FormState>();

  String? _selectedEventId;
  String? _selectedLanguage;
  final _venueNameController = TextEditingController();
  final _venueLocationController = TextEditingController();
  final _capacityController = TextEditingController();

  DateTime? _selectedDateTime;
  List<String> _availableLanguages = [];

  Future<List<Event>> _fetchEvents() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('events')
        .get();
    return snapshot.docs
        .map((doc) => Event.fromMap(doc.id, doc.data()))
        .toList();
  }

  Future<void> _addEventShow() async {
    if (!_formKey.currentState!.validate() ||
        _selectedEventId == null ||
        _selectedLanguage == null ||
        _selectedDateTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("⚠️ Please fill all required fields")),
      );
      return;
    }

    try {
      final docRef = FirebaseFirestore.instance.collection('eventVenues').doc();

      final venue = EventVenue(
        id: docRef.id,
        eventId: _selectedEventId!,
        venueName: _venueNameController.text.trim(),
        venueLocation: _venueLocationController.text.trim(),
        language: _selectedLanguage!,
        dateTime: _selectedDateTime!,
        capacity: int.parse(_capacityController.text.trim()),
        bookedCount: 0,
      );

      await docRef.set(venue.toMap());

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("✅ Event Venue added successfully")),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("❌ Error: $e")));
    }
  }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Add Event Venue",
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
              /// Event Dropdown
              FutureBuilder<List<Event>>(
                future: _fetchEvents(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  return DropdownButtonFormField<String>(
                    value: _selectedEventId,
                    decoration: _inputDecoration("Select Event", Icons.event),
                    items: snapshot.data!
                        .map(
                          (event) => DropdownMenuItem<String>(
                            value: event.id,
                            child: Text(event.name),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedEventId = value;
                        final event = snapshot.data!.firstWhere(
                          (e) => e.id == value,
                        );
                        _availableLanguages = [event.language];
                        _selectedLanguage = null;
                      });
                    },
                    validator: (v) =>
                        v == null ? "Please select an event" : null,
                  );
                },
              ),
              const SizedBox(height: 12),

              /// Language Dropdown
              DropdownButtonFormField<String>(
                value: _selectedLanguage,
                decoration: _inputDecoration("Language", Icons.language),
                items: _availableLanguages
                    .map(
                      (lang) =>
                          DropdownMenuItem(value: lang, child: Text(lang)),
                    )
                    .toList(),
                onChanged: (val) => setState(() => _selectedLanguage = val),
                validator: (v) => v == null ? "Please select language" : null,
              ),
              const SizedBox(height: 12),

              /// Venue name
              TextFormField(
                controller: _venueNameController,
                decoration: _inputDecoration("Venue Name", Icons.location_city),
                validator: (v) => v!.isEmpty ? "Enter venue name" : null,
              ),
              const SizedBox(height: 12),

              /// Venue city/location
              TextFormField(
                controller: _venueLocationController,
                decoration: _inputDecoration("City / Location", Icons.place),
                validator: (v) => v!.isEmpty ? "Enter venue location" : null,
              ),
              const SizedBox(height: 12),

              /// Capacity
              TextFormField(
                controller: _capacityController,
                decoration: _inputDecoration(
                  "Capacity (Total Seats)",
                  Icons.event_seat,
                ),
                keyboardType: TextInputType.number,
                validator: (v) => v!.isEmpty ? "Enter total capacity" : null,
              ),
              const SizedBox(height: 12),

              /// Date & Time picker
              InkWell(
                onTap: () async {
                  final today = DateTime.now();
                  final pickedDate = await showDatePicker(
                    context: context,
                    initialDate: today,
                    firstDate: today,
                    lastDate: DateTime(today.year + 2),
                  );
                  if (pickedDate != null) {
                    final pickedTime = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );
                    if (pickedTime != null) {
                      setState(() {
                        _selectedDateTime = DateTime(
                          pickedDate.year,
                          pickedDate.month,
                          pickedDate.day,
                          pickedTime.hour,
                          pickedTime.minute,
                        );
                      });
                    }
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade400),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Icon(Icons.calendar_today, color: Colors.blueAccent),
                      Text(
                        _selectedDateTime == null
                            ? "Choose date & time"
                            : "${_selectedDateTime!.day}/${_selectedDateTime!.month}/${_selectedDateTime!.year} ${_selectedDateTime!.hour}:${_selectedDateTime!.minute.toString().padLeft(2, '0')}",
                      ),
                    ],
                  ),
                ),
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
                  onPressed: _addEventShow,
                  child: const Text(
                    "Add Event Venue",
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
