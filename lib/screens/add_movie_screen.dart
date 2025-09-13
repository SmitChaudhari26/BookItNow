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
              .toList(), // List<String>
          duration: _durationController.text.trim(),
          category: _categoryController.text
              .split(",")
              .map((e) => e.trim())
              .where((e) => e.isNotEmpty)
              .toList(), // List<String>
          certificate: _certificateController.text.trim(),
        );

        await docRef.set(movie.toMap());

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("✅ Movie added successfully!")));

        Navigator.pushReplacementNamed(context, '/home');
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
      appBar: AppBar(title: Text("Add Movie")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(labelText: "Movie Name"),
                  validator: (v) => v!.isEmpty ? "Enter movie name" : null,
                ),
                TextFormField(
                  controller: _descController,
                  decoration: InputDecoration(labelText: "Description"),
                  validator: (v) => v!.isEmpty ? "Enter description" : null,
                  maxLines: 3,
                ),
                TextFormField(
                  controller: _imageController,
                  decoration: InputDecoration(labelText: "Image URL"),
                  validator: (v) => v!.isEmpty ? "Enter image URL" : null,
                ),
                TextFormField(
                  controller: _languageController,
                  decoration: InputDecoration(
                    labelText: "Languages (comma separated)",
                  ),
                  validator: (v) => v!.isEmpty ? "Enter languages" : null,
                ),
                TextFormField(
                  controller: _durationController,
                  decoration: InputDecoration(
                    labelText: "Duration (e.g. 2h 30m)",
                  ),
                  validator: (v) => v!.isEmpty ? "Enter duration" : null,
                ),
                TextFormField(
                  controller: _categoryController,
                  decoration: InputDecoration(
                    labelText:
                        "Categories (comma separated, e.g. Action,Drama)",
                  ),
                  validator: (v) => v!.isEmpty ? "Enter categories" : null,
                ),
                TextFormField(
                  controller: _certificateController,
                  decoration: InputDecoration(
                    labelText: "Certificate (e.g. U/A)",
                  ),
                  validator: (v) => v!.isEmpty ? "Enter certificate" : null,
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _saveMovie,
                  child: Text("Save Movie"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
