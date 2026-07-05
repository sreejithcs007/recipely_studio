import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class RecentActivity extends StatelessWidget {
  final List<dynamic> logs;

  const RecentActivity({super.key, required this.logs});

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
          Text(
            'Recent Admin Activity',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: titleColor,
            ),
          ),
          const SizedBox(height: 16),
          if (logs.isEmpty)
            _buildSampleLogs(context)
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: logs.length,
              separatorBuilder: (context, index) => const Divider(height: 16),
              itemBuilder: (context, index) {
                final log = logs[index];
                final String action = log['action'] as String? ?? 'Performed Admin Action';
                final String createdStr = log['created_at'] as String? ?? '';
                final String adminName = (log['admin'] as Map?)?['name'] as String? ?? 'Admin';
                
                DateTime? date;
                if (createdStr.isNotEmpty) {
                  date = DateTime.parse(createdStr).toLocal();
                }
                
                final timeFormatted = date != null 
                    ? DateFormat('MMM dd, yyyy - hh:mm a').format(date)
                    : 'Just now';

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.history_toggle_off, size: 16, color: Colors.blue),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RichText(
                            text: TextSpan(
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                color: isDark ? Colors.white : Colors.black,
                              ),
                              children: [
                                TextSpan(
                                  text: adminName,
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                const TextSpan(text: ' '),
                                TextSpan(text: action),
                              ],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            timeFormatted,
                            style: GoogleFonts.inter(
                              color: Colors.grey,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildSampleLogs(BuildContext context) {
    final sampleLogs = [
      {'name': 'Sarah Jenkins', 'action': 'published new recipe "Zesty Lemon Tart"', 'time': '10 minutes ago'},
      {'name': 'Marcus Aurelius', 'action': 'updated Category "Italian Cuisine"', 'time': '1 hour ago'},
      {'name': 'Sarah Jenkins', 'action': 'archived recipe "Spicy Tuna Roll"', 'time': '3 hours ago'},
      {'name': 'System Coordinator', 'action': 'backed up Supabase Database tables', 'time': '5 hours ago'},
      {'name': 'Sarah Jenkins', 'action': 'created Tag "Vegan-friendly"', 'time': '1 day ago'},
    ];

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: sampleLogs.length,
      separatorBuilder: (context, index) => const Divider(height: 16),
      itemBuilder: (context, index) {
        final log = sampleLogs[index];
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.history_toggle_off, size: 16, color: Colors.blue),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
                      ),
                      children: [
                        TextSpan(
                          text: log['name']!,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const TextSpan(text: ' '),
                        TextSpan(text: log['action']!),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    log['time']!,
                    style: GoogleFonts.inter(
                      color: Colors.grey,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
