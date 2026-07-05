import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';

// ── Recipe Growth Area Chart ─────────────────────────────────────────────────
class RecipeGrowthChart extends StatefulWidget {
  final List<dynamic> growthData;

  const RecipeGrowthChart({super.key, required this.growthData});

  @override
  State<RecipeGrowthChart> createState() => _RecipeGrowthChartState();
}

class _RecipeGrowthChartState extends State<RecipeGrowthChart> {
  String _selectedPeriod = '12M';

  final _months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

  List<FlSpot> _getSpots() {
    // Cumulative counts by month
    final Map<int, int> monthCounts = {};
    for (final item in widget.growthData) {
      final raw = item['created_at'] as String?;
      if (raw != null) {
        final dt = DateTime.tryParse(raw);
        if (dt != null) {
          monthCounts[dt.month] = (monthCounts[dt.month] ?? 0) + 1;
        }
      }
    }

    // Build cumulative spots
    int cumulative = 0;
    final List<FlSpot> spots = [];
    for (int i = 1; i <= 12; i++) {
      cumulative += monthCounts[i] ?? 0;
      spots.add(FlSpot((i - 1).toDouble(), cumulative.toDouble()));
    }
    // If no data, use sample data
    if (widget.growthData.isEmpty) {
      return [
        const FlSpot(0, 120), const FlSpot(1, 180), const FlSpot(2, 240),
        const FlSpot(3, 310), const FlSpot(4, 390), const FlSpot(5, 480),
        const FlSpot(6, 560), const FlSpot(7, 620), const FlSpot(8, 680),
        const FlSpot(9, 720), const FlSpot(10, 780), const FlSpot(11, 840),
      ];
    }
    return spots;
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    final spots = _getSpots();
    final maxY = (spots.map((s) => s.y).reduce((a, b) => a > b ? a : b) * 1.2).ceilToDouble();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Recipe growth',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: const Color(0xFF8E8E8E),
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      '${spots.last.y.toInt()}',
                      style: GoogleFonts.inter(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF0F0F0F),
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.trending_up_rounded, color: Color(0xFF3B9E74), size: 16),
                    const SizedBox(width: 3),
                    Text(
                      '+18.4%',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF3B9E74),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            // Period toggle
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF5F6F8),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: ['3M', '6M', '12M', 'All'].map((period) {
                  final isActive = _selectedPeriod == period;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedPeriod = period),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: isActive ? Colors.white : Colors.transparent,
                        borderRadius: BorderRadius.circular(6),
                        boxShadow: isActive
                            ? [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 4)]
                            : null,
                      ),
                      child: Text(
                        period,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                          color: isActive ? const Color(0xFF0F0F0F) : const Color(0xFF8E8E8E),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        // Area chart
        SizedBox(
          height: 220,
          child: LineChart(
            LineChartData(
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: maxY / 4,
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
                    reservedSize: 36,
                    interval: maxY / 4,
                    getTitlesWidget: (value, meta) => Text(
                      value.toInt().toString(),
                      style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFFADB5BD)),
                    ),
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 28,
                    interval: 1,
                    getTitlesWidget: (value, meta) {
                      final idx = value.toInt();
                      if (idx >= 0 && idx < _months.length) {
                        return SideTitleWidget(
                          axisSide: meta.axisSide,
                          space: 6,
                          child: Text(
                            _months[idx],
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
              maxY: maxY,
              lineBarsData: [
                // Total recipes (darker orange)
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
                // Published (lighter orange)
                LineChartBarData(
                  spots: spots.map((s) => FlSpot(s.x, s.y * 0.88)).toList(),
                  isCurved: true,
                  curveSmoothness: 0.35,
                  color: primaryColor.withOpacity(0.45),
                  barWidth: 2,
                  isStrokeCapRound: true,
                  dotData: const FlDotData(show: false),
                  belowBarData: BarAreaData(
                    show: true,
                    gradient: LinearGradient(
                      colors: [primaryColor.withOpacity(0.08), primaryColor.withOpacity(0.0)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ── Cuisine Donut Chart ──────────────────────────────────────────────────────
class CuisineDonutChart extends StatefulWidget {
  final List<dynamic> popularCategories;

  const CuisineDonutChart({super.key, required this.popularCategories});

  @override
  State<CuisineDonutChart> createState() => _CuisineDonutChartState();
}

class _CuisineDonutChartState extends State<CuisineDonutChart> {
  int _touchedIndex = -1;

  final _colors = [
    const Color(0xFFFF6430),
    const Color(0xFFF59E0B),
    const Color(0xFF3B9E74),
    const Color(0xFF60A5FA),
    const Color(0xFFA78BFA),
  ];

  @override
  Widget build(BuildContext context) {
    final data = widget.popularCategories.isNotEmpty
        ? widget.popularCategories
        : [
            {'name': 'Italian', 'count': 32},
            {'name': 'Japanese', 'count': 18},
            {'name': 'Thai', 'count': 14},
            {'name': 'French', 'count': 12},
            {'name': 'Others', 'count': 24},
          ];

    final total = data.fold<int>(0, (sum, d) => sum + ((d['count'] ?? 0) as int));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Cuisines',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: const Color(0xFF8E8E8E),
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      '${data.length}',
                      style: GoogleFonts.inter(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF0F0F0F),
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'types',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: const Color(0xFF8E8E8E),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const Icon(Icons.more_horiz, color: Color(0xFFADB5BD)),
          ],
        ),
        const SizedBox(height: 20),
        // Donut chart
        SizedBox(
          height: 160,
          child: PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: 42,
              pieTouchData: PieTouchData(
                touchCallback: (event, response) {
                  setState(() {
                    if (!event.isInterestedForInteractions ||
                        response == null ||
                        response.touchedSection == null) {
                      _touchedIndex = -1;
                      return;
                    }
                    _touchedIndex = response.touchedSection!.touchedSectionIndex;
                  });
                },
              ),
              sections: data.asMap().entries.map((entry) {
                final i = entry.key;
                final d = entry.value;
                final count = (d['count'] ?? 0) as int;
                final isTouched = i == _touchedIndex;
                return PieChartSectionData(
                  color: _colors[i % _colors.length],
                  value: count.toDouble(),
                  title: '',
                  radius: isTouched ? 52 : 44,
                );
              }).toList(),
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Legend
        ...data.asMap().entries.map((entry) {
          final i = entry.key;
          final d = entry.value;
          final count = (d['count'] ?? 0) as int;
          final pct = total > 0 ? (count / total * 100).round() : 0;
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Container(
                  width: 9,
                  height: 9,
                  decoration: BoxDecoration(
                    color: _colors[i % _colors.length],
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    d['name'] as String,
                    style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF4E4E4E)),
                  ),
                ),
                Text(
                  '$pct%',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF4E4E4E),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}

// ── Top Recipes Bar Chart ────────────────────────────────────────────────────
class TopRecipesBarChart extends StatelessWidget {
  final List<dynamic> recipes;

  const TopRecipesBarChart({super.key, required this.recipes});

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    final data = recipes.isNotEmpty
        ? recipes.take(6).toList()
        : [
            {'title': 'Truffle Risotto', 'views_count': 980},
            {'title': 'Wagyu Burger', 'views_count': 860},
            {'title': 'Miso Salmon', 'views_count': 720},
            {'title': 'Thai Curry', 'views_count': 810},
            {'title': 'Beef Ragu', 'views_count': 640},
            {'title': 'Tiramisu', 'views_count': 530},
          ];

    final maxVal = data
        .map((d) => (d['views_count'] ?? 0) as int)
        .fold(0, (a, b) => a > b ? a : b)
        .toDouble();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Most viewed',
          style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF8E8E8E)),
        ),
        const SizedBox(height: 4),
        Text(
          'Top ${data.length} recipes',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF0F0F0F),
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 20),
        ...data.asMap().entries.map((entry) {
          final d = entry.value;
          final title = (d['title'] as String? ?? 'Recipe').split(' ').take(2).join('\n');
          final views = (d['views_count'] ?? 0) as int;
          final fraction = maxVal > 0 ? views / maxVal : 0.5;

          return Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Row(
              children: [
                SizedBox(
                  width: 64,
                  child: Text(
                    title,
                    textAlign: TextAlign.right,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: const Color(0xFF8E8E8E),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: fraction,
                      backgroundColor: const Color(0xFFF5F6F8),
                      valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                      minHeight: 12,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}
