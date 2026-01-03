import 'package:flutter/material.dart';
import 'dashboard_theme.dart';

class ThemePresets {
  // Romantic Theme - Pink & Purple
  static final romantic = DashboardTheme(
    id: 'romantic',
    name: 'Romantic',
    primaryColor: Color(0xFFF08080), // Light Coral
    accentColor: Color(0xFF5D535E), // Muted Purple
    cardBackground: Color(0xFFFFFBFA),
    heartIconColor: Color(0xFFE91E63),
    partnerBorderColor: Color(0xFFF08080),
    yourBorderColor: Color(0xFFADA397),
    textPrimaryColor: Color(0xFF4A4A4A),
    textSecondaryColor: Color(0xFF9E9E9E),
  );

  // Ocean Theme - Blue & Teal
  static final ocean = DashboardTheme(
    id: 'ocean',
    name: 'Ocean',
    primaryColor: Color(0xFF2A52BE), // Cerulean
    accentColor: Color(0xFF1E3A8A),
    cardBackground: Color(0xFFF0F9FF),
    heartIconColor: Color(0xFF06B6D4),
    partnerBorderColor: Color(0xFF2A52BE),
    yourBorderColor: Color(0xFF94A3B8),
    textPrimaryColor: Color(0xFF0F172A),
    textSecondaryColor: Color(0xFF64748B),
  );

  // Sunset Theme - Orange & Red
  static final sunset = DashboardTheme(
    id: 'sunset',
    name: 'Sunset',
    primaryColor: Color(0xFFE67E22), // Carrot Orange
    accentColor: Color(0xFFD35400),
    cardBackground: Color(0xFFFFF8F0),
    heartIconColor: Color(0xFFE74C3C),
    partnerBorderColor: Color(0xFFE67E22),
    yourBorderColor: Color(0xFFF1C40F),
    textPrimaryColor: Color(0xFF3E2723),
    textSecondaryColor: Color(0xFF8D6E63),
  );

  // Forest Theme - Green & Earth tones
  static final forest = DashboardTheme(
    id: 'forest',
    name: 'Forest',
    primaryColor: Color(0xFF626F47), // Sage Green
    accentColor: Color(0xFF3F4E28),
    cardBackground: Color(0xFFF7F8F5),
    heartIconColor: Color(0xFFBC8F8F),
    partnerBorderColor: Color(0xFF626F47),
    yourBorderColor: Color(0xFFA9B388),
    textPrimaryColor: Color(0xFF1B1F13),
    textSecondaryColor: Color(0xFF6B705C),
  );

  // Minimal Theme - Black, White & Grey
  static final minimal = DashboardTheme(
    id: 'minimal',
    name: 'Minimal',
    primaryColor: Color(0xFF334155), // Slate 700
    accentColor: Color(0xFF0F172A),
    cardBackground: Colors.white,
    heartIconColor: Color(0xFF94A3B8),
    partnerBorderColor: Color(0xFF334155),
    yourBorderColor: Color(0xFFCBD5E1),
    textPrimaryColor: Color(0xFF1E293B),
    textSecondaryColor: Color(0xFF94A3B8),
  );

  // Lavender Theme - Purple & Soft colors
  static final lavender = DashboardTheme(
    id: 'lavender',
    name: 'Lavender',
    primaryColor: Color(0xFF818CF8), // Indigo Light
    accentColor: Color(0xFF4F46E5),
    cardBackground: Color(0xFFF5F3FF),
    heartIconColor: Color(0xFFEC4899),
    partnerBorderColor: Color(0xFF818CF8),
    yourBorderColor: Color(0xFFC4B5FD),
    textPrimaryColor: Color(0xFF312E81),
    textSecondaryColor: Color(0xFF6366F1),
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
