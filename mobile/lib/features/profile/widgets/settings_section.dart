import 'package:flutter/material.dart';
import '../../../core/utils/responsive_helper.dart';
import '../../../core/constants/app_dimensions.dart';

class SettingsSection extends StatelessWidget {
  final String title;
  final dynamic theme;

  const SettingsSection({super.key, required this.title, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: TextStyle(
          fontSize: context.sp(AppDimensions.fontL),
          fontWeight: FontWeight.bold,
          color: theme.textPrimaryColor,
        ),
      ),
    );
  }
}
