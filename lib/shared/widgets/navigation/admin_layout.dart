import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../modules/authentication/presentation/bloc/auth_bloc.dart';

class AdminLayout extends StatefulWidget {
  final Widget child;

  const AdminLayout({super.key, required this.child});

  @override
  State<AdminLayout> createState() => _AdminLayoutState();
}

class _AdminLayoutState extends State<AdminLayout> {
  void _onNavigate(String path) {
    context.go(path);
  }

  void _onLogout() {
    context.read<AuthBloc>().add(AuthLogoutRequested());
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sidebarBg = isDark ? const Color(0xFF18181B) : Colors.white;
    final topbarBg = isDark ? const Color(0xFF09090B) : Colors.white;
    final borderColor = isDark ? const Color(0xFF27272A) : const Color(0xFFE2E8F0);
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);

    final currentRoute = GoRouterState.of(context).uri.path;

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthUnauthenticated) {
          context.go('/login');
        }
      },
      child: Scaffold(
        body: Row(
          children: [
            // ── Sidebar Navigation ──────────────────────────────────────────
            Container(
              width: 220,
              decoration: BoxDecoration(
                color: sidebarBg,
                border: Border(right: BorderSide(color: borderColor, width: 1)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Logo Header ──────────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.restaurant_menu_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Recipely',
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: textColor,
                                letterSpacing: -0.3,
                              ),
                            ),
                            Text(
                              'Studio · Admin',
                              style: GoogleFonts.inter(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w400,
                                color: isDark
                                    ? const Color(0xFF8E8E8E)
                                    : const Color(0xFF8E8E8E),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // ── Navigation List ──────────────────────────────────────
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      children: [
                        _buildSectionLabel('OVERVIEW', isDark),
                        _buildNavItem(
                          icon: Icons.grid_view_rounded,
                          label: 'Dashboard',
                          path: '/dashboard',
                          currentRoute: currentRoute,
                          isDark: isDark,
                        ),
                        _buildNavItem(
                          icon: Icons.soup_kitchen_outlined,
                          label: 'Recipes',
                          path: '/recipes',
                          currentRoute: currentRoute,
                          isDark: isDark,
                        ),
                        _buildNavItem(
                          icon: Icons.star_border_rounded,
                          label: 'Featured',
                          path: '/featured',
                          currentRoute: currentRoute,
                          isDark: isDark,
                        ),
                        _buildNavItem(
                          icon: Icons.local_fire_department_outlined,
                          label: 'Trending',
                          path: '/trending',
                          currentRoute: currentRoute,
                          isDark: isDark,
                        ),
                        const SizedBox(height: 8),
                        _buildSectionLabel('LIBRARY', isDark),
                        _buildNavItem(
                          icon: Icons.grid_3x3_outlined,
                          label: 'Categories',
                          path: '/categories',
                          currentRoute: currentRoute,
                          isDark: isDark,
                        ),
                        _buildNavItem(
                          icon: Icons.label_outline_rounded,
                          label: 'Tags',
                          path: '/tags',
                          currentRoute: currentRoute,
                          isDark: isDark,
                        ),
                        const SizedBox(height: 8),
                        _buildSectionLabel('PLATFORM', isDark),
                        _buildNavItem(
                          icon: Icons.people_outline_rounded,
                          label: 'Users',
                          path: '/users',
                          currentRoute: currentRoute,
                          isDark: isDark,
                        ),
                        _buildNavItem(
                          icon: Icons.bar_chart_rounded,
                          label: 'Analytics',
                          path: '/analytics',
                          currentRoute: currentRoute,
                          isDark: isDark,
                        ),
                        _buildNavItem(
                          icon: Icons.settings_outlined,
                          label: 'Settings',
                          path: '/settings',
                          currentRoute: currentRoute,
                          isDark: isDark,
                        ),
                      ],
                    ),
                  ),

                  // ── User Profile Footer ──────────────────────────────────
                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      String name = 'Admin User';
                      String role = 'Administrator';
                      String initials = 'A';

                      if (state is AuthAuthenticated) {
                        name = state.user.name.isNotEmpty ? state.user.name : 'Admin User';
                        role = _formatRole(state.user.role);
                        initials = name
                            .split(' ')
                            .where((e) => e.isNotEmpty)
                            .map((e) => e[0])
                            .take(2)
                            .join()
                            .toUpperCase();
                      }

                      return Container(
                        decoration: BoxDecoration(
                          border: Border(top: BorderSide(color: borderColor, width: 1)),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 18,
                              backgroundColor: Theme.of(context).primaryColor,
                              child: Text(
                                initials,
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    name,
                                    style: GoogleFonts.inter(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: textColor,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    role,
                                    style: GoogleFonts.inter(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w400,
                                      color: isDark
                                          ? const Color(0xFF8E8E8E)
                                          : const Color(0xFF8E8E8E),
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.logout_rounded,
                                color: isDark
                                    ? const Color(0xFF8E8E8E)
                                    : const Color(0xFFADB5BD),
                                size: 18,
                              ),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              onPressed: _onLogout,
                              tooltip: 'Sign out',
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            // ── Main Page Content ───────────────────────────────────────────
            Expanded(
              child: Column(
                children: [
                  // Top Sticky Navigation Bar
                  Container(
                    height: 60,
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    decoration: BoxDecoration(
                      color: topbarBg,
                      border: Border(bottom: BorderSide(color: borderColor, width: 1)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _getRouteName(currentRoute),
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: textColor,
                          ),
                        ),
                        BlocBuilder<AuthBloc, AuthState>(
                          builder: (context, state) {
                            if (state is AuthAuthenticated) {
                              final initials = state.user.name.isNotEmpty
                                  ? state.user.name
                                      .split(' ')
                                      .where((e) => e.isNotEmpty)
                                      .map((e) => e[0])
                                      .take(2)
                                      .join()
                                      .toUpperCase()
                                  : 'A';
                              return Row(
                                children: [
                                  Text(
                                    state.user.name,
                                    style: GoogleFonts.inter(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: isDark
                                          ? const Color(0xFFA1A1AA)
                                          : const Color(0xFF6C757D),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  CircleAvatar(
                                    radius: 17,
                                    backgroundColor: Theme.of(context).primaryColor,
                                    child: Text(
                                      initials,
                                      style: GoogleFonts.inter(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            }
                            return const SizedBox.shrink();
                          },
                        ),
                      ],
                    ),
                  ),
                  // Page body
                  Expanded(child: widget.child),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String label, bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 10.5,
          fontWeight: FontWeight.w600,
          color: isDark ? const Color(0xFF6E6E6E) : const Color(0xFFADB5BD),
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required String path,
    required String currentRoute,
    required bool isDark,
  }) {
    final isSelected = currentRoute == path || currentRoute.startsWith('$path/');
    final primaryColor = Theme.of(context).primaryColor;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: InkWell(
        onTap: () => _onNavigate(path),
        borderRadius: BorderRadius.circular(50),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
          decoration: BoxDecoration(
            color: isSelected
                ? primaryColor.withOpacity(0.10)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(50),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: isSelected
                    ? primaryColor
                    : (isDark ? const Color(0xFF8E8E8E) : const Color(0xFF6E6E6E)),
              ),
              const SizedBox(width: 12),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected
                      ? primaryColor
                      : (isDark ? const Color(0xFFCDCDCD) : const Color(0xFF4E4E4E)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatRole(String role) {
    switch (role) {
      case 'admin':
        return 'Administrator';
      case 'editor':
        return 'Content Editor';
      case 'moderator':
        return 'Moderator';
      default:
        return 'Admin User';
    }
  }

  String _getRouteName(String path) {
    if (path.startsWith('/dashboard')) return 'Dashboard';
    if (path.startsWith('/recipes/new')) return 'Recipes / Add New Recipe';
    if (path.startsWith('/recipes/edit')) return 'Recipes / Edit Recipe';
    if (path.startsWith('/recipes/preview')) return 'Recipes / Preview Recipe';
    if (path.startsWith('/recipes')) return 'Recipes';
    if (path.startsWith('/categories')) return 'Categories';
    if (path.startsWith('/tags')) return 'Tags';
    if (path.startsWith('/users')) return 'Users';
    if (path.startsWith('/featured')) return 'Featured';
    if (path.startsWith('/trending')) return 'Trending';
    if (path.startsWith('/analytics')) return 'Analytics';
    if (path.startsWith('/settings')) return 'Settings';
    return 'Recipely Studio';
  }
}
