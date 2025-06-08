class PowerStats {
  final int timestamp;
  final String deviceName;
  final String deviceType;
  final double voltage;
  final double current;

  PowerStats({
    required this.timestamp,
    required this.deviceName,
    required this.deviceType,
    required this.voltage,
    required this.current,
  });

  factory PowerStats.fromMap(Map<String, dynamic> map) {
    return PowerStats(
      timestamp: map['timestamp'] ?? 0,
      deviceName: map['deviceName'] ?? '',
      deviceType: map['deviceType'] ?? '',
      voltage: (map['voltage'] ?? 0).toDouble(),
      current: (map['current'] ?? 0).toDouble(),
    );
  }
}
