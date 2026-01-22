import 'package:flutter/material.dart';
import '../../../core/utils/responsive_helper.dart';
import '../../../core/constants/app_dimensions.dart';

class SocialAuthButton extends StatelessWidget {
  final String iconPath;
  final VoidCallback? onTap;
  final bool isEnabled;

  const SocialAuthButton({
    super.key,
    required this.iconPath,
    this.onTap,
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final double size = context.space(48);

    return GestureDetector(
      onTap: isEnabled ? onTap : null,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: ResponsiveHelper.radius(context, AppDimensions.radiusM),
          border: Border.all(color: const Color(0xFFE0E0E0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Image.asset(
          iconPath,
          width: context.space(24),
          height: context.space(24),
        ),
      ),
    );
  }
}
