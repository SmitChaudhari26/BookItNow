// lib/models/movie.dart

class Movie {
  final String id;
  final String name;
  final String description;
  final String image;
  final List<String> language; // multiple possible
  final String duration;
  final List<String> category;
  final String certificate; // U/A, A, etc.

  Movie({
    required this.id,
    required this.name,
    required this.description,
    required this.image,
    required this.language,
    required this.duration,
    required this.category,
    required this.certificate,
  });

  factory Movie.fromMap(String id, Map<String, dynamic> map) {
    return Movie(
      id: id,
      name: map['name'] as String,
      description: map['description'] as String,
      image: map['image'] as String,
      language: List<String>.from(map['language'] ?? []),
      duration: map['duration'] as String,
      category: List<String>.from(map['category'] ?? []),
      certificate: map['certificate'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'image': image,
      'language': language,
      'duration': duration,
      'category': category,
      'certificate': certificate,
    };
  }
}
