import 'package:flutter/material.dart';
import '../services/firebase_services.dart';
import '../models/schedule.dart';

class WeeklyScheduleWidget extends StatefulWidget {
  final FirebaseService firebaseService;

  const WeeklyScheduleWidget({super.key, required this.firebaseService});

  @override
  State<WeeklyScheduleWidget> createState() => _WeeklyScheduleWidgetState();
}

class _WeeklyScheduleWidgetState extends State<WeeklyScheduleWidget> {
  final _formKey = GlobalKey<FormState>();

  final List<String> days = const [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];
  final List<String> devices = const ['lamp', 'fan'];

  String? selectedDay;
  String? selectedDevice;
  TimeOfDay? onTime;
  TimeOfDay? offTime;

  List<ScheduleModel> schedules = [];
  bool _isLoading = true;

  final Color primaryColor = Colors.teal;
  final double borderRadius = 16;

  @override
  void initState() {
    super.initState();
    _fetchSchedules();
  }

  Future<void> _fetchSchedules() async {
    setState(() => _isLoading = true);
    try {
      final data = await widget.firebaseService.getSchedules();
      setState(() => schedules = data);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed to fetch schedules: $e")));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _pickTime(bool isOnTime) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 7, minute: 0),
    );
    if (picked != null) {
      setState(() {
        if (isOnTime)
          onTime = picked;
        else
          offTime = picked;
      });
    }
  }

  Future<void> _saveSchedule() async {
    if (_formKey.currentState!.validate()) {
      if (onTime == null || offTime == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please select ON and OFF time")),
        );
        return;
      }

      if (onTime == offTime) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("ON and OFF time cannot be the same")),
        );
        return;
      }

      final schedule = ScheduleModel(
        id: '',
        day: selectedDay!,
        device: selectedDevice!,
        onTime: onTime!.format(context),
        offTime: offTime!.format(context),
        enabled: true,
      );

      try {
        await widget.firebaseService.addSchedule(schedule);
        await _fetchSchedules();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Schedule saved successfully")),
        );
        setState(() {
          selectedDay = null;
          selectedDevice = null;
          onTime = null;
          offTime = null;
        });
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Failed to save schedule: $e")));
      }
    }
  }

  Future<void> _toggleScheduleStatus(ScheduleModel schedule) async {
    final updated = schedule.copyWith(enabled: !schedule.enabled);
    try {
      await widget.firebaseService.updateSchedule(updated);
      await _fetchSchedules();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed to update schedule: $e")));
    }
  }

  Future<void> _deleteSchedule(String id) async {
    try {
      await widget.firebaseService.deleteSchedule(id);
      await _fetchSchedules();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Schedule deleted successfully")),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed to delete schedule: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Add Schedule",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildForm(),
          const SizedBox(height: 32),
          const Divider(),
          const SizedBox(height: 12),
          const Text(
            "Schedule List",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else if (schedules.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: Center(
                child: Text(
                  "No schedules saved yet",
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: schedules.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final s = schedules[index];
                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(borderRadius),
                  ),
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: primaryColor.withOpacity(0.1),
                              child: Icon(
                                s.device == 'lamp'
                                    ? Icons.lightbulb
                                    : Icons.toys_outlined,
                                color: primaryColor,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "${s.day} - ${s.device.toUpperCase()}",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    "ON: ${s.onTime} | OFF: ${s.offTime}",
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Text("Aktive: "),
                                const SizedBox(width: 6),
                                Switch(
                                  value: s.enabled,
                                  onChanged: (_) => _toggleScheduleStatus(s),
                                  activeColor: primaryColor,
                                ),
                              ],
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.delete_outline,
                                color: Colors.redAccent,
                              ),
                              onPressed: () => _deleteSchedule(s.id),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          DropdownButtonFormField<String>(
            value: selectedDay,
            decoration: const InputDecoration(
              labelText: 'Select Day',
              border: OutlineInputBorder(),
            ),
            items: days
                .map((day) => DropdownMenuItem(value: day, child: Text(day)))
                .toList(),
            onChanged: (value) => setState(() => selectedDay = value),
            validator: (value) => value == null ? 'Please select a day' : null,
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: selectedDevice,
            decoration: const InputDecoration(
              labelText: 'Select Device',
              border: OutlineInputBorder(),
            ),
            items: devices.map((device) {
              return DropdownMenuItem(
                value: device,
                child: Row(
                  children: [
                    Icon(
                      device == 'lamp' ? Icons.lightbulb : Icons.toys,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(device.toUpperCase()),
                  ],
                ),
              );
            }).toList(),
            onChanged: (value) => setState(() => selectedDevice = value),
            validator: (value) =>
                value == null ? 'Please select a device' : null,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.timer),
                  label: Text(
                    onTime == null
                        ? 'Select ON Time'
                        : 'ON: ${onTime!.format(context)}',
                  ),
                  onPressed: () => _pickTime(true),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.timer_off),
                  label: Text(
                    offTime == null
                        ? 'Select OFF Time'
                        : 'OFF: ${offTime!.format(context)}',
                  ),
                  onPressed: () => _pickTime(false),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.save_alt),
              label: const Text("Save Schedule"),
              onPressed: _saveSchedule,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                textStyle: const TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
