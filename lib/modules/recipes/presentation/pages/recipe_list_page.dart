import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:get_it/get_it.dart';

import '../../../../core/services/dialog_service.dart';
import '../../../../core/services/snackbar_service.dart';
import '../../../../shared/widgets/badges/custom_badges.dart';
import '../../../../shared/widgets/buttons/custom_buttons.dart';
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
  String? _selectedCuisine;
  String? _selectedDifficulty;
  String? _selectedStatus;
  String _sortBy = 'created_at';
  bool _ascending = false;

  final List<String> _cuisines = ['Italian', 'Mexican', 'Indian', 'Japanese', 'Chinese', 'American', 'French', 'Mediterranean'];
  final List<String> _difficulties = ['Easy', 'Medium', 'Hard'];
  final List<String> _statuses = ['published', 'draft'];

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
    context.read<RecipeListBloc>().add(
          LoadRecipes(
            query: _searchQuery.isEmpty ? null : _searchQuery,
            cuisine: _selectedCuisine,
            difficulty: _selectedDifficulty,
            status: _selectedStatus,
            sortBy: _sortBy,
            ascending: _ascending,
          ),
        );
  }

  void _onDeleteRecipe(Recipe recipe) async {
    final confirmed = await GetIt.I<DialogService>().showConfirmDialog(
      context: context,
      title: 'Delete Recipe',
      message: 'Are you sure you want to delete "${recipe.title}"? This will soft-delete the recipe.',
      confirmLabel: 'Delete',
      isDestructive: true,
    );

    if (confirmed && mounted) {
      context.read<RecipeListBloc>().add(DeleteRecipeRequested(recipe.id));
      GetIt.I<SnackbarService>().showSuccess('Recipe soft-deleted successfully!');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF18181B) : Colors.white;
    final borderColor = isDark ? const Color(0xFF27272A) : const Color(0xFFE2E8F0);
    final titleColor = isDark ? Colors.white : const Color(0xFF0F172A);

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Recipe Management',
                      style: GoogleFonts.inter(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: titleColor,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Manage, review, edit, and publish recipe entries to the mobile platform.',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: isDark ? const Color(0xFFA1A1AA) : const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
                PrimaryButton(
                  label: 'Add Recipe',
                  icon: Icons.add,
                  onPressed: () => context.go('/recipes/new'),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // 2. Filters Row
            Wrap(
              spacing: 12,
              runSpacing: 12,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                // Search field
                SizedBox(
                  width: 260,
                  child: TextField(
                    controller: _searchController,
                    onChanged: (val) {
                      setState(() {
                        _searchQuery = val.trim();
                      });
                      _loadRecipes();
                    },
                    decoration: InputDecoration(
                      hintText: 'Search recipe title...',
                      prefixIcon: const Icon(Icons.search, size: 20),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 18),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {
                                  _searchQuery = '';
                                });
                                _loadRecipes();
                              },
                            )
                          : null,
                    ),
                  ),
                ),
                // Cuisine Dropdown
                DropdownButton<String>(
                  value: _selectedCuisine,
                  hint: const Text('Cuisine'),
                  underline: const SizedBox(),
                  onChanged: (val) {
                    setState(() => _selectedCuisine = val);
                    _loadRecipes();
                  },
                  items: [
                    const DropdownMenuItem<String>(value: null, child: Text('All Cuisines')),
                    ..._cuisines.map((c) => DropdownMenuItem<String>(value: c, child: Text(c))),
                  ],
                ),
                // Difficulty Dropdown
                DropdownButton<String>(
                  value: _selectedDifficulty,
                  hint: const Text('Difficulty'),
                  underline: const SizedBox(),
                  onChanged: (val) {
                    setState(() => _selectedDifficulty = val);
                    _loadRecipes();
                  },
                  items: [
                    const DropdownMenuItem<String>(value: null, child: Text('All Difficulties')),
                    ..._difficulties.map((d) => DropdownMenuItem<String>(value: d, child: Text(d))),
                  ],
                ),
                // Status Dropdown
                DropdownButton<String>(
                  value: _selectedStatus,
                  hint: const Text('Status'),
                  underline: const SizedBox(),
                  onChanged: (val) {
                    setState(() => _selectedStatus = val);
                    _loadRecipes();
                  },
                  items: [
                    const DropdownMenuItem<String>(value: null, child: Text('All Statuses')),
                    ..._statuses.map((s) => DropdownMenuItem<String>(value: s, child: Text(s.toUpperCase()))),
                  ],
                ),
                // Sort order dropdown
                DropdownButton<String>(
                  value: _sortBy,
                  underline: const SizedBox(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() => _sortBy = val);
                      _loadRecipes();
                    }
                  },
                  items: const [
                    DropdownMenuItem<String>(value: 'created_at', child: Text('Date Created')),
                    DropdownMenuItem<String>(value: 'title', child: Text('Title')),
                    DropdownMenuItem<String>(value: 'prep_time_minutes', child: Text('Prep Time')),
                    DropdownMenuItem<String>(value: 'rating', child: Text('Rating')),
                  ],
                ),
                // Sort ascending/descending toggle
                IconButton(
                  icon: Icon(_ascending ? Icons.arrow_upward : Icons.arrow_downward, size: 20),
                  onPressed: () {
                    setState(() => _ascending = !_ascending);
                    _loadRecipes();
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),

            // 3. Table list
            Expanded(
              child: BlocBuilder<RecipeListBloc, RecipeListState>(
                builder: (context, state) {
                  if (state is RecipeListLoading) {
                    return _buildShimmerTable();
                  } else if (state is RecipeListFailure) {
                    return ErrorState(
                      message: state.error,
                      onRetry: _loadRecipes,
                    );
                  } else if (state is RecipeListLoaded) {
                    final recipes = state.recipes;

                    if (recipes.isEmpty) {
                      return const EmptyState(
                        icon: Icons.restaurant_outlined,
                        title: 'No Recipes Found',
                        description: 'No recipes match your filter options. Try clearing filters or create a new recipe.',
                      );
                    }

                    return Container(
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: borderColor),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: SingleChildScrollView(
                          child: DataTable(
                            headingRowColor: WidgetStateProperty.all(
                              isDark ? const Color(0xFF09090B) : const Color(0xFFF8FAFC),
                            ),
                            columns: [
                              DataColumn(
                                label: Text(
                                  'Recipe Details',
                                  style: GoogleFonts.inter(fontWeight: FontWeight.bold),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  'Cuisine',
                                  style: GoogleFonts.inter(fontWeight: FontWeight.bold),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  'Difficulty',
                                  style: GoogleFonts.inter(fontWeight: FontWeight.bold),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  'Rating',
                                  style: GoogleFonts.inter(fontWeight: FontWeight.bold),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  'Status',
                                  style: GoogleFonts.inter(fontWeight: FontWeight.bold),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  'Actions',
                                  style: GoogleFonts.inter(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                            rows: recipes.map((recipe) {
                              return DataRow(
                                cells: [
                                  // Details Cell
                                  DataCell(
                                    Row(
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(4),
                                          child: recipe.imageUrl.isNotEmpty
                                              ? CachedNetworkImage(
                                                  imageUrl: recipe.imageUrl,
                                                  width: 36,
                                                  height: 36,
                                                  fit: BoxFit.cover,
                                                  errorWidget: (c, u, e) => Container(
                                                    width: 36,
                                                    height: 36,
                                                    color: Colors.grey[200],
                                                    child: const Icon(Icons.restaurant, size: 16),
                                                  ),
                                                )
                                              : Container(
                                                  width: 36,
                                                  height: 36,
                                                  color: Colors.grey[200],
                                                  child: const Icon(Icons.restaurant, size: 16),
                                                ),
                                        ),
                                        const SizedBox(width: 12),
                                        Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              recipe.title,
                                              style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                                            ),
                                            Text(
                                              '${recipe.prepTime} Prep • ${recipe.cookTime} Cook',
                                              style: GoogleFonts.inter(color: Colors.grey, fontSize: 11),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Cuisine
                                  DataCell(Text(recipe.cuisine ?? 'Global')),
                                  // Difficulty
                                  DataCell(Text(recipe.difficulty)),
                                  // Rating
                                  DataCell(
                                    Row(
                                      children: [
                                        const Icon(Icons.star, size: 16, color: Colors.amber),
                                        const SizedBox(width: 4),
                                        Text(
                                          '${recipe.rating}',
                                          style: GoogleFonts.inter(fontWeight: FontWeight.w500),
                                        ),
                                        Text(
                                          ' (${recipe.reviewsCount})',
                                          style: GoogleFonts.inter(fontSize: 12, color: Colors.grey),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Status
                                  DataCell(StatusBadge(status: recipe.status)),
                                  // Actions
                                  DataCell(
                                    Row(
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.visibility_outlined, color: Colors.grey),
                                          tooltip: 'Preview Details',
                                          onPressed: () => context.go('/recipes/preview/${recipe.id}'),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.edit_outlined, color: Colors.blue),
                                          tooltip: 'Edit Recipe',
                                          onPressed: () => context.go('/recipes/edit/${recipe.id}'),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete_outline, color: Colors.red),
                                          tooltip: 'Delete Recipe',
                                          onPressed: () => _onDeleteRecipe(recipe),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                      ),
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

  Widget _buildShimmerTable() {
    return Column(
      children: List.generate(
        6,
        (index) => Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: ShimmerLoader(width: double.infinity, height: 50, borderRadius: 6),
        ),
      ),
    );
  }
}
