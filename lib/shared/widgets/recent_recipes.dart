import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../shared/widgets/badges/custom_badges.dart';

class RecentRecipes extends StatelessWidget {
  final List<dynamic> recipes;

  const RecentRecipes({super.key, required this.recipes});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF18181B) : Colors.white;
    final borderColor = isDark ? const Color(0xFF27272A) : const Color(0xFFE2E8F0);
    final titleColor = isDark ? Colors.white : const Color(0xFF0F172A);

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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recently Added Recipes',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: titleColor,
                ),
              ),
              TextButton(
                onPressed: () => context.go('/recipes'),
                child: Text(
                  'View All',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (recipes.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 32),
                child: Text(
                  'No recipes added yet.',
                  style: GoogleFonts.inter(color: Colors.grey),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: recipes.length,
              separatorBuilder: (context, index) => const Divider(height: 16),
              itemBuilder: (context, index) {
                final recipe = recipes[index];
                final String title = recipe['title'] as String? ?? 'Untitled Recipe';
                final String cuisine = recipe['cuisine'] as String? ?? 'Global';
                final String difficulty = recipe['difficulty'] as String? ?? 'Easy';
                final String status = recipe['status'] as String? ?? 'published';
                final String imageUrl = recipe['thumbnail_image_url'] as String? ?? '';
                final String recipeId = recipe['id'] as String? ?? '';

                return Row(
                  children: [
                    // Recipe Image Thumbnail
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: imageUrl.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: imageUrl,
                              width: 48,
                              height: 48,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                width: 48,
                                height: 48,
                                color: Colors.grey[200],
                              ),
                              errorWidget: (context, url, error) => Container(
                                width: 48,
                                height: 48,
                                color: Colors.grey[300],
                                child: const Icon(Icons.restaurant, size: 20, color: Colors.grey),
                              ),
                            )
                          : Container(
                              width: 48,
                              height: 48,
                              color: Colors.grey[200],
                              child: const Icon(Icons.restaurant, size: 20, color: Colors.grey),
                            ),
                    ),
                    const SizedBox(width: 16),
                    // Title and Metadata
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$cuisine • $difficulty',
                            style: GoogleFonts.inter(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Status Badge
                    StatusBadge(status: status),
                    const SizedBox(width: 12),
                    // Actions Button
                    IconButton(
                      icon: const Icon(Icons.chevron_right),
                      onPressed: () {
                        if (recipeId.isNotEmpty) {
                          context.go('/recipes/preview/$recipeId');
                        }
                      },
                    ),
                  ],
                );
              },
            ),
        ],
      ),
    );
  }
}
