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

  // ─── Lamp ────────────────────────────────────────────────

  Stream<bool> getLampStatusStream() {
    return _lampRef.child('isOn').onValue.map((event) {
      final data = event.snapshot.value;
      print('Lamp stream snapshot: $data');
      return data == true;
    });
  }

  Future<void> setLampStatus(bool isOn) async {
    print('Lamp status updated: $isOn');
    await _lampRef.update({'isOn': isOn});
    await addHistory('lamp', isOn);
  }

  // ─── Fan (Dynamo) ────────────────────────────────────────

  Stream<bool> getFanStatusStream() {
    return _fanRef.child('isOn').onValue.map((event) {
      return event.snapshot.value == true;
    });
  }

  Future<bool> getFanStatus() async {
    final snapshot = await _fanRef.child('isOn').get();
    return snapshot.value == true;
  }

  Future<void> setFanStatus(bool isOn) async {
    await _fanRef.update({'isOn': isOn});
    await addHistory('fan', isOn);
  }

  // ─── Power Stats ─────────────────────────────────────────

  Stream<List<PowerStats>> getPowerStatsStream() {
    return _powerStatsRef.onValue.map((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>? ?? {};
      final stats = data.entries.map((e) {
        return PowerStats.fromMap(e.value);
      }).toList();
      stats.sort((a, b) => a.timestamp.compareTo(b.timestamp));
      return stats;
    });
  }

  Future<void> addDummyStat() async {
    final ref = _powerStatsRef.push();
    final value = double.parse(
      (1 + (3 * (0.5 - (DateTime.now().second % 10) / 10))).toStringAsFixed(2),
    );
    await ref.set({
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'value': value,
    });
  }

  // ─── Schedule ─────────────────────────────────────────────

  Stream<List<Schedule>> getWeeklySchedule() {
    return _scheduleRef.onValue.map((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>? ?? {};
      return data.entries.map((e) {
        return Schedule.fromMap(e.value);
      }).toList();
    });
  }

  Future<void> setSchedule(Schedule schedule) async {
    await _scheduleRef.child(schedule.id).set(schedule.toMap());
  }

  // ─── History (Lamp & Fan) ────────────────────────────────

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
}
