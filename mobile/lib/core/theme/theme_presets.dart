import 'package:flutter/material.dart';
import 'dashboard_theme.dart';

class ThemePresets {
  // Romantic Theme - Pink & Purple
  static final romantic = DashboardTheme(
    id: 'romantic',
    name: 'Romantic',
    primaryColor: Color(0xFFFF6B9D),
    accentColor: Color(0xFF4E4E7C),
    cardBackground: Colors.white,
    heartIconColor: Color(0xFFFF1493),
    partnerBorderColor: Color(0xFFFF6B9D),
    yourBorderColor: Color(0xFFC06C84),
    textPrimaryColor: Color(0xFF4E4E7C),
    textSecondaryColor: Colors.grey,
  );

  // Ocean Theme - Blue & Teal
  static final ocean = DashboardTheme(
    id: 'ocean',
    name: 'Ocean',
    primaryColor: Color(0xFF0077BE),
    accentColor: Color(0xFF005F8F),
    cardBackground: Colors.white,
    heartIconColor: Color(0xFF00CED1),
    partnerBorderColor: Color(0xFF0077BE),
    yourBorderColor: Color(0xFF00CED1),
    textPrimaryColor: Color(0xFF003D5C),
    textSecondaryColor: Color(0xFF6B7280),
  );

  // Sunset Theme - Orange & Red
  static final sunset = DashboardTheme(
    id: 'sunset',
    name: 'Sunset',
    primaryColor: Color(0xFFFF6347),
    accentColor: Color(0xFFFF4500),
    cardBackground: Colors.white,
    heartIconColor: Color(0xFFFF1493),
    partnerBorderColor: Color(0xFFFF6347),
    yourBorderColor: Color(0xFFFFD700),
    textPrimaryColor: Color(0xFF8B4513),
    textSecondaryColor: Color(0xFF808080),
  );

  // Forest Theme - Green & Earth tones
  static final forest = DashboardTheme(
    id: 'forest',
    name: 'Forest',
    primaryColor: Color(0xFF228B22),
    accentColor: Color(0xFF2E8B57),
    cardBackground: Colors.white,
    heartIconColor: Color(0xFFFF69B4),
    partnerBorderColor: Color(0xFF228B22),
    yourBorderColor: Color(0xFF8FBC8F),
    textPrimaryColor: Color(0xFF006400),
    textSecondaryColor: Color(0xFF708090),
  );

  // Minimal Theme - Black, White & Grey
  static final minimal = DashboardTheme(
    id: 'minimal',
    name: 'Minimal',
    primaryColor: Color(0xFF2C3E50),
    accentColor: Color(0xFF34495E),
    cardBackground: Colors.white,
    heartIconColor: Color(0xFFE74C3C),
    partnerBorderColor: Color(0xFF2C3E50),
    yourBorderColor: Color(0xFF95A5A6),
    textPrimaryColor: Color(0xFF2C3E50),
    textSecondaryColor: Color(0xFF7F8C8D),
  );

  // Lavender Theme - Purple & Soft colors
  static final lavender = DashboardTheme(
    id: 'lavender',
    name: 'Lavender',
    primaryColor: Color(0xFF9370DB),
    accentColor: Color(0xFF8A2BE2),
    cardBackground: Colors.white,
    heartIconColor: Color(0xFFFF69B4),
    partnerBorderColor: Color(0xFF9370DB),
    yourBorderColor: Color(0xFFDDA0DD),
    textPrimaryColor: Color(0xFF4B0082),
    textSecondaryColor: Color(0xFF9E9E9E),
  );

  // Get all presets as a list
  static List<DashboardTheme> get all => [
    romantic,
    ocean,
    sunset,
    forest,
    minimal,
    lavender,
  ];

  // Get preset by ID
  static DashboardTheme? getById(String id) {
    try {
      return all.firstWhere((theme) => theme.id == id);
    } catch (e) {
      return null;
    }
  }

  // Get default theme
  static DashboardTheme get defaultTheme => romantic;
}
