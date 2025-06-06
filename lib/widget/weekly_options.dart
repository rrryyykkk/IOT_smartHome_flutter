import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class WeeklyScheduleWidget extends StatefulWidget {
  const WeeklyScheduleWidget({super.key});

  @override
  State<WeeklyScheduleWidget> createState() => _WeeklyScheduleWidgetState();
}

class _WeeklyScheduleWidgetState extends State<WeeklyScheduleWidget> {
  final _days = [
    "Monday",
    "Tuesday",
    "Wednesday",
    "Thursday",
    "Friday",
    "Saturday",
    "Sunday",
  ];
  Map<String, Map<String, TimeOfDay>> schedule = {};

  void _pickTime(String day, String type) async {
    final result = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 18, minute: 0),
    );
    if (result != null) {
      setState(() {
        schedule[day] ??= {};
        schedule[day]![type] = result;
      });
      await FirebaseFirestore.instance
          .collection('weekly_schedule')
          .doc(day)
          .set({
            type: '${result.hour}:${result.minute}',
          }, SetOptions(merge: true));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: _days.map((day) {
        final on = schedule[day]?["on"];
        final off = schedule[day]?["off"];
        return ListTile(
          title: Text(day),
          subtitle: Text(
            "On: ${on?.format(context) ?? '--'}  Off: ${off?.format(context) ?? '--'}",
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: () => _pickTime(day, 'on'),
                icon: const Icon(Icons.play_arrow),
              ),
              IconButton(
                onPressed: () => _pickTime(day, 'off'),
                icon: const Icon(Icons.stop),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
