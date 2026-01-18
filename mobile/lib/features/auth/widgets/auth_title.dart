import 'package:flutter/material.dart';
import '../../../core/utils/responsive_helper.dart';
import '../../../core/constants/app_dimensions.dart';

class AuthTitle extends StatelessWidget {
  final String title;
  final Color color;

  const AuthTitle({super.key, required this.title, required this.color});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        fontSize: context.sp(AppDimensions.fontXXL),
        fontWeight: FontWeight.bold,
        color: color,
      ),
    );
  }
}
