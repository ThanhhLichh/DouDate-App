import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/utils/responsive_helper.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/providers/dashboard_theme_provider.dart';
import '../../../../core/theme/theme_constants.dart';
import '../../models/home_models.dart';

class CoupleCard extends StatelessWidget {
  final CoupleDashboard data;
  final dynamic theme;

  const CoupleCard({super.key, required this.data, required this.theme});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<File?>(
      future: context.read<DashboardThemeProvider>().getCoupleBackgroundImage(),
      builder: (context, snapshot) {
        final hasCustomBackground = snapshot.hasData && snapshot.data != null;

        return Container(
          padding: EdgeInsets.symmetric(
            vertical: context.space(30),
            horizontal: context.space(20),
          ),
          decoration: BoxDecoration(
            image: hasCustomBackground
                ? DecorationImage(
                    image: FileImage(snapshot.data!),
                    fit: BoxFit.cover,
                    opacity: 0.95,
                  )
                : const DecorationImage(
                    image: AssetImage(ThemeConstants.defaultCoupleBackground),
                    fit: BoxFit.cover,
                    opacity: 0.95,
                  ),
            borderRadius: ResponsiveHelper.radius(
              context,
              AppDimensions.radiusXL,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 20,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildAvatar(
                    context,
                    data.yourAvatar ?? '',
                    theme.yourBorderColor,
                  ),
                  Icon(
                    Icons.favorite,
                    color: theme.heartIconColor,
                    size: context.space(AppDimensions.iconXL),
                  ),
                  _buildAvatar(
                    context,
                    data.partnerAvatar ?? '',
                    theme.partnerBorderColor,
                  ),
                ],
              ),
              ResponsiveHelper.verticalSpace(context, AppDimensions.spaceM),
              Text(
                "${data.yourName}      &      ${data.partnerName}",
                style: TextStyle(
                  color: theme.textPrimaryColor,
                  fontSize: context.sp(AppDimensions.fontL),
                  fontWeight: FontWeight.w600,
                ),
              ),
              ResponsiveHelper.verticalSpace(context, AppDimensions.spaceL),
              Text(
                "Together for",
                style: TextStyle(
                  color: theme.textPrimaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: context.sp(AppDimensions.fontS),
                ),
              ),
              ResponsiveHelper.verticalSpace(context, AppDimensions.spaceXS),
              Text(
                "${data.daysTogether}",
                style: TextStyle(
                  fontSize: context.sp(48),
                  fontWeight: FontWeight.bold,
                  color: theme.textPrimaryColor,
                ),
              ),
              Text(
                "beautiful days",
                style: TextStyle(
                  color: theme.textPrimaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: context.sp(AppDimensions.fontS),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAvatar(BuildContext context, String avatarUrl, Color color) {
    return Container(
      padding: EdgeInsets.all(context.space(3)),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: color, width: context.space(2)),
      ),
      child: CircleAvatar(
        radius: context.space(40),
        backgroundColor: Colors.transparent,
        backgroundImage: avatarUrl.isNotEmpty
            ? NetworkImage(avatarUrl)
            : const AssetImage(ThemeConstants.defaultAvatar) as ImageProvider,
      ),
    );
  }
}
