import 'package:flutter/material.dart';
import '../../../core/utils/responsive_helper.dart';
import '../../../core/constants/app_dimensions.dart';

class AuthButton extends StatelessWidget {
  final String text;
  final bool isLoading;
  final VoidCallback? onTap;
  final Gradient gradient;

  const AuthButton({
    super.key,
    required this.text,
    required this.isLoading,
    required this.onTap,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: context.space(15)),
        decoration: BoxDecoration(
          borderRadius: ResponsiveHelper.radius(
            context,
            AppDimensions.radiusXL,
          ),
          gradient: gradient,
        ),
        child: Center(
          child: isLoading
              ? SizedBox(
                  height: context.space(24),
                  width: context.space(24),
                  child: const CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : Text(
                  text,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: context.sp(AppDimensions.fontL),
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),
      ),
    );
  }
}
