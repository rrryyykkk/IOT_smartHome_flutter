class ScheduleModel {
  final String id;
  final String day;
  final String device;
  final String onTime;
  final String offTime;
  final bool enabled;

  ScheduleModel({
    required this.id,
    required this.day,
    required this.device,
    required this.onTime,
    required this.offTime,
    required this.enabled,
  });

  factory ScheduleModel.fromMap(Map<dynamic, dynamic> map, String id) {
    return ScheduleModel(
      id: id,
      day: map['day'],
      device: map['device'],
      onTime: map['onTime'],
      offTime: map['offTime'],
      enabled: map['enabled'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'day': day,
      'device': device,
      'onTime': onTime,
      'offTime': offTime,
      'enabled': enabled,
    };
  }

  ScheduleModel copyWith({
    String? id,
    String? day,
    String? device,
    String? onTime,
    String? offTime,
    bool? enabled,
  }) {
    return ScheduleModel(
      id: id ?? this.id,
      day: day ?? this.day,
      device: device ?? this.device,
      onTime: onTime ?? this.onTime,
      offTime: offTime ?? this.offTime,
      enabled: enabled ?? this.enabled,
    );
  }
}
