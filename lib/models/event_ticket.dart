import 'package:cloud_firestore/cloud_firestore.dart';

class EventTicket {
  final String id;
  final String userId;
  final String eventId;
  final String eventName;
  final String venueId;
  final String venueName;
  final DateTime dateTime;
  final DateTime createdAt;
  final int ticketCount; // new field

  EventTicket({
    required this.id,
    required this.userId,
    required this.eventId,
    required this.eventName,
    required this.venueId,
    required this.venueName,
    required this.dateTime,
    required this.createdAt,
    required this.ticketCount, // initialize
  });

  factory EventTicket.fromMap(String id, Map<String, dynamic> data) {
    return EventTicket(
      id: id,
      userId: data['userId'] ?? '',
      eventId: data['eventId'] ?? '',
      eventName: data['eventName'] ?? '',
      venueId: data['venueId'] ?? '',
      venueName: data['venueName'] ?? '',
      dateTime: (data['dateTime'] as Timestamp).toDate(),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      ticketCount: data['ticketCount'] ?? 1, // default 1
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'eventId': eventId,
      'venueId': venueId,
      'venueName': venueName,
      'dateTime': dateTime,
      'createdAt': createdAt,
      'ticketCount': ticketCount, // include in map
    };
  }
}
