class Invoice {
  final int id;
  final double totalAmount;
  final int pointEarned;
  final String status;
  final String? fileUrl;
  final String salesCode;
  final DateTime createdAt;

  Invoice({
    required this.id,
    required this.totalAmount,
    required this.pointEarned,
    required this.status,
    this.fileUrl,
    required this.salesCode,
    required this.createdAt,
  });

  factory Invoice.fromJson(Map<String, dynamic> json) {
    return Invoice(
      id: json['id'],
      totalAmount: double.parse(json['total_amount'].toString()),
      pointEarned: json['points_earned'] ?? 0,
      status: json['status'],
      fileUrl: json['file_url'],
      salesCode: json['sales_code'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
