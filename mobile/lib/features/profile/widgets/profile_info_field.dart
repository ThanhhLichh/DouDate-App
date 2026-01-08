import 'package:flutter/material.dart';
import '../../../core/utils/responsive_helper.dart';
import '../../../core/constants/app_dimensions.dart';

class ProfileInfoField extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback? onEdit;
  final dynamic theme;

  const ProfileInfoField({
    super.key,
    required this.label,
    required this.value,
    required this.onEdit,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: context.sp(AppDimensions.fontXS),
                    color: theme.textSecondaryColor,
                  ),
                ),
                ResponsiveHelper.verticalSpace(context, AppDimensions.spaceXS),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: context.sp(AppDimensions.fontM),
                    color: theme.textPrimaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          if (onEdit != null)
            IconButton(
              onPressed: onEdit,
              icon: Icon(
                Icons.edit_outlined,
                size: context.space(AppDimensions.iconM),
                color: theme.textSecondaryColor,
              ),
            ),
        ],
      ),
    );
  }
}
