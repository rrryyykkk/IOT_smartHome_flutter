class PowerStats {
  final double value;
  final int timestamp;

  PowerStats({required this.timestamp, required this.value});

  factory PowerStats.fromMap(Map<dynamic, dynamic> map) {
    return PowerStats(
      timestamp: map['timestamp'] ?? 0,
      value: (map['value'] ?? 0).toDouble(),
    );
  }
}
