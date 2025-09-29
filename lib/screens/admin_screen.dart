// lib/screens/admin_screen.dart
import 'package:flutter/material.dart';

class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Admin Dashboard",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
        elevation: 6,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            _adminTile(
              context,
              title: "Add Movie",
              icon: Icons.movie,
              route: "/addMovie",
            ),
            _adminTile(
              context,
              title: "Add Event",
              icon: Icons.event,
              route: "/addEvent",
            ),
            _adminTile(
              context,
              title: "Add Theater",
              icon: Icons.theaters,
              route: "/addTheater",
            ),
            _adminTile(
              context,
              title: "Add Movie Show",
              icon: Icons.slideshow,
              route: "/addShow",
            ),
            _adminTile(
              context,
              title: "Add Event Show",
              icon: Icons.event_seat,
              route: "/addEventShow",
            ),
          ],
        ),
      ),
    );
  }

  Widget _adminTile(
    BuildContext context, {
    required String title,
    required IconData icon,
    required String route,
  }) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, route),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 8,
        color: Colors.blue.shade50,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 60, color: Colors.blueAccent),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
