class HistoryItem {
  final String device;
  final bool status;
  final int timestamp;

  HistoryItem({
    required this.device,
    required this.status,
    required this.timestamp,
  });

  factory HistoryItem.fromMap(Map<dynamic, dynamic> map) {
    return HistoryItem(
      device: map['device'] ?? '',
      status: map['status'] ?? false,
      timestamp: map['timestamp'] ?? 0,
    );
  }
}
