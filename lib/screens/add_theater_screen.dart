// lib/screens/add_theater_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/theater.dart';

class AddTheaterScreen extends StatefulWidget {
  @override
  _AddTheaterScreenState createState() => _AddTheaterScreenState();
}

class _AddTheaterScreenState extends State<AddTheaterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _cityController = TextEditingController();
  final _theaterController = TextEditingController();
  final _screensController = TextEditingController();

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

  Future<void> _addTheater() async {
    if (_formKey.currentState!.validate()) {
      try {
        final docRef = FirebaseFirestore.instance.collection('theaters').doc();

        final theater = Theater(
          id: docRef.id,
          location: _cityController.text.trim(),
          name: _theaterController.text.trim(),
          totalScreens: int.parse(_screensController.text.trim()),
        );

        await docRef.set(theater.toMap());

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("✅ Theater added successfully")),
        );
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("❌ Error: $e")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Add Theater",
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
          child: Column(
            children: [
              TextFormField(
                controller: _cityController,
                decoration: _inputDecoration("City", Icons.location_city),
                validator: (v) => v!.isEmpty ? "Enter city" : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _theaterController,
                decoration: _inputDecoration(
                  "Theater / Place Name",
                  Icons.theaters,
                ),
                validator: (v) => v!.isEmpty ? "Enter theater name" : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _screensController,
                decoration: _inputDecoration(
                  "Total Screens",
                  Icons.screen_share,
                ),
                keyboardType: TextInputType.number,
                validator: (v) => v!.isEmpty ? "Enter total screens" : null,
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
                  onPressed: _addTheater,
                  child: const Text(
                    "Add Theater",
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
