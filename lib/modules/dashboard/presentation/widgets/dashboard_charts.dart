import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';

class RecipeGrowthChart extends StatelessWidget {
  final List<dynamic> growthData;

  const RecipeGrowthChart({super.key, required this.growthData});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).primaryColor;

    final spots = [
      const FlSpot(0, 10),
      const FlSpot(1, 18),
      const FlSpot(2, 32),
      const FlSpot(3, 44),
      const FlSpot(4, 58),
      const FlSpot(5, 84),
    ];

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (value) => FlLine(
            color: isDark ? const Color(0xFF27272A) : const Color(0xFFF1F5F9),
            strokeWidth: 1,
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: 1,
              getTitlesWidget: (value, meta) {
                const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'];
                final index = value.toInt();
                if (index >= 0 && index < months.length) {
                  return SideTitleWidget(
                    axisSide: meta.axisSide,
                    space: 8,
                    child: Text(
                      months[index],
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        minX: 0,
        maxX: 5,
        minY: 0,
        maxY: 100,
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: primaryColor,
            barWidth: 4,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              color: primaryColor.withOpacity(0.1),
            ),
          ),
        ],
      ),
    );
  }
}

class CategoryPieChart extends StatelessWidget {
  final List<dynamic> popularCategories;

  const CategoryPieChart({super.key, required this.popularCategories});

  @override
  Widget build(BuildContext context) {
    final colors = [
      const Color(0xFFEA580C),
      const Color(0xFF10B981),
      const Color(0xFF3B82F6),
      const Color(0xFF8B5CF6),
      const Color(0xFFF59E0B),
    ];

    final sections = popularCategories.asMap().entries.map((entry) {
      final index = entry.key;
      final data = entry.value;
      final count = (data['count'] ?? 0) as int;

      return PieChartSectionData(
        color: colors[index % colors.length],
        value: count > 0 ? count.toDouble() : 1.0,
        title: count > 0 ? '$count' : '',
        radius: 40,
        titleStyle: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();

    return PieChart(
      PieChartData(
        sectionsSpace: 2,
        centerSpaceRadius: 30,
        sections: sections.isNotEmpty
            ? sections
            : [
                PieChartSectionData(
                  color: Colors.grey,
                  value: 1,
                  title: '',
                  radius: 40,
                ),
              ],
      ),
    );
  }
}
