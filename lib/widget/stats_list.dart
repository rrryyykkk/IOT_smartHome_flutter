import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/power_stats.dart';

class StatsList extends StatelessWidget {
  final List<PowerStats> stats;
  const StatsList({super.key, required this.stats});

  String formatTimestamp(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return DateFormat('EEEE, d MMMM y • HH:mm', 'id_ID').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white70 : Colors.black87;

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: stats.length,
      itemBuilder: (context, index) {
        final stat = stats[index];
        final power = (stat.voltage * stat.current).toStringAsFixed(2);
        final formattedTime = formatTimestamp(stat.timestamp);

        IconData deviceIcon;
        switch (stat.deviceType.toLowerCase()) {
          case 'lamp':
            deviceIcon = Icons.light_mode;
            break;
          case 'fan':
            deviceIcon = Icons.air;
            break;
          default:
            deviceIcon = Icons.power;
        }

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Icon(deviceIcon, color: const Color(0xFF2F80ED), size: 28),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        '${stat.deviceName} (${stat.deviceType.toUpperCase()})',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  formattedTime,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                const Divider(height: 20, thickness: 1),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildStatItem(
                      'Tegangan',
                      '${stat.voltage.toStringAsFixed(1)} V',
                      textColor,
                    ),
                    _buildStatItem(
                      'Arus',
                      '${stat.current.toStringAsFixed(2)} A',
                      textColor,
                    ),
                    _buildStatItem('Daya', '$power W', textColor),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatItem(String label, String value, Color textColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 13, color: Colors.grey[600])),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
      ],
    );
  }
}
