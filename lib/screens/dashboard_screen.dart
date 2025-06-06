import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_services.dart';
import '../services/firebase_services.dart';
import '../widget/lamp_toggle.dart';
import '../widget/fan_toggle.dart'; // ← Tambahkan ini
import '../widget/stats_chart.dart';
// import '../widgets/timer_control.dart';
import '../widget/weekly_options.dart';
import '../widget/lamp_history.dart';
import '../models/power_stats.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: ListView(
          children: [
            Text(
              "Hi 👋, Welcome back!",
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF2F80ED),
              ),
            ),
            const SizedBox(height: 20),

            ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text("Add Dummy Stat"),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2F80ED),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 16,
                ),
              ),
              onPressed: () {
                FirebaseService().addDummyStat();
              },
            ),

            const SizedBox(height: 20),

            // 💡 Lamp Control + Timer
            _buildCard(
              title: "Lamp Control",
              icon: Icons.lightbulb_outline,
              child: Column(
                children: const [
                  LampToggle(),
                  SizedBox(height: 16),
                  // TimerControlWidget(),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // 🌀 Fan (Dinamo) Control
            _buildCard(
              title: "Fan Control",
              icon: Icons.toys,
              child: const FanToggle(),
            ),

            const SizedBox(height: 24),

            // ⚡ Power Usage Chart
            _buildCard(
              title: "Power Usage",
              icon: Icons.bolt,
              child: SizedBox(
                height: 220,
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
                      return StatsChart(stats: stats);
                    }
                  },
                ),
              ),
            ),

            const SizedBox(height: 24),

            // 📅 Weekly Schedule
            _buildCard(
              title: "Weekly Schedule",
              icon: Icons.schedule,
              child: const WeeklyScheduleWidget(),
            ),

            const SizedBox(height: 24),

            // 🕓 Lamp History
            _buildCard(
              title: "Lamp History",
              icon: Icons.history,
              child: const LampHistoryList(),
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
