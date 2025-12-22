import 'package:flutter/material.dart';

class ResponsiveHelper {
  // Base design dimensions (iPhone 13 Pro)
  static const double _baseWidth = 390.0;
  static const double _baseHeight = 844.0;

  // Get screen size
  static double screenWidth(BuildContext context) =>
      MediaQuery.of(context).size.width;

  static double screenHeight(BuildContext context) =>
      MediaQuery.of(context).size.height;

  // Responsive Width Percentage
  static double wp(BuildContext context, double percent) =>
      screenWidth(context) * percent / 100;

  // Responsive Height Percentage
  static double hp(BuildContext context, double percent) =>
      screenHeight(context) * percent / 100;

  // Responsive Font Size
  static double sp(BuildContext context, double size) {
    final scaleWidth = screenWidth(context) / _baseWidth;
    final scaleHeight = screenHeight(context) / _baseHeight;
    final scale = (scaleWidth + scaleHeight) / 2;
    return size * scale;
  }

  // Responsive Spacing
  static double space(BuildContext context, double size) {
    return size * screenWidth(context) / _baseWidth;
  }

  // Device Type Checks
  static bool isMobile(BuildContext context) => screenWidth(context) < 600;
  static bool isTablet(BuildContext context) =>
      screenWidth(context) >= 600 && screenWidth(context) < 1024;
  static bool isDesktop(BuildContext context) => screenWidth(context) >= 1024;

  // Safe Area Padding
  static EdgeInsets safeAreaPadding(BuildContext context) =>
      MediaQuery.of(context).padding;

  // Responsive EdgeInsets
  static EdgeInsets symmetric({
    required BuildContext context,
    double horizontal = 0,
    double vertical = 0,
  }) {
    return EdgeInsets.symmetric(
      horizontal: wp(context, horizontal),
      vertical: hp(context, vertical),
    );
  }

  static EdgeInsets all(BuildContext context, double value) {
    return EdgeInsets.all(space(context, value));
  }

  static EdgeInsets only({
    required BuildContext context,
    double left = 0,
    double top = 0,
    double right = 0,
    double bottom = 0,
  }) {
    return EdgeInsets.only(
      left: space(context, left),
      top: space(context, top),
      right: space(context, right),
      bottom: space(context, bottom),
    );
  }

  // Responsive BorderRadius
  static BorderRadius radius(BuildContext context, double radius) {
    return BorderRadius.circular(space(context, radius));
  }

  // Responsive SizedBox
  static SizedBox verticalSpace(BuildContext context, double height) {
    return SizedBox(height: space(context, height));
  }

  static SizedBox horizontalSpace(BuildContext context, double width) {
    return SizedBox(width: space(context, width));
  }

  // Max Width Container for Tablet/Desktop
  static double maxContentWidth(BuildContext context) {
    if (isMobile(context)) return screenWidth(context);
    if (isTablet(context)) return 600;
    return 800;
  }
}

// Extension for easier usage
extension ResponsiveContext on BuildContext {
  double get width => ResponsiveHelper.screenWidth(this);
  double get height => ResponsiveHelper.screenHeight(this);

  double wp(double percent) => ResponsiveHelper.wp(this, percent);
  double hp(double percent) => ResponsiveHelper.hp(this, percent);
  double sp(double size) => ResponsiveHelper.sp(this, size);
  double space(double size) => ResponsiveHelper.space(this, size);

  bool get isMobile => ResponsiveHelper.isMobile(this);
  bool get isTablet => ResponsiveHelper.isTablet(this);
  bool get isDesktop => ResponsiveHelper.isDesktop(this);
}
