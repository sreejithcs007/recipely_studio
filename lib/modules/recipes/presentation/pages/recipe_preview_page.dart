import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get_it/get_it.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../../core/services/dialog_service.dart';
import '../../../../core/services/snackbar_service.dart';
import '../../../../shared/widgets/badges/custom_badges.dart';
import '../../../../shared/widgets/buttons/custom_buttons.dart';
import '../../../../shared/widgets/error_states/error_state.dart';
import '../../../../shared/widgets/loading/shimmers.dart';
import '../../domain/entities/recipe.dart';
import '../../domain/repositories/recipe_repository.dart';

class RecipePreviewPage extends StatefulWidget {
  final String recipeId;

  const RecipePreviewPage({super.key, required this.recipeId});

  @override
  State<RecipePreviewPage> createState() => _RecipePreviewPageState();
}

class _RecipePreviewPageState extends State<RecipePreviewPage> {
  Recipe? _recipe;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadRecipe();
  }

  Future<void> _loadRecipe() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final repo = GetIt.I<RecipeRepository>();
      final r = await repo.getRecipeById(widget.recipeId);
      setState(() {
        _recipe = r;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _onDeleteRecipe() async {
    if (_recipe == null) return;
    final confirmed = await GetIt.I<DialogService>().showConfirmDialog(
      context: context,
      title: 'Delete Recipe',
      message: 'Are you sure you want to delete "${_recipe!.title}"?',
      confirmLabel: 'Delete',
      isDestructive: true,
    );

    if (confirmed) {
      try {
        final repo = GetIt.I<RecipeRepository>();
        await repo.deleteRecipe(_recipe!.id);
        if (mounted) {
          GetIt.I<SnackbarService>().showSuccess('Recipe deleted successfully!');
          context.go('/recipes');
        }
      } catch (e) {
        GetIt.I<SnackbarService>().showError('Failed to delete recipe: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF18181B) : Colors.white;
    final borderColor = isDark ? const Color(0xFF27272A) : const Color(0xFFE2E8F0);
    final titleColor = isDark ? Colors.white : const Color(0xFF0F172A);

    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_error != null || _recipe == null) {
      return Scaffold(
        body: ErrorState(
          message: _error ?? 'Recipe not found',
          onRetry: _loadRecipe,
        ),
      );
    }

    final recipe = _recipe!;
    final isWide = MediaQuery.of(context).size.width > 900;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/recipes'),
        ),
        title: Text(
          recipe.title,
          style: GoogleFonts.inter(fontWeight: FontWeight.bold),
        ),
        actions: [
          OutlineBtn(
            label: 'Delete',
            icon: Icons.delete_outline,
            textColor: Colors.red,
            borderColor: Colors.red.withOpacity(0.5),
            onPressed: _onDeleteRecipe,
          ),
          const SizedBox(width: 12),
          PrimaryButton(
            label: 'Edit Recipe',
            icon: Icons.edit,
            onPressed: () => context.go('/recipes/edit/${recipe.id}'),
          ),
          const SizedBox(width: 24),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32.0),
        child: isWide
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left column (General Info)
                  Expanded(
                    flex: 1,
                    child: _buildGeneralInfo(recipe, isDark, cardBg, borderColor, titleColor),
                  ),
                  const SizedBox(width: 32),
                  // Right column (Ingredients & Steps)
                  Expanded(
                    flex: 2,
                    child: _buildIngredientsAndSteps(recipe, isDark, cardBg, borderColor, titleColor),
                  ),
                ],
              )
            : Column(
                children: [
                  _buildGeneralInfo(recipe, isDark, cardBg, borderColor, titleColor),
                  const SizedBox(height: 32),
                  _buildIngredientsAndSteps(recipe, isDark, cardBg, borderColor, titleColor),
                ],
              ),
      ),
    );
  }

  Widget _buildGeneralInfo(Recipe recipe, bool isDark, Color cardBg, Color borderColor, Color titleColor) {
    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner Image
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: recipe.imageUrl.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: recipe.imageUrl,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorWidget: (c, u, e) => Container(
                      height: 200,
                      color: Colors.grey[200],
                      child: const Icon(Icons.broken_image, size: 40),
                    ),
                  )
                : Container(
                    height: 200,
                    color: Colors.grey[200],
                    child: const Icon(Icons.restaurant, size: 40),
                  ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              StatusBadge(status: recipe.status),
              const SizedBox(width: 8),
              if (recipe.isFeatured) const FeaturedBadge(),
              const SizedBox(width: 8),
              if (recipe.isTrending) const TrendingBadge(),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            recipe.title,
            style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold, color: titleColor),
          ),
          const SizedBox(height: 8),
          Text(
            recipe.description,
            style: GoogleFonts.inter(fontSize: 14, color: Colors.grey[600]),
          ),
          const Divider(height: 32),
          _buildDetailRow('Prep Time', recipe.prepTime),
          _buildDetailRow('Cook Time', recipe.cookTime),
          _buildDetailRow('Total Time', recipe.totalTime),
          _buildDetailRow('Calories', recipe.calories),
          _buildDetailRow('Servings', recipe.servings),
          _buildDetailRow('Difficulty', recipe.difficulty),
          _buildDetailRow('Spicy Level', '${recipe.spiceLevel} / 3'),
          _buildDetailRow('Rating', '${recipe.rating} ★'),
          _buildDetailRow('Cuisine', recipe.cuisine ?? 'Global'),
          _buildDetailRow('Estimated Cost', '\$${recipe.estimatedCost.toStringAsFixed(2)}'),
          const Divider(height: 32),
          Text(
            'Categories & Tags',
            style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ...recipe.categories.map((c) => Chip(
                    label: Text(c, style: const TextStyle(fontSize: 11)),
                    backgroundColor: Colors.orange.withOpacity(0.1),
                    side: BorderSide.none,
                  )),
              ...recipe.tags.map((t) => Chip(
                    label: Text(t, style: const TextStyle(fontSize: 11)),
                    backgroundColor: Colors.blue.withOpacity(0.1),
                    side: BorderSide.none,
                  )),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIngredientsAndSteps(Recipe recipe, bool isDark, Color cardBg, Color borderColor, Color titleColor) {
    return Column(
      children: [
        // Ingredients
        Container(
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor),
          ),
          padding: const EdgeInsets.all(24),
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Ingredients checklist',
                style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: titleColor),
              ),
              const SizedBox(height: 16),
              if (recipe.ingredients.isEmpty)
                Text('No ingredients declared.', style: GoogleFonts.inter(color: Colors.grey))
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: recipe.ingredients.length,
                  separatorBuilder: (context, index) => const Divider(height: 12),
                  itemBuilder: (context, index) {
                    final ing = recipe.ingredients[index];
                    return Row(
                      children: [
                        const Icon(Icons.circle, size: 8, color: Colors.deepOrange),
                        const SizedBox(width: 12),
                        Text(
                          '${ing.quantity} ${ing.unit ?? ''}',
                          style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          ing.name,
                          style: GoogleFonts.inter(fontSize: 14),
                        ),
                        if (ing.isOptional) ...[
                          const SizedBox(width: 8),
                          Text(
                            '(optional)',
                            style: GoogleFonts.inter(fontSize: 12, fontStyle: FontStyle.italic, color: Colors.grey),
                          ),
                        ],
                      ],
                    );
                  },
                ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        // Steps
        Container(
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor),
          ),
          padding: const EdgeInsets.all(24),
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Instructions steps',
                style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: titleColor),
              ),
              const SizedBox(height: 16),
              if (recipe.steps.isEmpty)
                Text('No instruction steps declared.', style: GoogleFonts.inter(color: Colors.grey))
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: recipe.steps.length,
                  separatorBuilder: (context, index) => const Divider(height: 24),
                  itemBuilder: (context, index) {
                    final step = recipe.steps[index];
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 12,
                          backgroundColor: Colors.deepOrange.withOpacity(0.1),
                          child: Text(
                            '${step.stepNumber}',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.deepOrange,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            step.content,
                            style: GoogleFonts.inter(fontSize: 14, height: 1.5),
                          ),
                        ),
                      ],
                    );
                  },
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.inter(fontSize: 13, color: Colors.grey)),
          Text(value, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
