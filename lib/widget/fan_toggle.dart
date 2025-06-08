import 'dart:async';
import 'package:flutter/material.dart';
import '../services/firebase_services.dart';

class FanToggle extends StatefulWidget {
  const FanToggle({super.key});

  @override
  State<FanToggle> createState() => _FanToggleState();
}

class _FanToggleState extends State<FanToggle> {
  final FirebaseService _service = FirebaseService();
  late Stream<bool> _fanStream;
  Timer? _scheduleTimer;

  @override
  void initState() {
    super.initState();
    _fanStream = _service.getFanStatusStream();

    // Cek schedule setiap 1 menit
    _scheduleTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      _service.evaluateAutoSchedule();
    });

    // Jalankan awal sekali
    _service.evaluateAutoSchedule();
  }

  @override
  void dispose() {
    _scheduleTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60,
      child: StreamBuilder<bool>(
        stream: _fanStream,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final isFanOn = snapshot.data!;

          return SwitchListTile(
            title: const Text("Fan (Dinamo)"),
            value: isFanOn,
            onChanged: (value) async {
              await _service.setFanStatus(value);
            },
            secondary: const Icon(Icons.toys),
          );
        },
      ),
    );
  }
}
