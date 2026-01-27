class Reward {
  final int id;
  final String name;
  final String description;
  final int pointsRequired;
  final String? imageUrl;

  Reward({
    required this.id,
    required this.name,
    required this.description,
    required this.pointsRequired,
    this.imageUrl,
  });

  factory Reward.fromJson(Map<String, dynamic> json) {
    return Reward(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      pointsRequired: json['points_required'],
      imageUrl: json['image_url'],
    );
  }
}