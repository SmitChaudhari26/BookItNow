// lib/models/theater.dart

class Theater {
  final String id;
  final String location;     // City
  final String name;         // Theater or Place name
  final int totalScreens;    // Number of screens/halls

  Theater({
    required this.id,
    required this.location,
    required this.name,
    required this.totalScreens,
  });

  /// Factory method to create Theater object from Firestore map
  factory Theater.fromMap(String id, Map<String, dynamic> map) {
    return Theater(
      id: id,
      location: map['location'] as String,
      name: map['name'] as String,
      totalScreens: map['totalScreens'] as int,
    );
  }

  /// Convert Theater object to Firestore map
  Map<String, dynamic> toMap() {
    return {
      'location': location,
      'name': name,
      'totalScreens': totalScreens,
    };
  }

  /// 🔹 Generate a unique key combining location + name
  String get uniqueKey => "${location.toLowerCase()}_${name.toLowerCase()}";
}
