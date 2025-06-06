import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../models/power_stats.dart';

class StatsChart extends StatelessWidget {
  final List<PowerStats> stats;
  const StatsChart({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorPrimary = isDark
        ? const Color(0xFF56CCF2)
        : const Color(0xFF2F80ED);

    // Ubah data menjadi FlSpot
    final List<FlSpot> spots = stats.map((e) {
      final double x = e.timestamp.toDouble(); // pastikan x adalah double
      final double y = e.value.toDouble(); // pastikan y adalah double
      return FlSpot(x, y);
    }).toList();

    // Fungsi untuk mengubah timestamp jadi string waktu
    String formatTime(double millis) {
      final date = DateTime.fromMillisecondsSinceEpoch(millis.toInt());
      return DateFormat.Hm().format(date); // contoh: 14:30
    }

    return LineChart(
      LineChartData(
        backgroundColor: Colors.transparent,
        minY: 0,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: true,
          getDrawingHorizontalLine: (_) =>
              FlLine(color: Colors.grey.withOpacity(0.2), strokeWidth: 1),
          getDrawingVerticalLine: (_) =>
              FlLine(color: Colors.grey.withOpacity(0.2), strokeWidth: 1),
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 42,
              interval: 0.5,
              getTitlesWidget: (value, _) => Text(
                value.toStringAsFixed(1),
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: _calculateXInterval(spots),
              reservedSize: 36,
              getTitlesWidget: (value, _) => Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  formatTime(value),
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.white70 : Colors.black54,
                  ),
                ),
              ),
            ),
          ),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: Colors.grey.withOpacity(0.3)),
        ),
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            tooltipBgColor: colorPrimary.withOpacity(0.85),
            getTooltipItems: (List<LineBarSpot> touchedSpots) {
              return touchedSpots.map((spot) {
                final time = formatTime(spot.x);
                return LineTooltipItem(
                  '$time\n${spot.y.toStringAsFixed(2)} W',
                  const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                );
              }).toList();
            },
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: colorPrimary,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  colorPrimary.withOpacity(0.3),
                  colorPrimary.withOpacity(0.05),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Fungsi bantu untuk menentukan jarak antar label X
  double _calculateXInterval(List<FlSpot> spots) {
    if (spots.length < 2) return 600000; // default 10 menit
    final duration = spots.last.x - spots.first.x;
    return duration / 4;
  }
}
