import 'package:flutter/material.dart';
import '../../../core/utils/responsive_helper.dart';
import '../../../core/constants/app_dimensions.dart';

class LogoutButton extends StatelessWidget {
  final VoidCallback onLogout;
  final dynamic theme;

  const LogoutButton({super.key, required this.onLogout, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: context.space(20),
        vertical: context.space(15),
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: ResponsiveHelper.radius(context, AppDimensions.radiusL),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextButton.icon(
        onPressed: onLogout,
        icon: Icon(
          Icons.logout,
          color: Colors.red,
          size: context.space(AppDimensions.iconM),
        ),
        label: Text(
          'Log Out',
          style: TextStyle(
            fontSize: context.sp(AppDimensions.fontM),
            color: Colors.red,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
