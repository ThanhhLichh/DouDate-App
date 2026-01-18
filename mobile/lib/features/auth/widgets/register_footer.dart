import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/utils/responsive_helper.dart';
import '../../../core/constants/app_dimensions.dart';

class RegisterFooter extends StatelessWidget {
  final bool isLoading;

  const RegisterFooter({super.key, required this.isLoading});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Already have an account?",
          style: TextStyle(fontSize: context.sp(AppDimensions.fontS)),
        ),
        TextButton(
          onPressed: isLoading ? null : () => context.go('/login'),
          style: TextButton.styleFrom(
            padding: EdgeInsets.symmetric(horizontal: context.space(4)),
          ),
          child: Text(
            "Login",
            style: TextStyle(
              color: const Color(0xFF6A5AE0),
              fontSize: context.sp(AppDimensions.fontS),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
