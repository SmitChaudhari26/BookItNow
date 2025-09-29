// lib/screens/add_movie_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/movie.dart';

class AddMovieScreen extends StatefulWidget {
  @override
  _AddMovieScreenState createState() => _AddMovieScreenState();
}

class _AddMovieScreenState extends State<AddMovieScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _imageController = TextEditingController();
  final TextEditingController _languageController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _certificateController = TextEditingController();

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: Colors.blueAccent),
      filled: true,
      fillColor: Colors.grey.shade100,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.blueAccent, width: 2),
      ),
    );
  }

  Future<void> _saveMovie() async {
    if (_formKey.currentState!.validate()) {
      try {
        final docRef = FirebaseFirestore.instance.collection("movies").doc();

        final movie = Movie(
          id: docRef.id,
          name: _nameController.text.trim(),
          description: _descController.text.trim(),
          image: _imageController.text.trim(),
          language: _languageController.text
              .split(",")
              .map((e) => e.trim())
              .where((e) => e.isNotEmpty)
              .toList(),
          duration: _durationController.text.trim(),
          category: _categoryController.text
              .split(",")
              .map((e) => e.trim())
              .where((e) => e.isNotEmpty)
              .toList(),
          certificate: _certificateController.text.trim(),
        );

        await docRef.set(movie.toMap());

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("✅ Movie added successfully!")),
        );

        Navigator.pushReplacementNamed(context, '/home');
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("❌ Error: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Movie", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
        elevation: 6,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: _inputDecoration("Movie Name", Icons.movie),
                  validator: (v) => v!.isEmpty ? "Enter movie name" : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _descController,
                  decoration: _inputDecoration("Description", Icons.description),
                  validator: (v) => v!.isEmpty ? "Enter description" : null,
                  maxLines: 3,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _imageController,
                  decoration: _inputDecoration("Image URL", Icons.image),
                  validator: (v) => v!.isEmpty ? "Enter image URL" : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _languageController,
                  decoration: _inputDecoration("Languages (comma separated)", Icons.language),
                  validator: (v) => v!.isEmpty ? "Enter languages" : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _durationController,
                  decoration: _inputDecoration("Duration (e.g. 2h 30m)", Icons.access_time),
                  validator: (v) => v!.isEmpty ? "Enter duration" : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _categoryController,
                  decoration: _inputDecoration(
                      "Categories (comma separated, e.g. Action,Drama)", Icons.category),
                  validator: (v) => v!.isEmpty ? "Enter categories" : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _certificateController,
                  decoration: _inputDecoration("Certificate (e.g. U/A)", Icons.card_membership),
                  validator: (v) => v!.isEmpty ? "Enter certificate" : null,
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
                    onPressed: _saveMovie,
                    child: const Text(
                      "Save Movie",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
