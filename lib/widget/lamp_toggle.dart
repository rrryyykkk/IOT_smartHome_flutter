import 'dart:async';
import 'package:flutter/material.dart';
import '../services/firebase_services.dart';

class LampToggle extends StatefulWidget {
  const LampToggle({super.key});

  @override
  State<LampToggle> createState() => _LampToggleState();
}

class _LampToggleState extends State<LampToggle> {
  final FirebaseService _firebaseService = FirebaseService();
  late Stream<bool> _lampStatusStream;
  Timer? _scheduleTimer;

  @override
  void initState() {
    super.initState();
    _lampStatusStream = _firebaseService.getLampStatusStream();

    // Evaluasi setiap 1 menit
    _scheduleTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      _firebaseService.evaluateAutoSchedule();
    });

    // Jalankan awal sekali
    _firebaseService.evaluateAutoSchedule();
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
        stream: _lampStatusStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final isOn = snapshot.data ?? false;

          return GestureDetector(
            onTap: () async {
              await _firebaseService.setLampStatus(!isOn);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isOn ? const Color(0xFF2F80ED) : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isOn ? Icons.lightbulb : Icons.lightbulb_outline,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    isOn ? "Lamp On" : "Lamp Off",
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
