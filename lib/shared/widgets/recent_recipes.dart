import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';

class RecentRecipes extends StatelessWidget {
  final List<dynamic> recipes;

  const RecentRecipes({super.key, required this.recipes});

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Recently updated',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: const Color(0xFF8E8E8E),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Latest recipes',
                    style: GoogleFonts.inter(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF0F0F0F),
                      letterSpacing: -0.3,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () => context.go('/recipes'),
                child: Text(
                  'View all',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: primaryColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (recipes.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: Center(
                child: Text(
                  'No recipes yet.',
                  style: GoogleFonts.inter(color: const Color(0xFFADB5BD)),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: recipes.length,
              separatorBuilder: (_, __) => const Divider(height: 1, color: Color(0xFFF5F6F8)),
              itemBuilder: (context, index) {
                final recipe = recipes[index];
                final String title = recipe['title'] as String? ?? 'Untitled Recipe';
                final String cuisine = recipe['cuisine'] as String? ?? 'Global';
                final String status = recipe['status'] as String? ?? 'published';
                final String imageUrl = recipe['thumbnail_image_url'] as String? ?? '';
                final String recipeId = recipe['id'] as String? ?? '';
                final double rating = (recipe['rating'] as num?)?.toDouble() ?? 4.5;
                final String createdAt = recipe['created_at'] as String? ?? '';
                final String timeAgo = _timeAgo(createdAt);
                final int totalTime = (recipe['total_time_minutes'] ?? 0) as int;

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    children: [
                      // Thumbnail
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: imageUrl.isNotEmpty
                            ? CachedNetworkImage(
                                imageUrl: imageUrl,
                                width: 46,
                                height: 46,
                                fit: BoxFit.cover,
                                placeholder: (_, __) => _imagePlaceholder(),
                                errorWidget: (_, __, ___) => _imagePlaceholder(),
                              )
                            : _imagePlaceholder(),
                      ),
                      const SizedBox(width: 12),
                      // Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.w600,
                                fontSize: 13.5,
                                color: const Color(0xFF0F0F0F),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 3),
                            Text(
                              '${_capitalize(cuisine)} · ${totalTime > 0 ? '$totalTime min' : '30 min'} · Updated $timeAgo',
                              style: GoogleFonts.inter(
                                fontSize: 11.5,
                                color: const Color(0xFF8E8E8E),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Status badge
                      _StatusPill(status: status),
                      const SizedBox(width: 12),
                      // Star rating
                      Row(
                        children: [
                          const Icon(Icons.star_rounded, color: Color(0xFFF59E0B), size: 14),
                          const SizedBox(width: 3),
                          Text(
                            rating.toStringAsFixed(1),
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF4E4E4E),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _imagePlaceholder() {
    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        color: const Color(0xFFF5F6F8),
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Icon(Icons.restaurant_rounded, size: 18, color: Color(0xFFADB5BD)),
    );
  }

  String _timeAgo(String rawDate) {
    if (rawDate.isEmpty) return 'recently';
    final dt = DateTime.tryParse(rawDate);
    if (dt == null) return 'recently';
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays == 1) return '1d ago';
    return '${diff.inDays}d ago';
  }

  String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1).toLowerCase();
}

class _StatusPill extends StatelessWidget {
  final String status;

  const _StatusPill({required this.status});

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    String label;

    switch (status.toLowerCase()) {
      case 'published':
        bg = const Color(0xFFEBFBEE);
        fg = const Color(0xFF2F9E44);
        label = 'Published';
        break;
      case 'draft':
        bg = const Color(0xFFF5F6F8);
        fg = const Color(0xFF6C757D);
        label = 'Draft';
        break;
      case 'review':
      case 'pending_review':
        bg = const Color(0xFFFFF9DB);
        fg = const Color(0xFFF59F00);
        label = 'Review';
        break;
      default:
        bg = const Color(0xFFF5F6F8);
        fg = const Color(0xFF6C757D);
        label = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(50),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: fg, shape: BoxShape.circle),
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }
}
