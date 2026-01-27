class Redemption {
  final int id;
  final int rewardId;
  final String rewardName;
  final int pointsUsed;
  final DateTime createdAt;

  Redemption({
    required this.id,
    required this.rewardId,
    required this.rewardName,
    required this.pointsUsed,
    required this.createdAt,
  });

  factory Redemption.fromJson(Map<String, dynamic> json) {
    return Redemption(
      id: json['id'],
      rewardId: json['reward_id'],
      rewardName: json['reward']['name'] ?? 'Unknown',
      pointsUsed: json['points_used'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  get status => null;
}