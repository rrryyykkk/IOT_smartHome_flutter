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

  @override
  void initState() {
    super.initState();
    _lampStatusStream = _firebaseService.getLampStatusStream();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream: _lampStatusStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final isOn = snapshot.data ?? false;

        return GestureDetector(
          onTap: () async {
            await _firebaseService.setLampStatus(!isOn); // ← toggle status
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
    );
  }
}
