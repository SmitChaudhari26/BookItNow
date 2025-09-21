// lib/main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';

// Screens
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/movies_screen.dart';
// import 'screens/events_screen.dart';
import 'screens/add_movie_screen.dart';
import 'screens/add_event_screen.dart';
import 'screens/add_event_show.dart';
import 'screens/add_theater_screen.dart';
import 'screens/add_movie_show.dart';
// import 'screens/movie_detail_screen.dart';
//import 'screens/event_detail_screen.dart';
//import 'screens/seat_selection_screen.dart';
import 'screens/movie_detail_screen.dart';

// Models
import 'models/movie.dart';
import 'models/event.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
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
        '/movies': (context) => MoviesScreen(),
        // '/events': (context) => EventsScreen(),
        '/addMovie': (context) => AddMovieScreen(),
        '/addEvent': (context) => AddEventScreen(),
        '/addTheater': (context) => AddTheaterScreen(),
        '/addShow': (context) => AddMovieShowScreen(),
        '/addEventShow': (context) => AddEventShowScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/movieDetail') {
          final movie = settings.arguments as Movie;
          return MaterialPageRoute(
            builder: (_) => MovieDetailScreen(movie: movie),
          );
          // } else if (settings.name == '/eventDetail') {
          //   final event = settings.arguments as Event;
          //   return MaterialPageRoute(
          //     builder: (_) => EventDetailScreen(event: event),
          //   );
        }
        // } else if (settings.name == '/seats') {
        //   // could be for movie or event show
        //   final args = settings.arguments as Map<String, dynamic>;
        //   return MaterialPageRoute(
        //     builder: (_) => SeatSelectionScreen(
        //       show: args['show'],
        //       selectedTime: args['selectedTime'],
        //     ),
        //   );
        // }
        return null;
      },
    );
  }
}
