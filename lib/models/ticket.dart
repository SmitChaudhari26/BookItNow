import 'package:cloud_firestore/cloud_firestore.dart';

class Ticket {
  final String id;
  final String userId; // ✅ Add this
  final String movieName;
  final String theaterName;
  final String cityName;
  final String showTime;
  final String seatSection;
  final List<int> seatNumbers;

  Ticket({
    required this.id,
    required this.userId, // ✅ Require userId
    required this.movieName,
    required this.theaterName,
    required this.cityName,
    required this.showTime,
    required this.seatSection,
    required this.seatNumbers,
  });

  String get qrData {
    return "TicketID:$id | User:$userId | Movie:$movieName | Theater:$theaterName | City:$cityName | ShowTime:$showTime | Section:$seatSection | Seats:${seatNumbers.join(",")}";
  }

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "userId": userId, // ✅ Save userId in Firestore
      "movieName": movieName,
      "theaterName": theaterName,
      "cityName": cityName,
      "showTime": showTime,
      "seatSection": seatSection,
      "seatNumbers": seatNumbers,
      "createdAt": FieldValue.serverTimestamp(),
    };
  }

  factory Ticket.fromMap(Map<String, dynamic> map) {
    return Ticket(
      id: map["id"],
      userId: map["userId"] ?? "", // ✅ Read userId
      movieName: map["movieName"],
      theaterName: map["theaterName"],
      cityName: map["cityName"],
      showTime: map["showTime"],
      seatSection: map["seatSection"],
      seatNumbers: List<int>.from(map["seatNumbers"] ?? []),
    );
  }
}
