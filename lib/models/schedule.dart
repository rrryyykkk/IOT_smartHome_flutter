class Schedule {
  final String id;
  final String day;
  final String time;
  final bool enabled;

  Schedule({
    required this.id,
    required this.day,
    required this.time,
    required this.enabled,
  });

  factory Schedule.fromMap(Map<dynamic, dynamic> map) {
    return Schedule(
      id: map['id'],
      day: map['day'],
      time: map['time'],
      enabled: map['enabled'],
    );
  }

  Map<String, dynamic> toMap() {
    return {'id': id, 'day': day, 'time': time, 'enabled': enabled};
  }
}
