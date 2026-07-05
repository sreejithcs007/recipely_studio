import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:get_it/get_it.dart';

import '../../../../core/services/dialog_service.dart';
import '../../../../core/services/snackbar_service.dart';
import '../../../../shared/widgets/empty_states/empty_state.dart';
import '../../../../shared/widgets/error_states/error_state.dart';
import '../../../../shared/widgets/loading/shimmers.dart';
import '../../domain/entities/recipe.dart';
import '../bloc/recipe_list_bloc.dart';

class RecipesListPage extends StatefulWidget {
  const RecipesListPage({super.key});

  @override
  State<RecipesListPage> createState() => _RecipesListPageState();
}

class _RecipesListPageState extends State<RecipesListPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String? _selectedStatus; // null = All
  String _sortBy = 'created_at';
  bool _ascending = false;
  final Set<String> _selectedIds = {};

  // Tab labels → status filter value
  final _tabs = [
    {'label': 'All', 'value': null},
    {'label': 'Published', 'value': 'published'},
    {'label': 'Draft', 'value': 'draft'},
    {'label': 'Review', 'value': 'review'},
    {'label': 'Featured', 'value': 'featured'},
    {'label': 'Trending', 'value': 'trending'},
  ];

  @override
  void initState() {
    super.initState();
    _loadRecipes();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadRecipes() {
    // Map 'featured'/'trending' tabs to separate filters
    String? status = _selectedStatus;
    bool? isFeatured;
    bool? isTrending;
    if (status == 'featured') {
      status = null;
      isFeatured = true;
    } else if (status == 'trending') {
      status = null;
      isTrending = true;
    }

    context.read<RecipeListBloc>().add(
          LoadRecipes(
            query: _searchQuery.isEmpty ? null : _searchQuery,
            status: status,
            sortBy: _sortBy,
            ascending: _ascending,
          ),
        );
  }

  void _onDeleteRecipe(Recipe recipe) async {
    final confirmed = await GetIt.I<DialogService>().showConfirmDialog(
      context: context,
      title: 'Delete Recipe',
      message: 'Are you sure you want to delete "${recipe.title}"?',
      confirmLabel: 'Delete',
      isDestructive: true,
    );
    if (confirmed && mounted) {
      context.read<RecipeListBloc>().add(DeleteRecipeRequested(recipe.id));
      GetIt.I<SnackbarService>().showSuccess('Recipe deleted successfully!');
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      body: Padding(
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
                        'LIBRARY',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.1,
                          color: primaryColor,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Recipes',
                        style: GoogleFonts.inter(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFF0F0F0F),
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      BlocBuilder<RecipeListBloc, RecipeListState>(
                        builder: (context, state) {
                          if (state is RecipeListLoaded) {
                            final total = state.recipes.length;
                            final featured = state.recipes.where((r) => r.isFeatured).length;
                            final trending = state.recipes.where((r) => r.isTrending).length;
                            final cuisines = state.recipes.map((r) => r.cuisine).toSet().length;
                            return Text(
                              '$total recipes · $featured featured · $trending trending across $cuisines cuisines.',
                              style: GoogleFonts.inter(
                                fontSize: 13.5,
                                color: const Color(0xFF8E8E8E),
                              ),
                            );
                          }
                          return Text(
                            'Manage your recipe library',
                            style: GoogleFonts.inter(fontSize: 13.5, color: const Color(0xFF8E8E8E)),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                // Export button
                _OutlineButton(
                  icon: Icons.download_rounded,
                  label: 'Export',
                  onTap: () {},
                ),
                const SizedBox(width: 10),
                // New Recipe button
                _PrimaryButton(
                  icon: Icons.add_rounded,
                  label: 'New Recipe',
                  onTap: () => context.go('/recipes/new'),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // ── Search / Filter / Sort bar ────────────────────────────────────
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  // Search
                  Expanded(
                    child: SizedBox(
                      height: 36,
                      child: TextField(
                        controller: _searchController,
                        onChanged: (val) {
                          setState(() => _searchQuery = val.trim());
                          _loadRecipes();
                        },
                        style: GoogleFonts.inter(fontSize: 13.5),
                        decoration: InputDecoration(
                          hintText: 'Search recipes...',
                          hintStyle: GoogleFonts.inter(
                            fontSize: 13.5,
                            color: const Color(0xFFADB5BD),
                          ),
                          prefixIcon: const Icon(Icons.search_rounded, size: 18, color: Color(0xFFADB5BD)),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Filters button
                  _FilterChip(
                    icon: Icons.tune_rounded,
                    label: 'Filters',
                    badge: _countActiveFilters() > 0 ? '${_countActiveFilters()}' : null,
                    onTap: _showFilterSheet,
                  ),
                  const SizedBox(width: 8),
                  // Sort button
                  _FilterChip(
                    icon: Icons.swap_vert_rounded,
                    label: 'Sort',
                    badge: null,
                    onTap: _showSortMenu,
                  ),
                  const SizedBox(width: 8),
                  // Refresh
                  InkWell(
                    onTap: _loadRecipes,
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.refresh_rounded, size: 16, color: Color(0xFF8E8E8E)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // ── Status Tabs ───────────────────────────────────────────────────
            Row(
              children: _tabs.map((tab) {
                final isActive = _selectedStatus == tab['value'];
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: GestureDetector(
                    onTap: () {
                      setState(() => _selectedStatus = tab['value'] as String?);
                      _loadRecipes();
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                      decoration: BoxDecoration(
                        color: isActive ? const Color(0xFF0F0F0F) : Colors.transparent,
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: Text(
                        tab['label'] as String,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                          color: isActive ? Colors.white : const Color(0xFF6C757D),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),

            // ── Table ─────────────────────────────────────────────────────────
            Expanded(
              child: BlocBuilder<RecipeListBloc, RecipeListState>(
                builder: (context, state) {
                  if (state is RecipeListLoading) return _buildShimmer();
                  if (state is RecipeListFailure) {
                    return ErrorState(message: state.error, onRetry: _loadRecipes);
                  }
                  if (state is RecipeListLoaded) {
                    final recipes = state.recipes;
                    if (recipes.isEmpty) {
                      return const EmptyState(
                        icon: Icons.restaurant_outlined,
                        title: 'No Recipes Found',
                        description: 'No recipes match your filters. Try clearing filters or create a new recipe.',
                      );
                    }
                    return _RecipeTable(
                      recipes: recipes,
                      selectedIds: _selectedIds,
                      onToggleSelect: (id) => setState(() {
                        if (_selectedIds.contains(id)) {
                          _selectedIds.remove(id);
                        } else {
                          _selectedIds.add(id);
                        }
                      }),
                      onPreview: (r) => context.go('/recipes/preview/${r.id}'),
                      onEdit: (r) => context.go('/recipes/edit/${r.id}'),
                      onDelete: _onDeleteRecipe,
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  int _countActiveFilters() {
    int count = 0;
    if (_searchQuery.isNotEmpty) count++;
    return count;
  }

  void _showFilterSheet() {
    // Placeholder — can be expanded
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Filter panel coming soon')),
    );
  }

  void _showSortMenu() {
    final items = {
      'created_at': 'Date Created',
      'title': 'Title',
      'rating': 'Rating',
      'total_time_minutes': 'Cook Time',
    };
    showMenu<String>(
      context: context,
      position: const RelativeRect.fromLTRB(200, 180, 0, 0),
      items: items.entries
          .map((e) => PopupMenuItem(
                value: e.key,
                child: Text(e.value, style: GoogleFonts.inter(fontSize: 13)),
              ))
          .toList(),
    ).then((val) {
      if (val != null) {
        setState(() => _sortBy = val);
        _loadRecipes();
      }
    });
  }

  Widget _buildShimmer() {
    return Column(
      children: List.generate(
        6,
        (_) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: ShimmerLoader(width: double.infinity, height: 56, borderRadius: 8),
        ),
      ),
    );
  }
}

// ── Recipe Data Table ─────────────────────────────────────────────────────────
class _RecipeTable extends StatelessWidget {
  final List<Recipe> recipes;
  final Set<String> selectedIds;
  final ValueChanged<String> onToggleSelect;
  final ValueChanged<Recipe> onPreview;
  final ValueChanged<Recipe> onEdit;
  final ValueChanged<Recipe> onDelete;

  const _RecipeTable({
    required this.recipes,
    required this.selectedIds,
    required this.onToggleSelect,
    required this.onPreview,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // Table header
          _TableHeader(),
          // Divider
          const Divider(height: 1, color: Color(0xFFE2E8F0)),
          // Rows
          Expanded(
            child: ListView.separated(
              itemCount: recipes.length,
              separatorBuilder: (_, __) => const Divider(height: 1, color: Color(0xFFF5F6F8)),
              itemBuilder: (context, index) {
                final recipe = recipes[index];
                return _RecipeRow(
                  recipe: recipe,
                  isSelected: selectedIds.contains(recipe.id),
                  onToggleSelect: () => onToggleSelect(recipe.id),
                  onPreview: () => onPreview(recipe),
                  onEdit: () => onEdit(recipe),
                  onDelete: () => onDelete(recipe),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _TableHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const labelStyle = TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.6,
      color: Color(0xFFADB5BD),
    );
    return Container(
      color: const Color(0xFFFAFAFA),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          const SizedBox(width: 24), // checkbox space
          const SizedBox(width: 48), // thumbnail
          const Expanded(flex: 5, child: Text('RECIPE', style: labelStyle)),
          const Expanded(flex: 2, child: Text('CUISINE', style: labelStyle)),
          const Expanded(flex: 2, child: Text('DIFFICULTY', style: labelStyle)),
          const Expanded(flex: 2, child: Text('COOK TIME', style: labelStyle)),
          const Expanded(flex: 2, child: Text('RATING', style: labelStyle)),
          const Expanded(flex: 2, child: Text('STATUS', style: labelStyle)),
          const SizedBox(width: 36, child: Text('FEAT.', style: labelStyle)),
          const SizedBox(width: 42, child: Text('TREND.', style: labelStyle)),
          const SizedBox(width: 72, child: Text('ACTIONS', style: labelStyle)),
        ],
      ),
    );
  }
}

class _RecipeRow extends StatefulWidget {
  final Recipe recipe;
  final bool isSelected;
  final VoidCallback onToggleSelect;
  final VoidCallback onPreview;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _RecipeRow({
    required this.recipe,
    required this.isSelected,
    required this.onToggleSelect,
    required this.onPreview,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  State<_RecipeRow> createState() => _RecipeRowState();
}

class _RecipeRowState extends State<_RecipeRow> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final r = widget.recipe;
    final primaryColor = Theme.of(context).primaryColor;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        color: _hovered ? const Color(0xFFFFF8F5) : Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Checkbox
            SizedBox(
              width: 24,
              child: Checkbox(
                value: widget.isSelected,
                onChanged: (_) => widget.onToggleSelect(),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                side: const BorderSide(color: Color(0xFFCDCDCD)),
                activeColor: primaryColor,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
            const SizedBox(width: 12),
            // Thumbnail
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: r.imageUrl.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: r.imageUrl,
                      width: 40,
                      height: 40,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => _placeholder(),
                      errorWidget: (_, __, ___) => _placeholder(),
                    )
                  : _placeholder(),
            ),
            const SizedBox(width: 12),
            // Recipe title + updated
            Expanded(
              flex: 5,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    r.title,
                    style: GoogleFonts.inter(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF0F0F0F),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Updated ${_timeAgo(r.createdAt.toIso8601String())}',
                    style: GoogleFonts.inter(fontSize: 11.5, color: const Color(0xFF8E8E8E)),
                  ),
                ],
              ),
            ),
            // Cuisine
            Expanded(
              flex: 2,
              child: Text(
                _capitalize(r.cuisine ?? 'Global'),
                style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF4E4E4E)),
              ),
            ),
            // Difficulty
            Expanded(
              flex: 2,
              child: Text(
                r.difficulty,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: _difficultyColor(r.difficulty),
                ),
              ),
            ),
            // Cook Time
            Expanded(
              flex: 2,
              child: Text(
                '${r.cookTimeMinutes} min',
                style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF4E4E4E)),
              ),
            ),
            // Rating
            Expanded(
              flex: 2,
              child: Row(
                children: [
                  const Icon(Icons.star_rounded, size: 14, color: Color(0xFFF59E0B)),
                  const SizedBox(width: 3),
                  Text(
                    r.rating.toStringAsFixed(1),
                    style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF4E4E4E)),
                  ),
                ],
              ),
            ),
            // Status pill
            Expanded(
              flex: 2,
              child: _StatusPill(status: r.status),
            ),
            // Featured star
            SizedBox(
              width: 36,
              child: Icon(
                r.isFeatured ? Icons.star_rounded : Icons.star_outline_rounded,
                size: 18,
                color: r.isFeatured ? const Color(0xFFF59E0B) : const Color(0xFFCDCDCD),
              ),
            ),
            // Trending fire
            SizedBox(
              width: 42,
              child: Icon(
                Icons.local_fire_department_rounded,
                size: 18,
                color: r.isTrending ? primaryColor : const Color(0xFFCDCDCD),
              ),
            ),
            // Action buttons
            SizedBox(
              width: 72,
              child: Row(
                children: [
                  _ActionIcon(
                    icon: Icons.visibility_outlined,
                    tooltip: 'Preview',
                    color: const Color(0xFF8E8E8E),
                    onTap: widget.onPreview,
                  ),
                  _ActionIcon(
                    icon: Icons.edit_outlined,
                    tooltip: 'Edit',
                    color: const Color(0xFF3B82F6),
                    onTap: widget.onEdit,
                  ),
                  _ActionIcon(
                    icon: Icons.delete_outline_rounded,
                    tooltip: 'Delete',
                    color: const Color(0xFFEF4444),
                    onTap: widget.onDelete,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder() => Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: const Color(0xFFF5F6F8),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.restaurant_rounded, size: 16, color: Color(0xFFADB5BD)),
      );

  String _timeAgo(String raw) {
    final dt = DateTime.tryParse(raw);
    if (dt == null) return 'recently';
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays == 1) return '1d ago';
    return '${diff.inDays}d ago';
  }

  String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1).toLowerCase();

  Color _difficultyColor(String d) {
    switch (d.toLowerCase()) {
      case 'easy':
        return const Color(0xFF3B9E74);
      case 'medium':
        return const Color(0xFFF59E0B);
      case 'hard':
        return const Color(0xFFEF4444);
      default:
        return const Color(0xFF6C757D);
    }
  }
}

// ── Status Pill ───────────────────────────────────────────────────────────────
class _StatusPill extends StatelessWidget {
  final String status;
  const _StatusPill({required this.status});

  @override
  Widget build(BuildContext context) {
    Color bg, fg;
    String label;
    switch (status.toLowerCase()) {
      case 'published':
        bg = const Color(0xFFEBFBEE); fg = const Color(0xFF2F9E44); label = 'Published'; break;
      case 'draft':
        bg = const Color(0xFFF5F6F8); fg = const Color(0xFF6C757D); label = 'Draft'; break;
      case 'review':
      case 'pending_review':
        bg = const Color(0xFFFFF9DB); fg = const Color(0xFFF59F00); label = 'Review'; break;
      default:
        bg = const Color(0xFFF5F6F8); fg = const Color(0xFF6C757D); label = status;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(50)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 6, height: 6, decoration: BoxDecoration(color: fg, shape: BoxShape.circle)),
          const SizedBox(width: 5),
          Text(label, style: GoogleFonts.inter(fontSize: 11.5, fontWeight: FontWeight.w600, color: fg)),
        ],
      ),
    );
  }
}

// ── Small Helpers ─────────────────────────────────────────────────────────────
class _ActionIcon extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final Color color;
  final VoidCallback onTap;
  const _ActionIcon({required this.icon, required this.tooltip, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Icon(icon, size: 16, color: color),
        ),
      ),
    );
  }
}

class _OutlineButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _OutlineButton({required this.icon, required this.label, required this.onTap});

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
            Text(label, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500, color: const Color(0xFF4E4E4E))),
          ],
        ),
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _PrimaryButton({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: primaryColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, size: 15, color: Colors.white),
            const SizedBox(width: 7),
            Text(label, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white)),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? badge;
  final VoidCallback onTap;
  const _FilterChip({required this.icon, required this.label, this.badge, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFE2E8F0)),
          borderRadius: BorderRadius.circular(8),
          color: Colors.white,
        ),
        child: Row(
          children: [
            Icon(icon, size: 15, color: const Color(0xFF6C757D)),
            const SizedBox(width: 6),
            Text(label, style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF4E4E4E))),
            if (badge != null) ...[
              const SizedBox(width: 6),
              Container(
                width: 18,
                height: 18,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  shape: BoxShape.circle,
                ),
                child: Text(badge!, style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
