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

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("✅ Theater added successfully")));
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
      appBar: AppBar(title: Text("Add Theater")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _cityController,
                decoration: InputDecoration(labelText: "City"),
                validator: (v) => v!.isEmpty ? "Enter city" : null,
              ),
              TextFormField(
                controller: _theaterController,
                decoration: InputDecoration(labelText: "Theater / Place Name"),
                validator: (v) => v!.isEmpty ? "Enter theater name" : null,
              ),
              TextFormField(
                controller: _screensController,
                decoration: InputDecoration(labelText: "Total Screens"),
                keyboardType: TextInputType.number,
                validator: (v) => v!.isEmpty ? "Enter total screens" : null,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _addTheater,
                child: Text("Add Theater"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
