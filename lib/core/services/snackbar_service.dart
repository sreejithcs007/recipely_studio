import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SnackbarService {
  static final GlobalKey<ScaffoldMessengerState> messengerKey =
      GlobalKey<ScaffoldMessengerState>();

  void showSuccess(String message) {
    _showSnackBar(
      message: message,
      backgroundColor: const Color(0xFF10B981), // Emerald 500
      icon: Icons.check_circle_outline,
    );
  }

  void showWarning(String message) {
    _showSnackBar(
      message: message,
      backgroundColor: const Color(0xFFD97706), // Amber 600
      icon: Icons.warning_amber_outlined,
    );
  }

  void showError(String message) {
    _showSnackBar(
      message: message,
      backgroundColor: const Color(0xFFEF4444), // Red 500
      icon: Icons.error_outline,
    );
  }

  void _showSnackBar({
    required String message,
    required Color backgroundColor,
    required IconData icon,
  }) {
    final state = messengerKey.currentState;
    if (state == null) return;

    state.clearSnackBars();
    state.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: backgroundColor,
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        duration: const Duration(seconds: 4),
      ),
    );
  }
}
