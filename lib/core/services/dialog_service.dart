import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DialogService {
  bool _isLoadingShowing = false;

  Future<bool> showConfirmDialog({
    required BuildContext context,
    required String title,
    required String message,
    String confirmLabel = 'Confirm',
    String cancelLabel = 'Cancel',
    bool isDestructive = false,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(
            title,
            style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 18),
          ),
          content: Text(
            message,
            style: GoogleFonts.inter(fontSize: 14),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(
                cancelLabel,
                style: GoogleFonts.inter(color: Colors.grey[600], fontWeight: FontWeight.w500),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: isDestructive ? const Color(0xFFEF4444) : Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              child: Text(
                confirmLabel,
                style: GoogleFonts.inter(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        );
      },
    );
    return result ?? false;
  }

  void showLoading(BuildContext context, {String message = 'Loading...'}) {
    if (_isLoadingShowing) return;
    _isLoadingShowing = true;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return PopScope(
          canPop: false,
          child: AlertDialog(
            content: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(width: 24),
                Text(
                  message,
                  style: GoogleFonts.inter(fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        );
      },
    ).then((_) {
      _isLoadingShowing = false;
    });
  }

  void hideLoading(BuildContext context) {
    if (_isLoadingShowing) {
      Navigator.of(context).pop();
      _isLoadingShowing = false;
    }
  }
}
