class User {
  final int id;
  final String name;
  final String email;
  final String role;
  final int points; // Tambahkan field points

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.points,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      role: json['role'],
      points: json['points'] ?? 0, // Ambil dari response
    );
  }
}