// lib/models/show.dart
import 'package:cloud_firestore/cloud_firestore.dart'; // add this at the top

class Show {
  final String id;
  final String mediaItemId;
  final String theaterId;
  final List<String> showtimes;
  final List<String> languages;
  final int screenNo;
  final DateTime date;

  // Seat arrangement per showtime
  final Map<String, List<bool>> executiveSeats;
  final Map<String, List<bool>> clubSeats;
  final Map<String, List<bool>> royalSeats;
  final Map<String, List<bool>> reclinerSeats;

  Show({
    required this.id,
    required this.mediaItemId,
    required this.theaterId,
    required this.showtimes,
    required this.languages,
    required this.screenNo,
    required this.date,
    required this.executiveSeats,
    required this.clubSeats,
    required this.royalSeats,
    required this.reclinerSeats,
  });

  /// 🔹 Factory method to create Show from Firestore map
  factory Show.fromMap(String id, Map<String, dynamic> map) {
    return Show(
      id: id,
      mediaItemId: map['mediaItemId'],
      theaterId: map['theaterId'],
      showtimes: List<String>.from(map['showtimes']),
      languages: List<String>.from(map['languages']),
      screenNo: map['screenNo'],
      date: (map['date'] as Timestamp).toDate(),
      executiveSeats: Map<String, List<bool>>.from(
        (map['executiveSeats'] as Map).map(
          (k, v) => MapEntry(k as String, List<bool>.from(v)),
        ),
      ),
      clubSeats: Map<String, List<bool>>.from(
        (map['clubSeats'] as Map).map(
          (k, v) => MapEntry(k as String, List<bool>.from(v)),
        ),
      ),
      royalSeats: Map<String, List<bool>>.from(
        (map['royalSeats'] as Map).map(
          (k, v) => MapEntry(k as String, List<bool>.from(v)),
        ),
      ),
      reclinerSeats: Map<String, List<bool>>.from(
        (map['reclinerSeats'] as Map).map(
          (k, v) => MapEntry(k as String, List<bool>.from(v)),
        ),
      ),
    );
  }

  /// 🔹 Convert Show to Firestore map
  Map<String, dynamic> toMap() {
    return {
      'mediaItemId': mediaItemId,
      'theaterId': theaterId,
      'showtimes': showtimes,
      'languages': languages,
      'screenNo': screenNo,
      'date': date,
      'executiveSeats': executiveSeats,
      'clubSeats': clubSeats,
      'royalSeats': royalSeats,
      'reclinerSeats': reclinerSeats,
    };
  }

  /// 🔹 Create default seat layout per showtime
  static Show createNew({
    required String id,
    required String mediaItemId,
    required String theaterId,
    required List<String> showtimes,
    required List<String> languages,
    required int screenNo,
    required DateTime date,
  }) {
    Map<String, List<bool>> createSeatMap(int count) {
      return {
        for (var time in showtimes) time: List<bool>.filled(count, false),
      };
    }

    return Show(
      id: id,
      mediaItemId: mediaItemId,
      theaterId: theaterId,
      showtimes: showtimes,
      languages: languages,
      screenNo: screenNo,
      date: date,
      executiveSeats: createSeatMap(40),
      clubSeats: createSeatMap(40),
      royalSeats: createSeatMap(30),
      reclinerSeats: createSeatMap(20),
    );
  }
}
