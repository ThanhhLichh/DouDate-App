import 'package:flutter/material.dart';
import '../../../../core/utils/responsive_helper.dart';
import '../../../../core/constants/app_dimensions.dart';

class HomeHeader extends StatelessWidget {
  final dynamic theme;

  const HomeHeader({super.key, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          "DuoDate",
          style: TextStyle(
            fontSize: context.sp(AppDimensions.fontXXL),
            fontWeight: FontWeight.bold,
            color: theme.accentColor,
          ),
        ),
        Text(
          "Your love journey together",
          style: TextStyle(
            color: theme.textSecondaryColor,
            fontSize: context.sp(AppDimensions.fontS),
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
