import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart'; // ⬅️ Penting untuk format tanggal

import '../services/auth_services.dart';
import '../services/firebase_services.dart';
import '../widget/lamp_toggle.dart';
import '../widget/fan_toggle.dart';
import '../widget/stats_list.dart';
import '../widget/weekly_options.dart';
import '../widget/history.dart';
import '../models/power_stats.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late Timer _scheduleTimer;

  @override
  void initState() {
    super.initState();

    // Cek auto-schedule pertama kali
    FirebaseService().evaluateAutoSchedule();

    // Cek auto-schedule setiap 1 menit
    _scheduleTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      FirebaseService().evaluateAutoSchedule();
      print('Auto-schedule checked at ${DateTime.now()}');
    });
  }

  @override
  void dispose() {
    _scheduleTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Format tanggal hari ini
    final todayFormatted = DateFormat.yMMMMEEEEd(
      'id_ID',
    ).format(DateTime.now());

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Dashboard",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Color(0xFFF2C94C)),
            onPressed: () async {
              await auth.signOut();
            },
            tooltip: 'Logout',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Selamat datang
            Text(
              "Hi 👋, Welcome back!",
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF2F80ED),
              ),
            ),
            const SizedBox(height: 4),
            // Tanggal hari ini
            Text(
              todayFormatted,
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 20),

            // Lamp Control
            _buildCard(
              title: "Lamp Control",
              icon: Icons.lightbulb_outline,
              child: const SizedBox(height: 60, child: LampToggle()),
            ),
            const SizedBox(height: 24),

            // Fan Control
            _buildCard(
              title: "Fan Control",
              icon: Icons.toys,
              child: const SizedBox(height: 60, child: FanToggle()),
            ),
            const SizedBox(height: 24),

            // Power Usage
            _buildCard(
              title: "Power Usage",
              icon: Icons.bolt,
              child: StreamBuilder<List<PowerStats>>(
                stream: FirebaseService().getPowerStatsStream(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return const Center(child: Text('Error loading stats'));
                  } else {
                    final stats = snapshot.data ?? [];
                    if (stats.isEmpty) {
                      return const Center(child: Text('No stats available'));
                    }
                    return StatsList(stats: stats);
                  }
                },
              ),
            ),
            const SizedBox(height: 24),

            // Weekly Schedule
            _buildCard(
              title: "Weekly Schedule",
              icon: Icons.schedule,
              child: WeeklyScheduleWidget(firebaseService: FirebaseService()),
            ),
            const SizedBox(height: 24),

            // Device History
            _buildCard(
              title: "Device History",
              icon: Icons.history,
              child: const SizedBox(height: 280, child: DeviceHistoryList()),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: const Color(0xFF2F80ED)),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2F80ED),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}
