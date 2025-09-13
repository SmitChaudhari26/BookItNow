class AppUser {
  final String userId;
  final String email;
  final String password;

  AppUser({required this.userId, required this.email, required this.password});

  factory AppUser.fromMap(Map<String, dynamic> map, String id) {
    return AppUser(
      userId: id,
      email: map['email'] ?? '',
      password: map['password'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {'email': email, 'password': password};
  }
}
