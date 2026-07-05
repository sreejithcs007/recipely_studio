import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';

class AnalyticsPage extends StatefulWidget {
  const AnalyticsPage({super.key});

  @override
  State<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage> {
  String _selectedPeriod = 'Last 30 days';

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Page Header ──────────────────────────────────────────────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'INSIGHTS',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.1,
                          color: primaryColor,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Analytics',
                        style: GoogleFonts.inter(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFF0F0F0F),
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Real-time performance across recipes, cuisines, and readers.',
                        style: GoogleFonts.inter(
                          fontSize: 13.5,
                          color: const Color(0xFF8E8E8E),
                        ),
                      ),
                    ],
                  ),
                ),
                // Period button
                _OutlineDropdownButton(
                  icon: Icons.calendar_today_rounded,
                  label: _selectedPeriod,
                  onTap: _showPeriodMenu,
                ),
                const SizedBox(width: 10),
                // Export button
                _OutlineButton(
                  icon: Icons.download_rounded,
                  label: 'Export',
                  onTap: () {},
                ),
              ],
            ),
            const SizedBox(height: 24),

            // ── Stats Cards Row ──────────────────────────────────────────────
            LayoutBuilder(
              builder: (context, constraints) {
                final cardWidth = (constraints.maxWidth - 3 * 16) / 4;
                return Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    _StatCard(
                      width: cardWidth,
                      icon: Icons.visibility_outlined,
                      iconBg: const Color(0xFFFFF3E8),
                      iconColor: primaryColor,
                      label: 'Recipe views',
                      value: '1.42M',
                      growth: '↑ 18.4%',
                    ),
                    _StatCard(
                      width: cardWidth,
                      icon: Icons.favorite_outline_rounded,
                      iconBg: const Color(0xFFFFE8EC),
                      iconColor: const Color(0xFFE8558A),
                      label: 'Saves',
                      value: '98.2k',
                      growth: '↑ 7.1%',
                    ),
                    _StatCard(
                      width: cardWidth,
                      icon: Icons.people_outline_rounded,
                      iconBg: const Color(0xFFE8F5E9),
                      iconColor: const Color(0xFF2F9E44),
                      label: 'Readers',
                      value: '24.6k',
                      growth: '↑ 5.7%',
                    ),
                    _StatCard(
                      width: cardWidth,
                      icon: Icons.trending_up_rounded,
                      iconBg: const Color(0xFFFFF9DB),
                      iconColor: const Color(0xFFF59E0B),
                      label: 'Publish velocity',
                      value: '+18/wk',
                      growth: '↑ 12.0%',
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 24),

            // ── Grid Row 1 (Recipe growth & Cuisines Donut) ──────────────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Recipe Growth
                Expanded(
                  flex: 2,
                  child: _ChartCard(
                    title: 'Recipe growth',
                    subtitle: '812 recipes published',
                    height: 320,
                    child: const _RecipeGrowthLineChart(),
                  ),
                ),
                const SizedBox(width: 24),
                // Most Popular Cuisines
                Expanded(
                  flex: 1,
                  child: _ChartCard(
                    title: 'Most popular cuisines',
                    subtitle: 'By share of views',
                    height: 320,
                    child: const _CuisineDonutChart(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // ── Grid Row 2 (Top Rated Recipes Bar & Save Velocity Line) ──────
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Rated Recipes (Bar Chart)
                Expanded(
                  flex: 1,
                  child: _ChartCard(
                    title: 'Top rated recipes',
                    subtitle: 'By average rating',
                    height: 340,
                    child: const _TopRatedBarChart(),
                  ),
                ),
                const SizedBox(width: 24),
                // Save Velocity (Line Chart)
                Expanded(
                  flex: 1,
                  child: _ChartCard(
                    title: 'Most saved',
                    subtitle: 'Save velocity',
                    height: 340,
                    child: const _SaveVelocityLineChart(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showPeriodMenu() {
    final items = ['Last 7 days', 'Last 30 days', 'Last 90 days', 'Custom Range'];
    showMenu<String>(
      context: context,
      position: const RelativeRect.fromLTRB(600, 160, 24, 0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 6,
      items: items
          .map((e) => PopupMenuItem(
                value: e,
                child: Text(e, style: GoogleFonts.inter(fontSize: 13)),
              ))
          .toList(),
    ).then((val) {
      if (val != null) {
        setState(() => _selectedPeriod = val);
      }
    });
  }
}

// ── Stat Card Component ──────────────────────────────────────────────────────
class _StatCard extends StatelessWidget {
  final double width;
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String label;
  final String value;
  final String growth;

  const _StatCard({
    required this.width,
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.growth,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width.clamp(200.0, double.infinity),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: iconBg,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 18),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFEBFBEE),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  growth,
                  style: GoogleFonts.inter(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF2F9E44),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12.5,
              color: const Color(0xFF8E8E8E),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: const Color(0xFF0F0F0F),
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Chart Container Card ─────────────────────────────────────────────────────
class _ChartCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final double height;
  final Widget child;

  const _ChartCard({
    required this.title,
    required this.subtitle,
    required this.height,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: const Color(0xFF8E8E8E),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: GoogleFonts.inter(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF0F0F0F),
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: height - 90,
            child: child,
          ),
        ],
      ),
    );
  }
}

// ── Recipe Growth Chart Widget ───────────────────────────────────────────────
class _RecipeGrowthLineChart extends StatelessWidget {
  const _RecipeGrowthLineChart();

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

    final spots = [
      const FlSpot(0, 110),
      const FlSpot(1, 150),
      const FlSpot(2, 180),
      const FlSpot(3, 220),
      const FlSpot(4, 280),
      const FlSpot(5, 360),
      const FlSpot(6, 420),
      const FlSpot(7, 490),
      const FlSpot(8, 560),
      const FlSpot(9, 640),
      const FlSpot(10, 720),
      const FlSpot(11, 812),
    ];

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 250,
          getDrawingHorizontalLine: (value) => FlLine(
            color: const Color(0xFFF1F1F1),
            strokeWidth: 1,
            dashArray: [4, 4],
          ),
        ),
        titlesData: FlTitlesData(
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 32,
              interval: 250,
              getTitlesWidget: (value, meta) {
                // Formatting 0 as 0, 750, 500, etc.
                if (value == 0) return Text('0', style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFFADB5BD)));
                return Text('${value.toInt()}', style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFFADB5BD)));
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 24,
              interval: 1,
              getTitlesWidget: (value, meta) {
                final idx = value.toInt();
                if (idx >= 0 && idx < months.length) {
                  return SideTitleWidget(
                    axisSide: meta.axisSide,
                    space: 6,
                    child: Text(
                      months[idx],
                      style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFFADB5BD)),
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
        maxX: 11,
        minY: 0,
        maxY: 1000,
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            curveSmoothness: 0.35,
            color: primaryColor,
            barWidth: 2.5,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [primaryColor.withOpacity(0.18), primaryColor.withOpacity(0.0)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Cuisines Donut Chart Widget ──────────────────────────────────────────────
class _CuisineDonutChart extends StatelessWidget {
  const _CuisineDonutChart();

  @override
  Widget build(BuildContext context) {
    final colors = [
      const Color(0xFFFF6430),
      const Color(0xFFF59E0B),
      const Color(0xFF3B9E74),
      const Color(0xFF60A5FA),
      const Color(0xFFA78BFA),
    ];

    final values = [35.0, 20.0, 18.0, 15.0, 12.0];

    return PieChart(
      PieChartData(
        sectionsSpace: 2,
        centerSpaceRadius: 48,
        sections: List.generate(values.length, (index) {
          return PieChartSectionData(
            color: colors[index],
            value: values[index],
            title: '',
            radius: 38,
          );
        }),
      ),
    );
  }
}

// ── Top Rated Bar Chart Widget ───────────────────────────────────────────────
class _TopRatedBarChart extends StatelessWidget {
  const _TopRatedBarChart();

  @override
  Widget build(BuildContext context) {
    final items = ['Truffle Risotto', 'Wagyu Burger', 'Miso Salmon', 'Thai Curry', 'Beef Ragu', 'Tiramisu'];
    final ratings = [4.9, 4.8, 4.7, 4.6, 4.5, 4.4];

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: 5,
        minY: 0,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 1.25,
          getDrawingHorizontalLine: (value) => FlLine(
            color: const Color(0xFFF1F1F1),
            strokeWidth: 1,
            dashArray: [4, 4],
          ),
        ),
        titlesData: FlTitlesData(
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              interval: 1.25,
              getTitlesWidget: (value, meta) {
                if (value == 0) return Text('0', style: GoogleFonts.inter(fontSize: 10, color: const Color(0xFFADB5BD)));
                return Text('${value.toStringAsFixed(1)}', style: GoogleFonts.inter(fontSize: 10, color: const Color(0xFFADB5BD)));
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 32,
              getTitlesWidget: (value, meta) {
                final idx = value.toInt();
                if (idx >= 0 && idx < items.length) {
                  return SideTitleWidget(
                    axisSide: meta.axisSide,
                    space: 6,
                    child: Text(
                      items[idx].split(' ').join('\n'),
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(fontSize: 9.5, color: const Color(0xFF8E8E8E)),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        barGroups: List.generate(items.length, (index) {
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: ratings[index],
                color: const Color(0xFFF59E0B),
                width: 32,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(6),
                  topRight: Radius.circular(6),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}

// ── Save Velocity Line Chart Widget ──────────────────────────────────────────
class _SaveVelocityLineChart extends StatelessWidget {
  const _SaveVelocityLineChart();

  @override
  Widget build(BuildContext context) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final spots = [
      const FlSpot(0, 90),
      const FlSpot(1, 115),
      const FlSpot(2, 140),
      const FlSpot(3, 175),
      const FlSpot(4, 220),
      const FlSpot(5, 260),
      const FlSpot(6, 330),
      const FlSpot(7, 395),
      const FlSpot(8, 470),
      const FlSpot(9, 550),
      const FlSpot(10, 630),
      const FlSpot(11, 740),
    ];

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 200,
          getDrawingHorizontalLine: (value) => FlLine(
            color: const Color(0xFFF1F1F1),
            strokeWidth: 1,
            dashArray: [4, 4],
          ),
        ),
        titlesData: FlTitlesData(
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              interval: 200,
              getTitlesWidget: (value, meta) {
                return Text('${value.toInt()}', style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFFADB5BD)));
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 24,
              interval: 1,
              getTitlesWidget: (value, meta) {
                final idx = value.toInt();
                if (idx >= 0 && idx < months.length) {
                  return SideTitleWidget(
                    axisSide: meta.axisSide,
                    space: 6,
                    child: Text(
                      months[idx],
                      style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFFADB5BD)),
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
        maxX: 11,
        minY: 0,
        maxY: 800,
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            curveSmoothness: 0.2,
            color: const Color(0xFF2F9E44),
            barWidth: 2,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                radius: 3.5,
                color: const Color(0xFF2F9E44),
                strokeWidth: 1,
                strokeColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Dropdown / Button Helpers ────────────────────────────────────────────────
class _OutlineDropdownButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _OutlineDropdownButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFDEE2E6)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 15, color: const Color(0xFF4E4E4E)),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF4E4E4E),
              ),
            ),
            const SizedBox(width: 6),
            const Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: Color(0xFF8E8E8E)),
          ],
        ),
      ),
    );
  }
}

class _OutlineButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _OutlineButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFDEE2E6)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 15, color: const Color(0xFF4E4E4E)),
            const SizedBox(width: 7),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF4E4E4E),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
