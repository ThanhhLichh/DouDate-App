import 'package:flutter/material.dart';
import '../../../../core/utils/responsive_helper.dart';

class BackgroundDecoration extends StatelessWidget {
  final dynamic theme;

  const BackgroundDecoration({super.key, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Top left circle
        Positioned(
          top: -context.space(40),
          left: -context.space(40),
          child: Container(
            width: context.space(120),
            height: context.space(120),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: theme.accentColor.withOpacity(0.08),
            ),
          ),
        ),
        // Bottom right circle
        Positioned(
          bottom: -context.space(60),
          right: -context.space(60),
          child: Container(
            width: context.space(200),
            height: context.space(200),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: theme.primaryColor.withOpacity(0.05),
            ),
          ),
        ),
      ],
    );
  }
}
