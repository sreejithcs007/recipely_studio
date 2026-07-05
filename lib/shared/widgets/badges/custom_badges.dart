import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class StatusBadge extends StatelessWidget {
  final String status;

  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color textColor;
    String label = status.toUpperCase();

    switch (status.toLowerCase()) {
      case 'published':
        bgColor = const Color(0xFFD1FAE5); // Emerald 100
        textColor = const Color(0xFF065F46); // Emerald 800
        break;
      case 'draft':
        bgColor = const Color(0xFFFEF3C7); // Amber 100
        textColor = const Color(0xFF92400E); // Amber 800
        break;
      case 'archived':
      default:
        bgColor = const Color(0xFFF3F4F6); // Grey 100
        textColor = const Color(0xFF374151); // Grey 800
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(9999),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: textColor,
        ),
      ),
    );
  }
}

class FeaturedBadge extends StatelessWidget {
  const FeaturedBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFDBEAFE), // Blue 100
        borderRadius: BorderRadius.circular(9999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star, size: 12, color: Color(0xFF1E40AF)), // Blue 800
          const SizedBox(width: 4),
          Text(
            'FEATURED',
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1E40AF),
            ),
          ),
        ],
      ),
    );
  }
}

class TrendingBadge extends StatelessWidget {
  const TrendingBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFFCE7F3), // Pink 100
        borderRadius: BorderRadius.circular(9999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.local_fire_department, size: 12, color: Color(0xFF9D174D)), // Pink 800
          const SizedBox(width: 4),
          Text(
            'TRENDING',
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF9D174D),
            ),
          ),
        ],
      ),
    );
  }
}
