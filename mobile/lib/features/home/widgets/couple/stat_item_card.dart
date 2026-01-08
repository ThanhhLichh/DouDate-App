import 'package:flutter/material.dart';
import '../../../../core/utils/responsive_helper.dart';
import '../../../../core/constants/app_dimensions.dart';

class StatItemCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final dynamic theme;

  const StatItemCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(context.space(15)),
      decoration: BoxDecoration(
        color: theme.cardBackground,
        borderRadius: ResponsiveHelper.radius(context, AppDimensions.radiusL),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: theme.textSecondaryColor,
            size: context.space(AppDimensions.iconL),
          ),
          ResponsiveHelper.verticalSpace(context, AppDimensions.spaceS),
          Text(
            value,
            style: TextStyle(
              fontSize: context.sp(AppDimensions.fontL),
              fontWeight: FontWeight.bold,
              color: theme.textPrimaryColor,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: context.sp(AppDimensions.fontXXS),
              color: theme.textSecondaryColor,
            ),
          ),
        ],
      ),
    );
  }
}
