import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import '../models/power_stats.dart';
import '../models/schedule.dart';
import '../models/history.dart';

class FirebaseService {
  final _db = FirebaseDatabase.instance;

  final _powerStatsRef = FirebaseDatabase.instance.ref(
    'powerStats/smart_lamp/devices_001/stats',
  );
  final _lampRef = FirebaseDatabase.instance.ref('devices/lamp');
  final _fanRef = FirebaseDatabase.instance.ref('devices/fan');
  final _scheduleRef = FirebaseDatabase.instance.ref('schedules');
  final _historyRef = FirebaseDatabase.instance.ref('history');

  // Lamp
  Stream<bool> getLampStatusStream() {
    return _lampRef.child('isOn').onValue.map((event) {
      final data = event.snapshot.value;
      return data == true;
    });
  }

  Future<void> setLampStatus(bool isOn) async {
    await _lampRef.update({'isOn': isOn});
    await addHistory('lamp', isOn);
  }

  // Fan
  Stream<bool> getFanStatusStream() {
    return _fanRef.child('isOn').onValue.map((event) {
      return event.snapshot.value == true;
    });
  }

  Future<void> setFanStatus(bool isOn) async {
    await _fanRef.update({'isOn': isOn});
    await addHistory('fan', isOn);
  }

  // Power Stats
  Stream<List<PowerStats>> getPowerStatsStream() {
    final ref = FirebaseDatabase.instance.ref('powerStats');
    return ref.onValue.map((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>? ?? {};

      return data.entries.map((entry) {
        final map = Map<String, dynamic>.from(entry.value);
        return PowerStats.fromMap(map);
      }).toList();
    });
  }

  // Schedules
  Future<List<ScheduleModel>> getSchedules() async {
    final snapshot = await _scheduleRef.get();
    final data = snapshot.value as Map<dynamic, dynamic>? ?? {};
    return data.entries.map((e) {
      return ScheduleModel.fromMap(e.value, e.key);
    }).toList();
  }

  Future<void> addSchedule(ScheduleModel schedule) async {
    final newRef = _scheduleRef.push();
    await newRef.set(schedule.copyWith(id: newRef.key!).toMap());
  }

  Future<void> updateSchedule(ScheduleModel schedule) async {
    await _scheduleRef.child(schedule.id).update(schedule.toMap());
  }

  Future<void> deleteSchedule(String id) async {
    await _scheduleRef.child(id).remove();
  }

  // History
  Future<void> addHistory(String device, bool isOn) async {
    final ref = _historyRef.push();
    await ref.set({
      'device': device,
      'status': isOn,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
  }

  Stream<List<HistoryItem>> getHistoryStream() {
    return _historyRef.onValue.map((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>? ?? {};
      return data.entries.map((e) {
        return HistoryItem.fromMap(e.value);
      }).toList()..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    });
  }

  Future<void> clearAllHistory() async {
    await _historyRef.remove();
  }

  // Auto Schedule Evaluator
  void evaluateAutoSchedule() async {
    final schedules = await getSchedules();
    final now = DateTime.now();
    final daysInEnglish = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    final currentDay = daysInEnglish[now.weekday - 1];

    for (var s in schedules) {
      if (!s.enabled || s.day != currentDay) continue;

      final nowMinutes = now.hour * 60 + now.minute;
      final onTime = _parseTimeToMinutes(s.onTime);
      final offTime = _parseTimeToMinutes(s.offTime);

      final shouldBeOn = nowMinutes >= onTime && nowMinutes < offTime;

      if (s.device == 'lamp') {
        final current = (await _lampRef.child('isOn').get()).value == true;
        if (current != shouldBeOn) await setLampStatus(shouldBeOn);
      } else if (s.device == 'fan') {
        final current = (await _fanRef.child('isOn').get()).value == true;
        if (current != shouldBeOn) await setFanStatus(shouldBeOn);
      }
    }
  }

  int _parseTimeToMinutes(String time) {
    final parts = time.split(':').map(int.parse).toList();
    return parts[0] * 60 + parts[1];
  }
}
