import 'package:flutter/material.dart';
import '../../../core/utils/responsive_helper.dart';
import '../../../core/constants/app_dimensions.dart';

class SettingsItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool hasSwitch;
  final bool switchValue;
  final Function(bool)? onSwitchChanged;
  final VoidCallback? onTap;
  final dynamic theme;

  const SettingsItem({
    super.key,
    required this.icon,
    required this.title,
    this.hasSwitch = false,
    this.switchValue = false,
    this.onSwitchChanged,
    this.onTap,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: hasSwitch ? null : onTap,
      child: Container(
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
          children: [
            Icon(
              icon,
              size: context.space(AppDimensions.iconM),
              color: theme.textPrimaryColor,
            ),
            ResponsiveHelper.horizontalSpace(context, AppDimensions.spaceM),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: context.sp(AppDimensions.fontM),
                  color: theme.textPrimaryColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (hasSwitch)
              Switch(
                value: switchValue,
                onChanged: onSwitchChanged,
                activeThumbColor: theme.accentColor,
              )
            else
              Icon(
                Icons.chevron_right,
                size: context.space(AppDimensions.iconM),
                color: theme.textSecondaryColor,
              ),
          ],
        ),
      ),
    );
  }
}
