import 'package:flutter/material.dart';
import '../services/firebase_services.dart';

class FanToggle extends StatelessWidget {
  const FanToggle({super.key});

  @override
  Widget build(BuildContext context) {
    final fanStream = FirebaseService().getFanStatusStream();

    return StreamBuilder<bool>(
      stream: fanStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final isFanOn = snapshot.data!;

        return SwitchListTile(
          title: const Text("Fan (Dinamo)"),
          value: isFanOn,
          onChanged: (value) async {
            await FirebaseService().setFanStatus(value);
          },
          secondary: const Icon(Icons.toys),
        );
      },
    );
  }
}
