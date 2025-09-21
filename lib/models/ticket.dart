import 'package:cloud_firestore/cloud_firestore.dart';

class Ticket {
  final String id;
  final String userId;
  final String movieName;
  final String theaterName;
  final String cityName;
  final String showTime; // string like "7:30 PM"
  final DateTime dateTime; // ✅ New field for full date & time
  final String seatSection;
  final List<int> seatNumbers;

  Ticket({
    required this.id,
    required this.userId,
    required this.movieName,
    required this.theaterName,
    required this.cityName,
    required this.showTime,
    required this.dateTime, // ✅ require in constructor
    required this.seatSection,
    required this.seatNumbers,
  });

  String get qrData {
    return "TicketID:$id | User:$userId | Movie:$movieName | Theater:$theaterName | City:$cityName | ShowTime:$showTime | Date:${dateTime.toIso8601String()} | Section:$seatSection | Seats:${seatNumbers.join(",")}";
  }

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "userId": userId,
      "movieName": movieName,
      "theaterName": theaterName,
      "cityName": cityName,
      "showTime": showTime,
      "dateTime": dateTime, // ✅ Save in Firestore
      "seatSection": seatSection,
      "seatNumbers": seatNumbers,
      "createdAt": FieldValue.serverTimestamp(),
    };
  }

  factory Ticket.fromMap(Map<String, dynamic> map) {
    return Ticket(
      id: map["id"],
      userId: map["userId"] ?? "",
      movieName: map["movieName"],
      theaterName: map["theaterName"],
      cityName: map["cityName"],
      showTime: map["showTime"],
      dateTime: (map["dateTime"] as Timestamp)
          .toDate(), // ✅ parse Firestore timestamp
      seatSection: map["seatSection"],
      seatNumbers: List<int>.from(map["seatNumbers"] ?? []),
    );
  }
}
