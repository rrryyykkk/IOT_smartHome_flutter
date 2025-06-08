import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/history.dart';
import '../services/firebase_services.dart';

class DeviceHistoryList extends StatefulWidget {
  const DeviceHistoryList({super.key});

  @override
  State<DeviceHistoryList> createState() => _DeviceHistoryListState();
}

class _DeviceHistoryListState extends State<DeviceHistoryList> {
  final FirebaseService _firebaseService = FirebaseService();

  String selectedDevice = 'lamp';
  String selectedStatus = 'all';
  DateTime? selectedDate;

  void _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2023),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() => selectedDate = picked);
    }
  }

  void _clearFilters() {
    setState(() {
      selectedDate = null;
      selectedStatus = 'all';
      selectedDevice = 'lamp';
    });
  }

  void _clearHistory() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Confirm Delete"),
        content: const Text("Are you sure you want to clear all history?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Clear"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _firebaseService.clearAllHistory();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('History cleared successfully')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Filter Section
        Card(
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  DropdownButton<String>(
                    value: selectedDevice,
                    borderRadius: BorderRadius.circular(10),
                    items: const [
                      DropdownMenuItem(value: 'lamp', child: Text('Lamp')),
                      DropdownMenuItem(value: 'fan', child: Text('Fan')),
                    ],
                    onChanged: (val) => setState(() => selectedDevice = val!),
                  ),
                  const SizedBox(width: 12),
                  DropdownButton<String>(
                    value: selectedStatus,
                    borderRadius: BorderRadius.circular(10),
                    items: const [
                      DropdownMenuItem(value: 'all', child: Text('All')),
                      DropdownMenuItem(value: 'on', child: Text('ON')),
                      DropdownMenuItem(value: 'off', child: Text('OFF')),
                    ],
                    onChanged: (val) => setState(() => selectedStatus = val!),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: _pickDate,
                    icon: const Icon(Icons.calendar_today, size: 18),
                    label: Text(
                      selectedDate != null
                          ? DateFormat('dd/MM/yyyy').format(selectedDate!)
                          : "Pick Date",
                    ),
                  ),
                  const SizedBox(width: 12),
                  OutlinedButton.icon(
                    onPressed: _clearFilters,
                    icon: const Icon(Icons.refresh),
                    label: const Text("Reset"),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: _clearHistory,
                    icon: const Icon(Icons.delete_forever),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                    label: const Text("Clear All"),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // History List
        Expanded(
          child: StreamBuilder<List<HistoryItem>>(
            stream: _firebaseService.getHistoryStream(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text("No history found."));
              }

              final history = snapshot.data!
                  .where((item) => item.device == selectedDevice)
                  .where((item) {
                    if (selectedStatus == 'on') return item.status == true;
                    if (selectedStatus == 'off') return item.status == false;
                    return true;
                  })
                  .where((item) {
                    if (selectedDate == null) return true;
                    final date = DateTime.fromMillisecondsSinceEpoch(
                      item.timestamp,
                    );
                    return date.year == selectedDate!.year &&
                        date.month == selectedDate!.month &&
                        date.day == selectedDate!.day;
                  })
                  .toList();

              if (history.isEmpty) {
                return const Center(child: Text("No matching history."));
              }

              return ListView.separated(
                itemCount: history.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final item = history[index];
                  final time = DateTime.fromMillisecondsSinceEpoch(
                    item.timestamp,
                  );

                  return Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ListTile(
                      leading: Icon(
                        item.status ? Icons.power : Icons.power_off,
                        color: item.status ? Colors.green : Colors.red,
                      ),
                      title: Text(
                        '${item.device.toUpperCase()} turned ${item.status ? 'ON' : 'OFF'}',
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      subtitle: Text(
                        DateFormat('dd MMM yyyy – HH:mm').format(time),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
