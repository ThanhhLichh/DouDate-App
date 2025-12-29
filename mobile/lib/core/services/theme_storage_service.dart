import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/dashboard_theme.dart';
import '../theme/theme_constants.dart';
import '../theme/theme_presets.dart';

class ThemeStorageService {
  final SharedPreferences _prefs;

  ThemeStorageService(this._prefs);

  /// Save current theme to SharedPreferences
  Future<bool> saveTheme(DashboardTheme theme) async {
    try {
      final json = jsonEncode(theme.toJson());
      return await _prefs.setString(ThemeConstants.themeStorageKey, json);
    } catch (e) {
      debugPrint('Error saving theme: $e');
      return false;
    }
  }

  /// Load saved theme from SharedPreferences
  Future<DashboardTheme?> loadTheme() async {
    try {
      final jsonString = _prefs.getString(ThemeConstants.themeStorageKey);

      if (jsonString == null || jsonString.isEmpty) {
        return null;
      }

      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return DashboardTheme.fromJson(json);
    } catch (e) {
      debugPrint('Error loading theme: $e');
      return null;
    }
  }

  /// Clear saved theme (reset to default)
  Future<bool> clearTheme() async {
    try {
      return await _prefs.remove(ThemeConstants.themeStorageKey);
    } catch (e) {
      debugPrint('Error clearing theme: $e');
      return false;
    }
  }

  /// Check if a theme is saved
  bool hasThemeSaved() {
    return _prefs.containsKey(ThemeConstants.themeStorageKey);
  }

  /// Get the saved theme ID (if any)
  String? getSavedThemeId() {
    try {
      final jsonString = _prefs.getString(ThemeConstants.themeStorageKey);
      if (jsonString == null) return null;

      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return json['id'] as String?;
    } catch (e) {
      debugPrint('Error getting theme ID: $e');
      return null;
    }
  }

  /// Check if current theme is a preset or custom
  bool isCustomTheme() {
    try {
      final jsonString = _prefs.getString(ThemeConstants.themeStorageKey);
      if (jsonString == null) return false;

      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return json['isCustom'] as bool? ?? false;
    } catch (e) {
      debugPrint('Error checking custom theme: $e');
      return false;
    }
  }

  /// Save theme preference metadata (last modified, version, etc.)
  Future<bool> saveThemeMetadata(Map<String, dynamic> metadata) async {
    try {
      final json = jsonEncode(metadata);
      return await _prefs.setString('theme_metadata', json);
    } catch (e) {
      debugPrint('Error saving theme metadata: $e');
      return false;
    }
  }

  /// Load theme preference metadata
  Map<String, dynamic>? loadThemeMetadata() {
    try {
      final jsonString = _prefs.getString('theme_metadata');
      if (jsonString == null) return null;

      return jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      debugPrint('Error loading theme metadata: $e');
      return null;
    }
  }

  /// Migrate old theme data (if needed)
  // Future<void> migrateThemeData() async {
  //   try {
  //     // Check if old theme key exists
  //     final oldThemeKey = 'app_theme'; // Example old key
  //     if (_prefs.containsKey(oldThemeKey)) {
  //       final oldValue = _prefs.getString(oldThemeKey);

  //       // Convert old format to new format if needed
  //       // This is just a placeholder - implement based on your needs

  //       // Remove old key
  //       await _prefs.remove(oldThemeKey);
  //     }
  //   } catch (e) {
  //     debugPrint('Error migrating theme data: $e');
  //   }
  // }

  /// Export theme as JSON string (for backup/sharing)
  String? exportTheme() {
    try {
      final jsonString = _prefs.getString(ThemeConstants.themeStorageKey);
      return jsonString;
    } catch (e) {
      debugPrint('Error exporting theme: $e');
      return null;
    }
  }

  /// Import theme from JSON string
  Future<bool> importTheme(String jsonString) async {
    try {
      // Validate JSON
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      final theme = DashboardTheme.fromJson(json);

      // Save imported theme
      return await saveTheme(theme);
    } catch (e) {
      debugPrint('Error importing theme: $e');
      return false;
    }
  }

  /// Get theme history (last N themes used)
  List<String> getThemeHistory({int limit = 5}) {
    try {
      final history = _prefs.getStringList('theme_history') ?? [];
      return history.take(limit).toList();
    } catch (e) {
      debugPrint('Error getting theme history: $e');
      return [];
    }
  }

  /// Add theme to history
  Future<void> addToThemeHistory(String themeId) async {
    try {
      final history = _prefs.getStringList('theme_history') ?? [];

      // Remove if already exists
      history.remove(themeId);

      // Add to beginning
      history.insert(0, themeId);

      // Keep only last 10
      if (history.length > 10) {
        history.removeRange(10, history.length);
      }

      await _prefs.setStringList('theme_history', history);
    } catch (e) {
      debugPrint('Error adding to theme history: $e');
    }
  }

  /// Clear all theme-related data
  Future<void> clearAllThemeData() async {
    try {
      await _prefs.remove(ThemeConstants.themeStorageKey);
      await _prefs.remove(ThemeConstants.customThemeKey);
      await _prefs.remove('theme_metadata');
      await _prefs.remove('theme_history');
    } catch (e) {
      debugPrint('Error clearing all theme data: $e');
    }
  }
}
