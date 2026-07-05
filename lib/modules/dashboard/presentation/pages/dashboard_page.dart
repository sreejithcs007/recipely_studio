import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter/services.dart';

import '../../../../shared/widgets/error_states/error_state.dart';
import '../../../../shared/widgets/loading/shimmers.dart';
import '../../../../shared/widgets/recent_recipes.dart';
import '../../../../core/services/file_upload_service.dart';
import '../../../../core/services/snackbar_service.dart';
import '../bloc/dashboard_bloc.dart';
import '../widgets/welcome_banner.dart';
import '../widgets/dashboard_charts.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  void initState() {
    super.initState();
    context.read<DashboardBloc>().add(LoadDashboard());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      body: BlocBuilder<DashboardBloc, DashboardState>(
        builder: (context, state) {
          if (state is DashboardLoading) {
            return _buildShimmer();
          }
          if (state is DashboardError) {
            return ErrorState(
              message: state.message,
              onRetry: () => context.read<DashboardBloc>().add(LoadDashboard()),
            );
          }
          if (state is DashboardLoaded) {
            final data = state.data;
            final stats = data['statistics'] as Map<String, dynamic>;
            final recentRecipes = data['recentRecipes'] as List<dynamic>;
            final popularCategories = data['popularCategories'] as List<dynamic>;
            final growthData = data['recipeGrowth'] as List<dynamic>? ?? [];

            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── 1. Welcome Banner ─────────────────────────────────────
                  WelcomeBanner(
                    stats: stats,
                    onNewCategory: () => context.go('/categories?action=new'),
                    onAddRecipe: () => context.go('/recipes/new'),
                    onUploadMedia: () => _showUploadMediaDialog(context),
                  ),
                  const SizedBox(height: 24),

                  // ── 2. Stats Cards Row (6 cards) ──────────────────────────
                  _StatsRow(stats: stats),
                  const SizedBox(height: 24),

                  // ── 3. Charts Row: Growth + Cuisines ──────────────────────
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 5,
                        child: _Card(
                          child: RecipeGrowthChart(growthData: growthData),
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        flex: 3,
                        child: _Card(
                          child: CuisineDonutChart(popularCategories: popularCategories),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // ── 4. Bottom Row: Top Recipes + Latest Recipes ───────────
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 3,
                        child: _Card(
                          child: TopRecipesBarChart(recipes: recentRecipes),
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        flex: 5,
                        child: RecentRecipes(recipes: recentRecipes),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildShimmer() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const ShimmerLoader(width: double.infinity, height: 140),
          const SizedBox(height: 24),
          Row(
            children: List.generate(
              6,
              (_) => Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: const ShimmerLoader(width: double.infinity, height: 100),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: const [
              Expanded(flex: 5, child: ShimmerLoader(width: double.infinity, height: 320)),
              SizedBox(width: 20),
              Expanded(flex: 3, child: ShimmerLoader(width: double.infinity, height: 320)),
            ],
          ),
        ],
      ),
    );
  }

  void _showUploadMediaDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => const _UploadMediaDialog(),
    );
  }
}

// ── 6-column Stats Row ────────────────────────────────────────────────────────
class _StatsRow extends StatelessWidget {
  final Map<String, dynamic> stats;

  const _StatsRow({required this.stats});

  @override
  Widget build(BuildContext context) {
    final items = [
      _StatItem(
        icon: Icons.soup_kitchen_outlined,
        iconBg: const Color(0xFFFFF3E8),
        iconColor: const Color(0xFFFF6430),
        label: 'Total Recipes',
        value: '${stats['totalRecipes'] ?? 0}',
        change: '+12.4%',
        positive: true,
      ),
      _StatItem(
        icon: Icons.star_border_rounded,
        iconBg: const Color(0xFFFFFBEB),
        iconColor: const Color(0xFFF59E0B),
        label: 'Featured',
        value: '${stats['featuredRecipes'] ?? 0}',
        change: '+8.1%',
        positive: true,
      ),
      _StatItem(
        icon: Icons.local_fire_department_outlined,
        iconBg: const Color(0xFFFFEDED),
        iconColor: const Color(0xFFEF4444),
        label: 'Trending',
        value: '${stats['trendingRecipes'] ?? 0}',
        change: '+22.0%',
        positive: true,
      ),
      _StatItem(
        icon: Icons.grid_view_rounded,
        iconBg: const Color(0xFFEFF6FF),
        iconColor: const Color(0xFF3B82F6),
        label: 'Categories',
        value: '${stats['totalCategories'] ?? 0}',
        change: '2 new',
        positive: true,
      ),
      _StatItem(
        icon: Icons.people_outline_rounded,
        iconBg: const Color(0xFFEBFBEE),
        iconColor: const Color(0xFF3B9E74),
        label: 'Active Users',
        value: '${stats['totalUsers'] ?? 0}',
        change: '+5.7%',
        positive: true,
      ),
      _StatItem(
        icon: Icons.favorite_border_rounded,
        iconBg: const Color(0xFFFFF0F5),
        iconColor: const Color(0xFFE8558A),
        label: 'Favorites',
        value: '${stats['totalFavorites'] ?? 0}',
        change: '↓ 1.2%',
        positive: false,
      ),
    ];

    return Row(
      children: items.asMap().entries.map((entry) {
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: entry.key < items.length - 1 ? 12 : 0),
            child: _StatCard(item: entry.value),
          ),
        );
      }).toList(),
    );
  }
}

class _StatItem {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String label;
  final String value;
  final String change;
  final bool positive;

  const _StatItem({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.change,
    required this.positive,
  });
}

class _StatCard extends StatefulWidget {
  final _StatItem item;

  const _StatCard({required this.item});

  @override
  State<_StatCard> createState() => _StatCardState();
}

class _StatCardState extends State<_StatCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        transform: _hovered
            ? (Matrix4.identity()..translate(0.0, -3.0))
            : Matrix4.identity(),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: _hovered
                ? item.iconColor.withOpacity(0.3)
                : const Color(0xFFE2E8F0),
          ),
          boxShadow: _hovered
              ? [BoxShadow(color: item.iconColor.withOpacity(0.08), blurRadius: 12, offset: const Offset(0, 6))]
              : [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon + change badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: item.iconBg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(item.icon, color: item.iconColor, size: 18),
                ),
                Row(
                  children: [
                    Icon(
                      item.positive ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
                      size: 11,
                      color: item.positive ? const Color(0xFF3B9E74) : const Color(0xFFEF4444),
                    ),
                    const SizedBox(width: 2),
                    Text(
                      item.change,
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: item.positive ? const Color(0xFF3B9E74) : const Color(0xFFEF4444),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 14),
            // Value
            Text(
              item.value,
              style: GoogleFonts.inter(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF0F0F0F),
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 4),
            // Label
            Text(
              item.label,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: const Color(0xFF8E8E8E),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Generic white card container ───────────────────────────────────────────────
class _Card extends StatelessWidget {
  final Widget child;

  const _Card({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: child,
    );
  }
}

// ── Upload Media Dialog Widget ───────────────────────────────────────────────
class _UploadMediaDialog extends StatefulWidget {
  const _UploadMediaDialog();

  @override
  State<_UploadMediaDialog> createState() => _UploadMediaDialogState();
}

class _UploadMediaDialogState extends State<_UploadMediaDialog> {
  final TextEditingController _urlController = TextEditingController();
  bool _isUploading = false;
  String? _fileName;

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _pickAndUpload() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );

    if (result != null && result.files.first.bytes != null) {
      final file = result.files.first;
      setState(() {
        _isUploading = true;
        _fileName = file.name;
        _urlController.clear();
      });

      try {
        final url = await GetIt.I<FileUploadService>().uploadFile(
          bucket: 'recipe-images',
          fileName: 'media_${DateTime.now().millisecondsSinceEpoch}_${file.name}',
          fileBytes: file.bytes!,
        );
        setState(() {
          _urlController.text = url;
          _isUploading = false;
        });
        GetIt.I<SnackbarService>().showSuccess('File uploaded successfully!');
      } catch (e) {
        setState(() => _isUploading = false);
        GetIt.I<SnackbarService>().showError('Upload failed: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        'Upload Media',
        style: GoogleFonts.inter(fontSize: 17, fontWeight: FontWeight.w700),
      ),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select an image to upload to Supabase storage. You can copy the generated URL to use in your recipes or categories.',
              style: GoogleFonts.inter(fontSize: 13.5, color: const Color(0xFF6C757D), height: 1.4),
            ),
            const SizedBox(height: 20),
            if (_isUploading) ...[
              Center(
                child: Column(
                  children: [
                    const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2.5),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Uploading ${_fileName ?? ''}...',
                      style: GoogleFonts.inter(fontSize: 12.5, color: const Color(0xFF8E8E8E)),
                    ),
                  ],
                ),
              ),
            ] else ...[
              Center(
                child: OutlineButton(
                  onPressed: _pickAndUpload,
                  icon: Icons.image_rounded,
                  label: _urlController.text.isNotEmpty ? 'Select Another Image' : 'Choose Image File',
                ),
              ),
            ],
            if (_urlController.text.isNotEmpty) ...[
              const SizedBox(height: 20),
              Text(
                'Generated Public URL',
                style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF4E4E4E)),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 38,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F6F8),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      alignment: Alignment.centerLeft,
                      child: SelectableText(
                        _urlController.text,
                        maxLines: 1,
                        style: GoogleFonts.inter(fontSize: 12.5, color: const Color(0xFF0F0F0F)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: _urlController.text));
                      GetIt.I<SnackbarService>().showSuccess('URL copied to clipboard!');
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      height: 38,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: primaryColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'Copy',
                        style: GoogleFonts.inter(fontSize: 12.5, fontWeight: FontWeight.w600, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Close', style: GoogleFonts.inter()),
        ),
      ],
    );
  }
}

class OutlineButton extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final String label;

  const OutlineButton({
    super.key,
    required this.onPressed,
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 16),
      label: Text(label, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500)),
      style: OutlinedButton.styleFrom(
        foregroundColor: const Color(0xFF4E4E4E),
        side: const BorderSide(color: Color(0xFFDEE2E6)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}
