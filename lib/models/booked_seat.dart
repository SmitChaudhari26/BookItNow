// lib/models/booked_seat.dart

class BookedSeat {
  final String bookingId; // Unique booking reference
  final String userId; // Reference to User
  final String showId; // Reference to Show
  final List<String> seatNumbers; // Multiple seats booked

  BookedSeat({
    required this.bookingId,
    required this.userId,
    required this.showId,
    required this.seatNumbers,
  });

  /// 🔹 Create from Firestore map
  factory BookedSeat.fromMap(String bookingId, Map<String, dynamic> map) {
    return BookedSeat(
      bookingId: bookingId,
      userId: map['userId'] as String,
      showId: map['showId'] as String,
      seatNumbers: List<String>.from(map['seatNumbers']),
    );
  }

  /// 🔹 Convert to Firestore map
  Map<String, dynamic> toMap() {
    return {'userId': userId, 'showId': showId, 'seatNumbers': seatNumbers};
  }
}
