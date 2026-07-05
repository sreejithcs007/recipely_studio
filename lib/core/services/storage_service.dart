import 'dart:html' as html;
import 'package:flutter/foundation.dart';

class StorageService {
  void write(String key, String value) {
    if (kIsWeb) {
      try {
        html.window.localStorage[key] = value;
      } catch (e) {
        debugPrint('Error writing to localStorage: $e');
      }
    }
  }

  String? read(String key) {
    if (kIsWeb) {
      try {
        return html.window.localStorage[key];
      } catch (e) {
        debugPrint('Error reading from localStorage: $e');
        return null;
      }
    }
    return null;
  }

  void remove(String key) {
    if (kIsWeb) {
      try {
        html.window.localStorage.remove(key);
      } catch (e) {
        debugPrint('Error removing from localStorage: $e');
      }
    }
  }
}
