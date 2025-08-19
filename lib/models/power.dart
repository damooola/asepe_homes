class PowerData {
  final double power1;
  final double power2;
  final double power3;
  final DateTime createdAt;
  final String? id;

  PowerData({
    required this.power1,
    required this.power2,
    required this.power3,
    required this.createdAt,
    this.id,
  });

  factory PowerData.fromJson(Map<String, dynamic> json) {
    return PowerData(
      power1: (json['power1'] ?? 0).toDouble(),
      power2: (json['power2'] ?? 0).toDouble(),
      power3: (json['power3'] ?? 0).toDouble(),
      createdAt: DateTime.parse(json['createdAt']),
      id: json['id']?.toString(),
    );
  }
}
