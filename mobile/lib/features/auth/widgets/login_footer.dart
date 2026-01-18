import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/utils/responsive_helper.dart';
import '../../../core/constants/app_dimensions.dart';

class LoginFooter extends StatelessWidget {
  const LoginFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextButton(
          onPressed: () => context.go('/register'),
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: const Size(0, 0),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            "Create account",
            style: TextStyle(
              color: const Color(0xFF6A5AE0),
              fontSize: context.sp(AppDimensions.fontXS),
            ),
          ),
        ),
        SizedBox(width: context.space(8)),
        Text(
          "|",
          style: TextStyle(
            color: Colors.grey,
            fontSize: context.sp(AppDimensions.fontXS),
          ),
        ),
        SizedBox(width: context.space(8)),
        TextButton(
          onPressed: () {
            // TODO: Navigate to forgot password page
          },
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: const Size(0, 0),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            "Forgot password?",
            style: TextStyle(
              color: const Color(0xFF6A5AE0),
              fontSize: context.sp(AppDimensions.fontXS),
            ),
          ),
        ),
      ],
    );
  }
}
