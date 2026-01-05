import 'package:flutter/material.dart';
import '../../../core/utils/responsive_helper.dart';
import '../../../core/constants/app_dimensions.dart';

class SettingsHeader extends StatelessWidget {
  final dynamic theme;

  const SettingsHeader({super.key, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Text(
      "Profile & Settings",
      style: TextStyle(
        fontSize: context.sp(AppDimensions.fontXL),
        fontWeight: FontWeight.bold,
        color: theme.accentColor,
      ),
    );
  }
}
