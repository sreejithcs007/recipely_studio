import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../shared/widgets/cards/stats_card.dart';
import '../../../../shared/widgets/error_states/error_state.dart';
import '../../../../shared/widgets/loading/shimmers.dart';
import '../bloc/dashboard_bloc.dart';
import '../widgets/welcome_banner.dart';
import '../widgets/quick_actions.dart';
import '../../../../shared/widgets/recent_recipes.dart';
import '../widgets/recent_activity.dart';
import '../widgets/dashboard_charts.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _AdminLogSummary extends StatelessWidget {
  final Map<String, dynamic> stats;

  const _AdminLogSummary({required this.stats});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: MediaQuery.of(context).size.width > 1200 ? 4 : 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.6,
      children: [
        StatsCard(
          title: 'Total Recipes',
          value: '${stats['totalRecipes'] ?? 0}',
          icon: Icons.restaurant,
          iconColor: Colors.deepOrange,
          changeLabel: '+12%',
        ),
        StatsCard(
          title: 'Featured Recipes',
          value: '${stats['featuredRecipes'] ?? 0}',
          icon: Icons.star,
          iconColor: Colors.amber,
          changeLabel: '+5%',
        ),
        StatsCard(
          title: 'Total Categories',
          value: '${stats['totalCategories'] ?? 0}',
          icon: Icons.category,
          iconColor: Colors.teal,
          changeLabel: '0%',
        ),
        StatsCard(
          title: 'Active Users',
          value: '${stats['totalUsers'] ?? 0}',
          icon: Icons.people,
          iconColor: Colors.blue,
          changeLabel: '+8%',
        ),
      ],
    );
  }
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  void initState() {
    super.initState();
    context.read<DashboardBloc>().add(LoadDashboard());
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 1024;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF18181B) : Colors.white;
    final borderColor = isDark ? const Color(0xFF27272A) : const Color(0xFFE2E8F0);
    final titleColor = isDark ? Colors.white : const Color(0xFF0F172A);

    return Scaffold(
      body: BlocBuilder<DashboardBloc, DashboardState>(
        builder: (context, state) {
          if (state is DashboardLoading) {
            return _buildShimmerLayout(context);
          } else if (state is DashboardError) {
            return ErrorState(
              message: state.message,
              onRetry: () => context.read<DashboardBloc>().add(LoadDashboard()),
            );
          } else if (state is DashboardLoaded) {
            final data = state.data;
            final stats = data['statistics'] as Map<String, dynamic>;
            final recentRecipes = data['recentRecipes'] as List<dynamic>;
            final recentActivity = data['recentActivity'] as List<dynamic>;
            final popularCategories = data['popularCategories'] as List<dynamic>;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Welcome Banner
                  const WelcomeBanner(),
                  const SizedBox(height: 24),
                  
                  // 2. Metrics Grid
                  _AdminLogSummary(stats: stats),
                  const SizedBox(height: 24),

                  // 3. Grid for Charts and Lists
                  if (isWide)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Left Column (Charts and Recent Recipes)
                        Expanded(
                          flex: 2,
                          child: Column(
                            children: [
                              // Recipe Growth Chart Card
                              _buildChartCard(
                                title: 'Recipe Growth Overview',
                                isDark: isDark,
                                cardBg: cardBg,
                                borderColor: borderColor,
                                titleColor: titleColor,
                                child: SizedBox(
                                  height: 260,
                                  child: RecipeGrowthChart(growthData: data['recipeGrowth'] ?? []),
                                ),
                              ),
                              const SizedBox(height: 24),
                              RecentRecipes(recipes: recentRecipes),
                            ],
                          ),
                        ),
                        const SizedBox(width: 24),
                        // Right Column (Quick Actions, Category Share, Activity)
                        Expanded(
                          flex: 1,
                          child: Column(
                            children: [
                              const QuickActions(),
                              const SizedBox(height: 24),
                              // Pie Chart Card
                              _buildChartCard(
                                title: 'Category Popularity',
                                isDark: isDark,
                                cardBg: cardBg,
                                borderColor: borderColor,
                                titleColor: titleColor,
                                child: SizedBox(
                                  height: 180,
                                  child: CategoryPieChart(popularCategories: popularCategories),
                                ),
                              ),
                              const SizedBox(height: 24),
                              RecentActivity(logs: recentActivity),
                            ],
                          ),
                        ),
                      ],
                    )
                  else
                    // Mobile stacked layout
                    Column(
                      children: [
                        const QuickActions(),
                        const SizedBox(height: 24),
                        _buildChartCard(
                          title: 'Recipe Growth Overview',
                          isDark: isDark,
                          cardBg: cardBg,
                          borderColor: borderColor,
                          titleColor: titleColor,
                          child: SizedBox(
                            height: 220,
                            child: RecipeGrowthChart(growthData: data['recipeGrowth'] ?? []),
                          ),
                        ),
                        const SizedBox(height: 24),
                        RecentRecipes(recipes: recentRecipes),
                        const SizedBox(height: 24),
                        RecentActivity(logs: recentActivity),
                      ],
                    ),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildChartCard({
    required String title,
    required bool isDark,
    required Color cardBg,
    required Color borderColor,
    required Color titleColor,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 1),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: titleColor,
            ),
          ),
          const SizedBox(height: 24),
          child,
        ],
      ),
    );
  }

  Widget _buildShimmerLayout(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ShimmerLoader(width: double.infinity, height: 120),
          const SizedBox(height: 24),
          Row(
            children: const [
              Expanded(child: ShimmerLoader(width: double.infinity, height: 100)),
              SizedBox(width: 16),
              Expanded(child: ShimmerLoader(width: double.infinity, height: 100)),
              SizedBox(width: 16),
              Expanded(child: ShimmerLoader(width: double.infinity, height: 100)),
              SizedBox(width: 16),
              Expanded(child: ShimmerLoader(width: double.infinity, height: 100)),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Expanded(
                flex: 2,
                child: ShimmerLoader(width: double.infinity, height: 400),
              ),
              SizedBox(width: 24),
              Expanded(
                flex: 1,
                child: ShimmerLoader(width: double.infinity, height: 400),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
