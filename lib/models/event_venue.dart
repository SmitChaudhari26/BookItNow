import 'package:cloud_firestore/cloud_firestore.dart';

class EventVenue {
  final String id; // Firestore document ID
  final String eventId; // Event/Movie/Concert/Play name
  final String venueName; // Venue name (place)
  final String venueLocation; // City
  final String language; // Single language
  final DateTime dateTime; // One showtime
  final int capacity; // Total seats available
  final int bookedCount; // How many tickets are already booked

  EventVenue({
    required this.id,
    required this.eventId,
    required this.venueName,
    required this.venueLocation,
    required this.language,
    required this.dateTime,
    required this.capacity,
    required this.bookedCount,
  });

  /// Factory method to create Event from Firestore map
  factory EventVenue.fromMap(String id, Map<String, dynamic> map) {
    return EventVenue(
      id: id,
      eventId: map['eventId'],
      venueName: map['venueName'],
      venueLocation: map['venueLocation'],
      language: map['language'],
      dateTime: (map['dateTime'] as Timestamp).toDate(),
      capacity: map['capacity'],
      bookedCount: map['bookedCount'] ?? 0,
    );
  }

  /// Convert Event to Firestore map
  Map<String, dynamic> toMap() {
    return {
      'eventId': eventId,
      'venueName': venueName,
      'venueLocation': venueLocation,
      'language': language,
      'dateTime': dateTime,
      'capacity': capacity,
      'bookedCount': bookedCount,
    };
  }

  /// 🔹 Create new Event with default 0 bookings
  static EventVenue createNew({
    required String id,
    required String eventId,
    required String venueName,
    required String venueLocation,
    required String language,
    required DateTime dateTime,
    required int capacity,
  }) {
    return EventVenue(
      id: id,
      eventId: eventId,
      venueName: venueName,
      venueLocation: venueLocation,
      language: language,
      dateTime: dateTime,
      capacity: capacity,
      bookedCount: 0,
    );
  }

  /// 🔹 Check if event is sold out
  bool get isSoldOut => bookedCount >= capacity;
}
