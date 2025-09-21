// lib/screens/add_event_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/event.dart';

class AddEventScreen extends StatefulWidget {
  const AddEventScreen({super.key});

  @override
  State<AddEventScreen> createState() => _AddEventScreenState();
}

class _AddEventScreenState extends State<AddEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _imageController = TextEditingController();
  final _languageController = TextEditingController();
  final _durationController = TextEditingController();
  final _certificateController = TextEditingController();
  final _categoryController = TextEditingController();

  bool _isLoading = false;

  /// Save event to Firestore
  Future<void> _saveEvent() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final docRef = FirebaseFirestore.instance.collection('events').doc();

      final event = Event(
        id: docRef.id,
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        image: _imageController.text.trim(),
        language: _languageController.text.trim(),
        duration: _durationController.text.trim(),
        category: _categoryController.text
            .split(',') // comma-separated categories
            .map((e) => e.trim())
            .toList(),
        certificate: _certificateController.text.trim(),
      );

      await docRef.set(event.toMap());

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Event added successfully")),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Event")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: "Event Name"),
                validator: (val) => val!.isEmpty ? "Enter event name" : null,
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: "Description"),
                maxLines: 3,
              ),
              TextFormField(
                controller: _imageController,
                decoration: const InputDecoration(labelText: "Image URL"),
              ),
              TextFormField(
                controller: _languageController,
                decoration: const InputDecoration(labelText: "Language"),
              ),
              TextFormField(
                controller: _durationController,
                decoration: const InputDecoration(labelText: "Duration"),
              ),
              TextFormField(
                controller: _certificateController,
                decoration: const InputDecoration(labelText: "Certificate"),
              ),
              TextFormField(
                controller: _categoryController,
                decoration: const InputDecoration(
                  labelText: "Categories (comma separated)",
                  hintText: "e.g. Action, Thriller",
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isLoading ? null : _saveEvent,
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Save Event"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
