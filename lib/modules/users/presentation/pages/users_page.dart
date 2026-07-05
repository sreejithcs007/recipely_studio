import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../../shared/widgets/empty_states/empty_state.dart';
import '../../../../shared/widgets/error_states/error_state.dart';
import '../../../../shared/widgets/loading/shimmers.dart';
import '../../domain/entities/user_profile.dart';
import '../bloc/user_bloc.dart';

class UsersPage extends StatefulWidget {
  const UsersPage({super.key});

  @override
  State<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    context.read<UserBloc>().add(const LoadUsers());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String val) {
    setState(() {
      _searchQuery = val;
    });
    context.read<UserBloc>().add(LoadUsers(query: val.isEmpty ? null : val));
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
                        'MANAGEMENT',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.1,
                          color: primaryColor,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Users',
                        style: GoogleFonts.inter(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFF0F0F0F),
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      BlocBuilder<UserBloc, UserState>(
                        builder: (context, state) {
                          if (state is UserLoaded) {
                            final total = state.users.length;
                            return Text(
                              '$total registered user profiles · View cooked/saved recipe metrics and roles.',
                              style: GoogleFonts.inter(
                                fontSize: 13.5,
                                color: const Color(0xFF8E8E8E),
                              ),
                            );
                          }
                          return Text(
                            'View registered app profiles, cooked/saved recipe metrics, and roles.',
                            style: GoogleFonts.inter(
                              fontSize: 13.5,
                              color: const Color(0xFF8E8E8E),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // ── Search & Filter bar ──────────────────────────────────────────
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 36,
                      child: TextField(
                        controller: _searchController,
                        onChanged: _onSearchChanged,
                        style: GoogleFonts.inter(fontSize: 13.5),
                        decoration: InputDecoration(
                          hintText: 'Search by name or email...',
                          hintStyle: GoogleFonts.inter(
                            fontSize: 13.5,
                            color: const Color(0xFFADB5BD),
                          ),
                          prefixIcon: const Icon(Icons.search_rounded, size: 18, color: Color(0xFFADB5BD)),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 8),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear_rounded, size: 16),
                                  onPressed: () {
                                    _searchController.clear();
                                    _onSearchChanged('');
                                  },
                                )
                              : null,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  InkWell(
                    onTap: () => context.read<UserBloc>().add(const LoadUsers()),
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
            const SizedBox(height: 16),

            // ── Table ────────────────────────────────────────────────────────
            Expanded(
              child: BlocBuilder<UserBloc, UserState>(
                builder: (context, state) {
                  if (state is UserLoading) {
                    return _buildShimmer();
                  }
                  if (state is UserFailure) {
                    return ErrorState(
                      message: state.error,
                      onRetry: () => context.read<UserBloc>().add(const LoadUsers()),
                    );
                  }
                  if (state is UserLoaded) {
                    final users = state.users;
                    if (users.isEmpty) {
                      return const EmptyState(
                        icon: Icons.people_outline,
                        title: 'No Users Found',
                        description: 'There are no active users matching this search term.',
                      );
                    }
                    return _UserTable(users: users);
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

// ── User Data Table ──────────────────────────────────────────────────────────
class _UserTable extends StatelessWidget {
  final List<UserProfile> users;

  const _UserTable({required this.users});

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
              itemCount: users.length,
              separatorBuilder: (_, __) => const Divider(height: 1, color: Color(0xFFF5F6F8)),
              itemBuilder: (context, index) {
                final user = users[index];
                return _UserRow(user: user);
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
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: const [
          Expanded(flex: 5, child: Text('USER INFO', style: labelStyle)),
          Expanded(flex: 2, child: Text('SYSTEM ROLE', style: labelStyle)),
          Expanded(flex: 3, child: Text('CHEF LEVEL', style: labelStyle)),
          Expanded(flex: 4, child: Text('ENGAGEMENT STATS', style: labelStyle)),
          Expanded(flex: 2, child: Text('JOINED DATE', style: labelStyle)),
        ],
      ),
    );
  }
}

class _UserRow extends StatefulWidget {
  final UserProfile user;

  const _UserRow({required this.user});

  @override
  State<_UserRow> createState() => _UserRowState();
}

class _UserRowState extends State<_UserRow> {
  bool _hovered = false;

  Color _getRoleColor(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return const Color(0xFFEF4444);
      case 'editor':
        return const Color(0xFFA855F7);
      case 'moderator':
        return const Color(0xFF3B82F6);
      default:
        return const Color(0xFF10B981);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.user;
    final initials = user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U';
    final roleColor = _getRoleColor(user.role);

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        color: _hovered ? const Color(0xFFFFF8F5) : Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          children: [
            // User info (Avatar + Name & Email)
            Expanded(
              flex: 5,
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundImage: user.avatarUrl.isNotEmpty && user.avatarUrl.startsWith('http')
                        ? CachedNetworkImageProvider(user.avatarUrl)
                        : null,
                    backgroundColor: const Color(0xFFFFEFE8),
                    child: user.avatarUrl.isEmpty || !user.avatarUrl.startsWith('http')
                        ? Text(
                            initials,
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).primaryColor,
                              fontSize: 13,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.name,
                          style: GoogleFonts.inter(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF0F0F0F),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          user.email,
                          style: GoogleFonts.inter(
                            fontSize: 11.5,
                            color: const Color(0xFF8E8E8E),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // System Role
            Expanded(
              flex: 2,
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: roleColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      user.role.toUpperCase(),
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: roleColor,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Chef Level
            Expanded(
              flex: 3,
              child: Text(
                user.chefLevel,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF4E4E4E),
                ),
              ),
            ),
            // Engagement Stats
            Expanded(
              flex: 4,
              child: Row(
                children: [
                  _StatItem(
                    icon: Icons.restaurant_menu_rounded,
                    label: 'Cooked',
                    value: user.cookedCount,
                    color: Colors.orange,
                  ),
                  const SizedBox(width: 16),
                  _StatItem(
                    icon: Icons.bookmark_outline_rounded,
                    label: 'Saved',
                    value: user.savedCount,
                    color: Colors.blue,
                  ),
                ],
              ),
            ),
            // Joined Date
            Expanded(
              flex: 2,
              child: Text(
                DateFormat('MMM dd, yyyy').format(user.createdAt),
                style: GoogleFonts.inter(
                  fontSize: 12.5,
                  color: const Color(0xFF8E8E8E),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final int value;
  final Color color;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color.withOpacity(0.7)),
        const SizedBox(width: 4),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: '$value ',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF0F0F0F),
                ),
              ),
              TextSpan(
                text: label,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: const Color(0xFF8E8E8E),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
