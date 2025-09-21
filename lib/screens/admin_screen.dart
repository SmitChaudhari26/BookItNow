// lib/screens/admin_screen.dart
import 'package:flutter/material.dart';

class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Admin Dashboard"), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 4,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 50, color: Colors.blue),
              SizedBox(height: 10),
              Text(
                title,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
