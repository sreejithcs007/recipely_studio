import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/dependency_injection.dart';
import '../../../../shared/widgets/loading/shimmers.dart';

// ── Self-contained state ───────────────────────────────────────────────────────
class TrendingPage extends StatefulWidget {
  const TrendingPage({super.key});

  @override
  State<TrendingPage> createState() => _TrendingPageState();
}

class _TrendingPageState extends State<TrendingPage> {
  List<Map<String, dynamic>> _recipes = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final response = await sl<SupabaseClient>()
          .from('recipes')
          .select(
              'id, title, cuisine, cook_time_minutes, rating, status, '
              'is_trending, thumbnail_image_url, created_at')
          .eq('is_trending', true)
          .isFilter('deleted_at', null)
          .order('created_at', ascending: true);

      setState(() {
        _recipes = List<Map<String, dynamic>>.from(response);
        _loading = false;
      });
    } catch (e) {
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  Future<void> _removeTrending(String id) async {
    await sl<SupabaseClient>()
        .from('recipes')
        .update({'is_trending': false})
        .eq('id', id);
    _load();
  }

  // Pastel backgrounds cycling per card
  static const _cardBgs = [
    Color(0xFFFFF3DC),
    Color(0xFFFFE8EC),
    Color(0xFFE8F5E9),
    Color(0xFFFFEDE0),
    Color(0xFFE8EAF6),
    Color(0xFFE0F7FA),
  ];

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
            // ── Header ────────────────────────────────────────────────────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'SIGNALS',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.1,
                          color: primaryColor,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Trending recipes',
                        style: GoogleFonts.inter(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFF0F0F0F),
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Recipes currently trending across the mobile app.',
                        style: GoogleFonts.inter(
                          fontSize: 13.5,
                          color: const Color(0xFF8E8E8E),
                        ),
                      ),
                    ],
                  ),
                ),
                InkWell(
                  onTap: () => context.go('/recipes'),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
                    decoration: BoxDecoration(
                      color: primaryColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.add_rounded, size: 16, color: Colors.white),
                        const SizedBox(width: 8),
                        Text(
                          'Add to trending',
                          style: GoogleFonts.inter(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // ── Grid ──────────────────────────────────────────────────────────
            Expanded(
              child: _loading
                  ? GridView.builder(
                      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 360,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        childAspectRatio: 0.78,
                      ),
                      itemCount: 6,
                      itemBuilder: (_, __) => ShimmerLoader(
                        width: double.infinity,
                        height: double.infinity,
                        borderRadius: 16,
                      ),
                    )
                  : _error != null
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.error_outline_rounded, size: 48, color: Color(0xFFEF4444)),
                              const SizedBox(height: 12),
                              Text(_error!, style: GoogleFonts.inter(color: const Color(0xFF6C757D))),
                              const SizedBox(height: 16),
                              TextButton.icon(
                                onPressed: _load,
                                icon: const Icon(Icons.refresh_rounded),
                                label: const Text('Retry'),
                              ),
                            ],
                          ),
                        )
                      : _recipes.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.local_fire_department_outlined, size: 56, color: Colors.grey[300]),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No trending recipes yet',
                                    style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: const Color(0xFF6C757D)),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Go to Recipes and mark some as trending.',
                                    style: GoogleFonts.inter(fontSize: 13.5, color: const Color(0xFFADB5BD)),
                                  ),
                                  const SizedBox(height: 20),
                                  TextButton.icon(
                                    onPressed: () => context.go('/recipes'),
                                    icon: const Icon(Icons.arrow_forward_rounded),
                                    label: const Text('Go to Recipes'),
                                    style: TextButton.styleFrom(foregroundColor: primaryColor),
                                  ),
                                ],
                              ),
                            )
                          : GridView.builder(
                              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                                maxCrossAxisExtent: 360,
                                mainAxisSpacing: 16,
                                crossAxisSpacing: 16,
                                childAspectRatio: 0.78,
                              ),
                              itemCount: _recipes.length,
                              itemBuilder: (context, index) {
                                final r = _recipes[index];
                                final bg = _cardBgs[index % _cardBgs.length];
                                return _TrendingCard(
                                  recipe: r,
                                  position: index + 1,
                                  cardBg: bg,
                                  onRemove: () => _removeTrending(r['id'] as String),
                                  onEdit: () => context.go('/recipes/edit/${r['id']}'),
                                );
                              },
                            ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Trending Card — same layout as FeaturedCard but with 🔥 badge ──────────────
class _TrendingCard extends StatefulWidget {
  final Map<String, dynamic> recipe;
  final int position;
  final Color cardBg;
  final VoidCallback onRemove;
  final VoidCallback onEdit;

  const _TrendingCard({
    required this.recipe,
    required this.position,
    required this.cardBg,
    required this.onRemove,
    required this.onEdit,
  });

  @override
  State<_TrendingCard> createState() => _TrendingCardState();
}

class _TrendingCardState extends State<_TrendingCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final r = widget.recipe;
    final String title = r['title'] as String? ?? 'Untitled';
    final String cuisine = (r['cuisine'] as String? ?? 'Global').toUpperCase();
    final String status = r['status'] as String? ?? 'published';
    final double rating = (r['rating'] as num?)?.toDouble() ?? 0.0;
    final int cookTime = (r['cook_time_minutes'] as int?) ?? 0;
    final String imageUrl = r['thumbnail_image_url'] as String? ?? '';
    final primaryColor = Theme.of(context).primaryColor;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        transform: _hovered
            ? (Matrix4.identity()..translate(0.0, -4.0))
            : Matrix4.identity(),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _hovered
                ? primaryColor.withOpacity(0.3)
                : const Color(0xFFE2E8F0),
          ),
          boxShadow: _hovered
              ? [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 16, offset: const Offset(0, 8))]
              : [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 4)],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Image area ──────────────────────────────────────────────────
            Expanded(
              child: Stack(
                children: [
                  // Background fill
                  Positioned.fill(
                    child: Container(color: widget.cardBg),
                  ),
                  // Full-bleed cover image
                  if (imageUrl.isNotEmpty)
                    Positioned.fill(
                      child: CachedNetworkImage(
                        imageUrl: imageUrl,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => Container(color: widget.cardBg),
                        errorWidget: (_, __, ___) => Center(
                          child: Icon(Icons.restaurant_rounded, size: 56, color: Colors.grey[400]),
                        ),
                      ),
                    )
                  else
                    Center(
                      child: Icon(Icons.restaurant_rounded, size: 56, color: Colors.grey[400]),
                    ),
                  // Position badge — top left
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: primaryColor,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '#${widget.position}',
                        style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white),
                      ),
                    ),
                  ),
                  // Trending badge — top right (🔥 orange/red)
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEF4444),
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.local_fire_department_rounded, size: 11, color: Colors.white),
                          const SizedBox(width: 4),
                          Text(
                            'Trending',
                            style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Context menu — bottom right
                  Positioned(
                    bottom: 10,
                    right: 10,
                    child: _ContextMenuButton(onEdit: widget.onEdit, onRemove: widget.onRemove),
                  ),
                ],
              ),
            ),

            // ── Info area ───────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    cuisine,
                    style: GoogleFonts.inter(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                      color: primaryColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF0F0F0F),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.star_rounded, size: 13, color: Color(0xFFF59E0B)),
                          const SizedBox(width: 3),
                          Text(
                            '${rating.toStringAsFixed(1)} · ${cookTime > 0 ? '$cookTime min' : '—'}',
                            style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF8E8E8E)),
                          ),
                        ],
                      ),
                      _StatusPill(status: status),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Context Menu ──────────────────────────────────────────────────────────────
class _ContextMenuButton extends StatelessWidget {
  final VoidCallback onEdit;
  final VoidCallback onRemove;

  const _ContextMenuButton({required this.onEdit, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: (val) {
        if (val == 'edit') onEdit();
        if (val == 'remove') onRemove();
      },
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 6,
      itemBuilder: (_) => [
        PopupMenuItem(
          value: 'edit',
          child: Row(
            children: [
              const Icon(Icons.edit_outlined, size: 15, color: Color(0xFF3B82F6)),
              const SizedBox(width: 8),
              Text('Edit recipe', style: GoogleFonts.inter(fontSize: 13)),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'remove',
          child: Row(
            children: [
              const Icon(Icons.local_fire_department_outlined, size: 15, color: Color(0xFFEF4444)),
              const SizedBox(width: 8),
              Text('Remove from trending', style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFFEF4444))),
            ],
          ),
        ),
      ],
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 6)],
        ),
        child: const Icon(Icons.more_horiz_rounded, size: 16, color: Color(0xFF4E4E4E)),
      ),
    );
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
      default:
        bg = const Color(0xFFFFF9DB); fg = const Color(0xFFF59F00); label = 'Review';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(50)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 5, height: 5, decoration: BoxDecoration(color: fg, shape: BoxShape.circle)),
          const SizedBox(width: 4),
          Text(label, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: fg)),
        ],
      ),
    );
  }
}
