// lib/main.dart
import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/event_detail_screen.dart';
import 'screens/seat_selection_screen.dart';
import 'screens/my_tickets_screen.dart';
import 'models/event.dart';

void main() {
  runApp(BookItNowApp());
}

class BookItNowApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BookItNow',
      theme: ThemeData(primarySwatch: Colors.red),
      initialRoute: '/',
      routes: {
        '/': (context) => LoginScreen(),
        '/home': (context) => HomeScreen(),
        '/tickets': (context) => MyTicketsScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/event') {
          final event = settings.arguments as Event;
          return MaterialPageRoute(
            builder: (_) => EventDetailScreen(event: event),
          );
        } else if (settings.name == '/seats') {
          final event = settings.arguments as Event;
          return MaterialPageRoute(
            builder: (_) => SeatSelectionScreen(event: event),
          );
        }
        return null;
      },
    );
  }
}
