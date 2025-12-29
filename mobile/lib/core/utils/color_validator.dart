import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/theme_constants.dart';

class ColorValidator {
  /// Calculate relative luminance of a color
  /// Based on WCAG 2.0 formula
  static double _calculateLuminance(Color color) {
    double r = color.r;
    double g = color.g;
    double b = color.b;

    r = r <= 0.03928
        ? r / 12.92
        : math.pow((r + 0.055) / 1.055, 2.4).toDouble();
    g = g <= 0.03928
        ? g / 12.92
        : math.pow((g + 0.055) / 1.055, 2.4).toDouble();
    b = b <= 0.03928
        ? b / 12.92
        : math.pow((b + 0.055) / 1.055, 2.4).toDouble();

    return 0.2126 * r + 0.7152 * g + 0.0722 * b;
  }

  /// Calculate contrast ratio between two colors
  /// Returns value between 1 and 21
  static double calculateContrastRatio(Color color1, Color color2) {
    double lum1 = _calculateLuminance(color1);
    double lum2 = _calculateLuminance(color2);

    double lighter = math.max(lum1, lum2);
    double darker = math.min(lum1, lum2);

    return (lighter + 0.05) / (darker + 0.05);
  }

  /// Check if two colors have sufficient contrast (WCAG AA)
  static bool hasSufficientContrast(Color foreground, Color background) {
    double ratio = calculateContrastRatio(foreground, background);
    return ratio >= ThemeConstants.minContrastRatio;
  }

  /// Get brightness value of a color (0-255)
  static double getBrightness(Color color) {
    final r = (color.r * 255.0).round().clamp(0, 255);
    final g = (color.g * 255.0).round().clamp(0, 255);
    final b = (color.b * 255.0).round().clamp(0, 255);

    return (r * 299 + g * 587 + b * 114) / 1000;
  }

  /// Check if color is considered "light"
  static bool isLightColor(Color color) {
    return getBrightness(color) > 128;
  }

  /// Check if color is considered "dark"
  static bool isDarkColor(Color color) {
    return !isLightColor(color);
  }

  /// Suggest text color (black or white) for a background
  static Color suggestTextColor(Color backgroundColor) {
    return isLightColor(backgroundColor) ? Colors.black : Colors.white;
  }

  /// Calculate brightness difference between two colors
  static double calculateBrightnessDifference(Color color1, Color color2) {
    return (getBrightness(color1) - getBrightness(color2)).abs();
  }

  /// Validate if a color combination is accessible
  static ColorValidationResult validateColorCombination(
    Color foreground,
    Color background,
  ) {
    double contrastRatio = calculateContrastRatio(foreground, background);
    double brightnessDiff = calculateBrightnessDifference(
      foreground,
      background,
    );

    bool meetsContrast = contrastRatio >= ThemeConstants.minContrastRatio;
    bool meetsBrightness =
        brightnessDiff >= ThemeConstants.minBrightnessDifference;

    return ColorValidationResult(
      isValid: meetsContrast && meetsBrightness,
      contrastRatio: contrastRatio,
      brightnessDifference: brightnessDiff,
      meetsContrastRequirement: meetsContrast,
      meetsBrightnessRequirement: meetsBrightness,
    );
  }

  /// Adjust color to ensure it meets contrast requirements
  static Color adjustColorForContrast(
    Color color,
    Color background, {
    bool preferLighter = true,
  }) {
    if (hasSufficientContrast(color, background)) {
      return color;
    }

    // Try adjusting brightness
    HSLColor hsl = HSLColor.fromColor(color);
    double step = 0.05;

    for (int i = 0; i < 20; i++) {
      double newLightness = preferLighter
          ? math.min(1.0, hsl.lightness + step * i)
          : math.max(0.0, hsl.lightness - step * i);

      Color adjusted = hsl.withLightness(newLightness).toColor();

      if (hasSufficientContrast(adjusted, background)) {
        return adjusted;
      }
    }

    // If adjustment failed, return black or white
    return suggestTextColor(background);
  }

  /// Generate a complementary color
  static Color getComplementaryColor(Color color) {
    HSLColor hsl = HSLColor.fromColor(color);
    double newHue = (hsl.hue + 180) % 360;
    return hsl.withHue(newHue).toColor();
  }

  /// Generate analogous colors
  static List<Color> getAnalogousColors(Color color, {int count = 2}) {
    HSLColor hsl = HSLColor.fromColor(color);
    List<Color> colors = [];
    double step = 30.0;

    for (int i = 1; i <= count; i++) {
      double newHue = (hsl.hue + step * i) % 360;
      colors.add(hsl.withHue(newHue).toColor());
    }

    return colors;
  }

  /// Lighten a color by a percentage (0.0 to 1.0)
  static Color lighten(Color color, double amount) {
    assert(amount >= 0 && amount <= 1);
    HSLColor hsl = HSLColor.fromColor(color);
    double newLightness = math.min(1.0, hsl.lightness + amount);
    return hsl.withLightness(newLightness).toColor();
  }

  /// Darken a color by a percentage (0.0 to 1.0)
  static Color darken(Color color, double amount) {
    assert(amount >= 0 && amount <= 1);
    HSLColor hsl = HSLColor.fromColor(color);
    double newLightness = math.max(0.0, hsl.lightness - amount);
    return hsl.withLightness(newLightness).toColor();
  }
}

class ColorValidationResult {
  final bool isValid;
  final double contrastRatio;
  final double brightnessDifference;
  final bool meetsContrastRequirement;
  final bool meetsBrightnessRequirement;

  ColorValidationResult({
    required this.isValid,
    required this.contrastRatio,
    required this.brightnessDifference,
    required this.meetsContrastRequirement,
    required this.meetsBrightnessRequirement,
  });

  String get message {
    if (isValid) return 'Color combination is accessible';

    List<String> issues = [];
    if (!meetsContrastRequirement) {
      issues.add(
        'Insufficient contrast (${contrastRatio.toStringAsFixed(2)}:1)',
      );
    }
    if (!meetsBrightnessRequirement) {
      issues.add(
        'Insufficient brightness difference (${brightnessDifference.toStringAsFixed(0)})',
      );
    }

    return issues.join(', ');
  }
}
