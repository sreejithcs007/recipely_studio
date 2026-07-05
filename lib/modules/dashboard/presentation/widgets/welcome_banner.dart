import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../authentication/presentation/bloc/auth_bloc.dart';

class WelcomeBanner extends StatelessWidget {
  final Map<String, dynamic> stats;
  final VoidCallback onNewCategory;
  final VoidCallback onAddRecipe;

  const WelcomeBanner({
    super.key,
    required this.stats,
    required this.onNewCategory,
    required this.onAddRecipe,
  });

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  String _getDayLabel() {
    final days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    final day = days[DateTime.now().weekday - 1];
    return '$day · Content Day';
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        String firstName = 'Admin';
        if (state is AuthAuthenticated) {
          final parts = state.user.name.split(' ');
          firstName = parts.isNotEmpty ? parts[0] : state.user.name;
        }

        final totalRecipes = stats['totalRecipes'] ?? 0;
        final totalUsers = stats['totalUsers'] ?? 0;

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(28, 28, 28, 28),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFFF3E8), Color(0xFFFDE8D0)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFFFD4A8), width: 1),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Left: Text content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Day badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(50),
                        border: Border.all(color: const Color(0xFFFFD4A8)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('✨', style: TextStyle(fontSize: 12)),
                          const SizedBox(width: 5),
                          Text(
                            _getDayLabel(),
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFFB45309),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    // Greeting
                    Text(
                      '${_getGreeting()}, $firstName',
                      style: GoogleFonts.inter(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF0F0F0F),
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Subtitle
                    RichText(
                      text: TextSpan(
                        style: GoogleFonts.inter(
                          fontSize: 13.5,
                          color: const Color(0xFF6C757D),
                          height: 1.5,
                        ),
                        children: [
                          const TextSpan(text: 'Your platform has '),
                          TextSpan(
                            text: '$totalRecipes recipes',
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF0F0F0F),
                            ),
                          ),
                          const TextSpan(text: ' and '),
                          TextSpan(
                            text: '$totalUsers active readers',
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF0F0F0F),
                            ),
                          ),
                          const TextSpan(text: '. Here\'s how everything is performing.'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 24),
              // Right: Action buttons
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _ActionButton(
                    icon: Icons.grid_view_rounded,
                    label: 'New Category',
                    onTap: onNewCategory,
                    primary: false,
                  ),
                  const SizedBox(height: 10),
                  _ActionButton(
                    icon: Icons.add_rounded,
                    label: 'Add Recipe',
                    onTap: onAddRecipe,
                    primary: true,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool primary;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.primary,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        decoration: BoxDecoration(
          color: primary ? primaryColor : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: primary ? primaryColor : const Color(0xFFDEE2E6),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 15, color: primary ? Colors.white : const Color(0xFF4E4E4E)),
            const SizedBox(width: 7),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: primary ? Colors.white : const Color(0xFF4E4E4E),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
