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
  bool _isSidebarCollapsed = false;

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
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: _isSidebarCollapsed ? 72 : 240,
              decoration: BoxDecoration(
                color: sidebarBg,
                border: Border(right: BorderSide(color: borderColor, width: 1)),
              ),
              child: Column(
                children: [
                  // Sidebar Header (Logo)
                  Container(
                    height: 64,
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      border: Border(bottom: BorderSide(color: borderColor, width: 1)),
                    ),
                    child: Row(
                      mainAxisAlignment: _isSidebarCollapsed ? MainAxisAlignment.center : MainAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.restaurant_menu,
                          color: Theme.of(context).primaryColor,
                          size: 26,
                        ),
                        if (!_isSidebarCollapsed) ...[
                          const SizedBox(width: 12),
                          Text(
                            'Recipely Studio',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: textColor,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ]
                      ],
                    ),
                  ),
                  // Sidebar Items List
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                      children: [
                        _buildNavItem(
                          icon: Icons.dashboard_outlined,
                          activeIcon: Icons.dashboard,
                          label: 'Dashboard',
                          path: '/dashboard',
                          currentRoute: currentRoute,
                        ),
                        _buildNavItem(
                          icon: Icons.restaurant_outlined,
                          activeIcon: Icons.restaurant,
                          label: 'Recipes',
                          path: '/recipes',
                          currentRoute: currentRoute,
                        ),
                        _buildNavItem(
                          icon: Icons.category_outlined,
                          activeIcon: Icons.category,
                          label: 'Categories',
                          path: '/categories',
                          currentRoute: currentRoute,
                        ),
                        _buildNavItem(
                          icon: Icons.label_outline,
                          activeIcon: Icons.label,
                          label: 'Tags',
                          path: '/tags',
                          currentRoute: currentRoute,
                        ),
                        _buildNavItem(
                          icon: Icons.people_outline,
                          activeIcon: Icons.people,
                          label: 'Users',
                          path: '/users',
                          currentRoute: currentRoute,
                        ),
                        _buildNavItem(
                          icon: Icons.settings_outlined,
                          activeIcon: Icons.settings,
                          label: 'Settings',
                          path: '/settings',
                          currentRoute: currentRoute,
                        ),
                      ],
                    ),
                  ),
                  // Sidebar Footer (Collapse Toggle + Logout)
                  Container(
                    decoration: BoxDecoration(
                      border: Border(top: BorderSide(color: borderColor, width: 1)),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                    child: Column(
                      children: [
                        IconButton(
                          icon: Icon(
                            _isSidebarCollapsed ? Icons.chevron_right : Icons.chevron_left,
                            color: isDark ? const Color(0xFFA1A1AA) : const Color(0xFF64748B),
                          ),
                          onPressed: () {
                            setState(() {
                              _isSidebarCollapsed = !_isSidebarCollapsed;
                            });
                          },
                        ),
                        const SizedBox(height: 8),
                        IconButton(
                          icon: const Icon(
                            Icons.logout_outlined,
                            color: Color(0xFFEF4444),
                          ),
                          onPressed: _onLogout,
                        ),
                      ],
                    ),
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
                    height: 64,
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    decoration: BoxDecoration(
                      color: topbarBg,
                      border: Border(bottom: BorderSide(color: borderColor, width: 1)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Breadcrumbs / Section Title
                        Row(
                          children: [
                            Text(
                              _getRouteName(currentRoute),
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: textColor,
                              ),
                            ),
                          ],
                        ),
                        // Right widgets (Theme toggle, notifications, profile initials)
                        Row(
                          children: [
                            BlocBuilder<AuthBloc, AuthState>(
                              builder: (context, state) {
                                if (state is AuthAuthenticated) {
                                  final initials = state.user.name.isNotEmpty
                                      ? state.user.name.split(' ').map((e) => e[0]).join().toUpperCase()
                                      : 'A';
                                  return Row(
                                    children: [
                                      Text(
                                        state.user.name,
                                        style: GoogleFonts.inter(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: isDark ? const Color(0xFFA1A1AA) : const Color(0xFF475569),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      CircleAvatar(
                                        radius: 18,
                                        backgroundColor: Theme.of(context).primaryColor,
                                        child: Text(
                                          initials.length > 2 ? initials.substring(0, 2) : initials,
                                          style: GoogleFonts.inter(
                                            fontSize: 12,
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
                      ],
                    ),
                  ),
                  // Tab contents
                  Expanded(
                    child: widget.child,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required String path,
    required String currentRoute,
  }) {
    final isSelected = currentRoute == path || currentRoute.startsWith('$path/');
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).primaryColor;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Tooltip(
        message: _isSidebarCollapsed ? label : '',
        child: InkWell(
          onTap: () => _onNavigate(path),
          borderRadius: BorderRadius.circular(8),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
            decoration: BoxDecoration(
              color: isSelected
                  ? primaryColor.withOpacity(0.08)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              border: isSelected
                  ? Border(left: BorderSide(color: primaryColor, width: 3.5))
                  : null,
            ),
            child: Row(
              mainAxisAlignment: _isSidebarCollapsed ? MainAxisAlignment.center : MainAxisAlignment.start,
              children: [
                Icon(
                  isSelected ? activeIcon : icon,
                  color: isSelected ? primaryColor : (isDark ? const Color(0xFFA1A1AA) : const Color(0xFF64748B)),
                  size: 22,
                ),
                if (!_isSidebarCollapsed) ...[
                  const SizedBox(width: 12),
                  Text(
                    label,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      color: isSelected ? primaryColor : (isDark ? const Color(0xFFFAFAFA) : const Color(0xFF334155)),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getRouteName(String path) {
    if (path.startsWith('/dashboard')) return 'Dashboard Overview';
    if (path.startsWith('/recipes/new')) return 'Recipes / Add New Recipe';
    if (path.startsWith('/recipes/edit')) return 'Recipes / Edit Recipe';
    if (path.startsWith('/recipes/preview')) return 'Recipes / Preview Recipe';
    if (path.startsWith('/recipes')) return 'Recipe Management';
    if (path.startsWith('/categories')) return 'Category Management';
    if (path.startsWith('/tags')) return 'Tag Management';
    if (path.startsWith('/users')) return 'User Directory';
    if (path.startsWith('/settings')) return 'System Settings';
    return 'CMS Studio';
  }
}
