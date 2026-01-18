import 'package:flutter/material.dart';
import '../../../core/utils/responsive_helper.dart';

class AuthLogo extends StatelessWidget {
  final String imagePath;

  const AuthLogo({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      imagePath,
      height: context.hp(context.isMobile ? 20 : 18),
    );
  }
}
