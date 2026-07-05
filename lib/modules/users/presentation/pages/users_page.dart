import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../../shared/widgets/empty_states/empty_state.dart';
import '../../../../shared/widgets/error_states/error_state.dart';
import '../../../../shared/widgets/loading/shimmers.dart';
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

  Color _getRoleColor(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return Colors.red;
      case 'editor':
        return Colors.purple;
      case 'moderator':
        return Colors.blue;
      default:
        return Colors.green;
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
            // Header
            Text(
              'User Directory',
              style: GoogleFonts.inter(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: titleColor,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'View registered app profiles, cooked/saved recipe metrics, and roles.',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: isDark ? const Color(0xFFA1A1AA) : const Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 24),
            // Search
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    width: 400,
                    child: TextField(
                      controller: _searchController,
                      onChanged: _onSearchChanged,
                      decoration: InputDecoration(
                        hintText: 'Search by name or email...',
                        prefixIcon: const Icon(Icons.search, size: 20),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, size: 18),
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
              ],
            ),
            const SizedBox(height: 24),
            // User List Grid/Table
            Expanded(
              child: BlocBuilder<UserBloc, UserState>(
                builder: (context, state) {
                  if (state is UserLoading) {
                    return _buildShimmerTable();
                  } else if (state is UserFailure) {
                    return ErrorState(
                      message: state.error,
                      onRetry: () => context.read<UserBloc>().add(const LoadUsers()),
                    );
                  } else if (state is UserLoaded) {
                    final users = state.users;

                    if (users.isEmpty) {
                      return const EmptyState(
                        icon: Icons.people_outline,
                        title: 'No Users Found',
                        description: 'There are no active users matching this search term.',
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
                                  'User Info',
                                  style: GoogleFonts.inter(fontWeight: FontWeight.bold),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  'System Role',
                                  style: GoogleFonts.inter(fontWeight: FontWeight.bold),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  'Chef Level',
                                  style: GoogleFonts.inter(fontWeight: FontWeight.bold),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  'Engagement Stats',
                                  style: GoogleFonts.inter(fontWeight: FontWeight.bold),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  'Joined Date',
                                  style: GoogleFonts.inter(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                            rows: users.map((user) {
                              final initials = user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U';
                              final roleColor = _getRoleColor(user.role);

                              return DataRow(
                                cells: [
                                  DataCell(
                                    Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 16,
                                          backgroundImage: user.avatarUrl.isNotEmpty && user.avatarUrl.startsWith('http')
                                              ? CachedNetworkImageProvider(user.avatarUrl)
                                              : null,
                                          backgroundColor: Colors.orange[100],
                                          child: user.avatarUrl.isEmpty || !user.avatarUrl.startsWith('http')
                                              ? Text(
                                                  initials,
                                                  style: GoogleFonts.inter(
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.orange[800],
                                                    fontSize: 12,
                                                  ),
                                                )
                                              : null,
                                        ),
                                        const SizedBox(width: 12),
                                        Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              user.name,
                                              style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                                            ),
                                            Text(
                                              user.email,
                                              style: GoogleFonts.inter(color: Colors.grey, fontSize: 11),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  DataCell(
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: roleColor.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        user.role.toUpperCase(),
                                        style: GoogleFonts.inter(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: roleColor,
                                        ),
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    Text(
                                      user.chefLevel,
                                      style: GoogleFonts.inter(),
                                    ),
                                  ),
                                  DataCell(
                                    Text(
                                      '🍳 Cooked: ${user.cookedCount} • ⭐️ Saved: ${user.savedCount}',
                                      style: GoogleFonts.inter(fontSize: 12),
                                    ),
                                  ),
                                  DataCell(
                                    Text(
                                      DateFormat('MMM dd, yyyy').format(user.createdAt),
                                      style: GoogleFonts.inter(fontSize: 12, color: Colors.grey),
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
          child: ShimmerLoader(width: double.infinity, height: 52, borderRadius: 6),
        ),
      ),
    );
  }
}
