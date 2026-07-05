import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/di/dependency_injection.dart';
import '../../../../shared/widgets/error_states/error_state.dart';
import '../../../../shared/widgets/loading/shimmers.dart';

// ── Simple self-contained BLoC ─────────────────────────────────────────────

abstract class FeaturedEvent {}

class LoadFeaturedRecipes extends FeaturedEvent {}

class ToggleFeatured extends FeaturedEvent {
  final String recipeId;
  final bool currentValue;
  ToggleFeatured(this.recipeId, this.currentValue);
}

abstract class FeaturedState {}

class FeaturedLoading extends FeaturedState {}

class FeaturedLoaded extends FeaturedState {
  final List<Map<String, dynamic>> recipes;
  FeaturedLoaded(this.recipes);
}

class FeaturedError extends FeaturedState {
  final String message;
  FeaturedError(this.message);
}

class FeaturedBloc extends Bloc<FeaturedEvent, FeaturedState> {
  final SupabaseClient _client;

  FeaturedBloc(this._client) : super(FeaturedLoading()) {
    on<LoadFeaturedRecipes>(_onLoad);
    on<ToggleFeatured>(_onToggle);
  }

  Future<void> _onLoad(LoadFeaturedRecipes event, Emitter<FeaturedState> emit) async {
    emit(FeaturedLoading());
    try {
      final response = await _client
          .from('recipes')
          .select('id, title, cuisine, difficulty, rating, cook_time_minutes, status, is_featured, is_trending, thumbnail_image_url, created_at')
          .eq('is_featured', true)
          .isFilter('deleted_at', null)
          .order('created_at', ascending: true);

      emit(FeaturedLoaded(List<Map<String, dynamic>>.from(response)));
    } catch (e) {
      emit(FeaturedError(e.toString()));
    }
  }

  Future<void> _onToggle(ToggleFeatured event, Emitter<FeaturedState> emit) async {
    try {
      await _client
          .from('recipes')
          .update({'is_featured': !event.currentValue})
          .eq('id', event.recipeId);
      add(LoadFeaturedRecipes());
    } catch (e) {
      emit(FeaturedError(e.toString()));
    }
  }
}

// ── Page ───────────────────────────────────────────────────────────────────

class FeaturedPage extends StatelessWidget {
  const FeaturedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => FeaturedBloc(sl<SupabaseClient>())..add(LoadFeaturedRecipes()),
      child: const _FeaturedView(),
    );
  }
}

class _FeaturedView extends StatelessWidget {
  const _FeaturedView();

  // Cycling pastel backgrounds for cards
  static const _cardBgs = [
    Color(0xFFFFF3DC), // warm yellow
    Color(0xFFFFE8EC), // soft pink
    Color(0xFFE8F5E9), // light green
    Color(0xFFFFEDE0), // peach
    Color(0xFFE8EAF6), // lavender
    Color(0xFFE0F7FA), // cyan
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
            // ── Header ──────────────────────────────────────────────────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'CURATION',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.1,
                          color: primaryColor,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Featured recipes',
                        style: GoogleFonts.inter(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFF0F0F0F),
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Reorder the recipes shown on the home shelf across the mobile app.',
                        style: GoogleFonts.inter(fontSize: 13.5, color: const Color(0xFF8E8E8E)),
                      ),
                    ],
                  ),
                ),
                // Add to featured button
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
                          'Add to featured',
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

            // ── Grid ────────────────────────────────────────────────────────
            Expanded(
              child: BlocBuilder<FeaturedBloc, FeaturedState>(
                builder: (context, state) {
                  if (state is FeaturedLoading) {
                    return GridView.builder(
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
                    );
                  }

                  if (state is FeaturedError) {
                    return ErrorState(
                      message: state.message,
                      onRetry: () => context.read<FeaturedBloc>().add(LoadFeaturedRecipes()),
                    );
                  }

                  if (state is FeaturedLoaded) {
                    final recipes = state.recipes;

                    if (recipes.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.star_border_rounded, size: 56, color: Colors.grey[300]),
                            const SizedBox(height: 16),
                            Text(
                              'No featured recipes yet',
                              style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: const Color(0xFF6C757D)),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Go to Recipes and mark some as featured.',
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
                      );
                    }

                    return Column(
                      children: [
                        Expanded(
                          child: GridView.builder(
                            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                              maxCrossAxisExtent: 360,
                              mainAxisSpacing: 16,
                              crossAxisSpacing: 16,
                              childAspectRatio: 0.78,
                            ),
                            itemCount: recipes.length,
                            itemBuilder: (context, index) {
                              final r = recipes[index];
                              final bg = _cardBgs[index % _cardBgs.length];
                              return _FeaturedCard(
                                recipe: r,
                                position: index + 1,
                                cardBg: bg,
                                onUnfeature: () {
                                  context.read<FeaturedBloc>().add(
                                    ToggleFeatured(r['id'] as String, true),
                                  );
                                },
                                onEdit: () => context.go('/recipes/edit/${r['id']}'),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Auto-refresh banner
                        _AutoRefreshBanner(),
                      ],
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
}

// ── Featured Recipe Card ───────────────────────────────────────────────────────

class _FeaturedCard extends StatefulWidget {
  final Map<String, dynamic> recipe;
  final int position;
  final Color cardBg;
  final VoidCallback onUnfeature;
  final VoidCallback onEdit;

  const _FeaturedCard({
    required this.recipe,
    required this.position,
    required this.cardBg,
    required this.onUnfeature,
    required this.onEdit,
  });

  @override
  State<_FeaturedCard> createState() => _FeaturedCardState();
}

class _FeaturedCardState extends State<_FeaturedCard> {
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
                ? Theme.of(context).primaryColor.withOpacity(0.3)
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
            // ── Image area ─────────────────────────────────────────────────
            Expanded(
              child: Stack(
                children: [
                  // Background fill
                  Positioned.fill(
                    child: Container(color: widget.cardBg),
                  ),
                  // Recipe image centered
                  Center(
                    child: imageUrl.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: imageUrl,
                            width: 110,
                            height: 110,
                            fit: BoxFit.contain,
                            placeholder: (_, __) => const SizedBox(
                              width: 110,
                              height: 110,
                              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                            ),
                            errorWidget: (_, __, ___) => Icon(
                              Icons.restaurant_rounded,
                              size: 56,
                              color: Colors.grey[400],
                            ),
                          )
                        : Icon(Icons.restaurant_rounded, size: 56, color: Colors.grey[400]),
                  ),
                  // Position badge – top left
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '#${widget.position}',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  // Featured badge – top right
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF59E0B),
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star_rounded, size: 11, color: Colors.white),
                          const SizedBox(width: 4),
                          Text(
                            'Featured',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Drag handle / actions menu – bottom right
                  Positioned(
                    bottom: 10,
                    right: 10,
                    child: _ContextMenuButton(
                      onEdit: widget.onEdit,
                      onUnfeature: widget.onUnfeature,
                    ),
                  ),
                ],
              ),
            ),

            // ── Info area ──────────────────────────────────────────────────
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
                      color: Theme.of(context).primaryColor,
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
                      // Rating + cook time
                      Row(
                        children: [
                          const Icon(Icons.star_rounded, size: 13, color: Color(0xFFF59E0B)),
                          const SizedBox(width: 3),
                          Text(
                            '${rating.toStringAsFixed(1)} · ${cookTime > 0 ? '$cookTime min' : '—'}',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: const Color(0xFF8E8E8E),
                            ),
                          ),
                        ],
                      ),
                      // Status pill
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

// ── Context Menu Button ────────────────────────────────────────────────────────

class _ContextMenuButton extends StatelessWidget {
  final VoidCallback onEdit;
  final VoidCallback onUnfeature;

  const _ContextMenuButton({required this.onEdit, required this.onUnfeature});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: (val) {
        if (val == 'edit') onEdit();
        if (val == 'unfeature') onUnfeature();
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
          value: 'unfeature',
          child: Row(
            children: [
              const Icon(Icons.star_border_rounded, size: 15, color: Color(0xFFEF4444)),
              const SizedBox(width: 8),
              Text('Remove from featured', style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFFEF4444))),
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

// ── Status Pill ────────────────────────────────────────────────────────────────

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

// ── Auto-refresh Banner ────────────────────────────────────────────────────────

class _AutoRefreshBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF3E8),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.autorenew_rounded, color: Theme.of(context).primaryColor, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Auto-refresh featured shelf every 72 hours',
                  style: GoogleFonts.inter(fontSize: 13.5, fontWeight: FontWeight.w600, color: const Color(0xFF0F0F0F)),
                ),
                const SizedBox(height: 2),
                Text(
                  'Recipely will rotate the shelf based on trending signals when enabled.',
                  style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF8E8E8E)),
                ),
              ],
            ),
          ),
          InkWell(
            onTap: () {},
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFDEE2E6)),
              ),
              child: Text(
                'Configure',
                style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500, color: const Color(0xFF4E4E4E)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
