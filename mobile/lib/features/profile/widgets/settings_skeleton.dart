import 'package:flutter/material.dart';
import '../../../core/widgets/skeleton.dart';
import '../../../core/utils/responsive_helper.dart';
import '../../../core/constants/app_dimensions.dart';

class SettingsPageSkeleton extends StatelessWidget {
  const SettingsPageSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        constraints: BoxConstraints(
          maxWidth: ResponsiveHelper.maxContentWidth(context),
        ),
        child: SingleChildScrollView(
          padding: ResponsiveHelper.symmetric(
            context: context,
            horizontal: context.isMobile ? 5 : 8,
            vertical: 3,
          ),
          child: Column(
            children: [
              ResponsiveHelper.verticalSpace(context, AppDimensions.spaceM),

              // Header Skeleton
              SkeletonLine(
                width: context.wp(50),
                height: context.sp(AppDimensions.fontXL),
              ),

              ResponsiveHelper.verticalSpace(context, AppDimensions.spaceXL),

              // Avatar Skeleton
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: context.space(140),
                    height: context.space(140),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.5),
                    ),
                  ),
                  SkeletonAvatar(size: context.space(100)),
                ],
              ),

              ResponsiveHelper.verticalSpace(context, AppDimensions.spaceL),

              // Section Title Skeleton
              Align(
                alignment: Alignment.centerLeft,
                child: SkeletonLine(
                  width: context.wp(30),
                  height: context.sp(AppDimensions.fontL),
                ),
              ),

              ResponsiveHelper.verticalSpace(context, AppDimensions.spaceM),

              // Profile Info Fields Skeleton
              _buildInfoFieldSkeleton(context),
              ResponsiveHelper.verticalSpace(context, AppDimensions.spaceM),
              _buildInfoFieldSkeleton(context),
              ResponsiveHelper.verticalSpace(context, AppDimensions.spaceM),
              _buildInfoFieldSkeleton(context),

              ResponsiveHelper.verticalSpace(context, AppDimensions.spaceL),

              // Connection Status Card Skeleton
              _buildConnectionCardSkeleton(context),

              ResponsiveHelper.verticalSpace(context, AppDimensions.spaceXL),

              // Settings Section Title Skeleton
              Align(
                alignment: Alignment.centerLeft,
                child: SkeletonLine(
                  width: context.wp(25),
                  height: context.sp(AppDimensions.fontL),
                ),
              ),

              ResponsiveHelper.verticalSpace(context, AppDimensions.spaceM),

              // Settings Items Skeleton
              _buildSettingsItemSkeleton(context),
              ResponsiveHelper.verticalSpace(context, AppDimensions.spaceS),
              _buildSettingsItemSkeleton(context),
              ResponsiveHelper.verticalSpace(context, AppDimensions.spaceS),
              _buildSettingsItemSkeleton(context),

              ResponsiveHelper.verticalSpace(context, AppDimensions.spaceXL),

              // Logout Button Skeleton
              _buildLogoutButtonSkeleton(context),

              ResponsiveHelper.verticalSpace(context, AppDimensions.spaceL),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoFieldSkeleton(BuildContext context) {
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
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SkeletonLine(
            width: context.wp(100),
            height: context.sp(AppDimensions.fontXS),
            borderRadius: BorderRadius.circular(4),
          ),
          ResponsiveHelper.verticalSpace(context, AppDimensions.spaceXS),
          SkeletonLine(
            width: context.wp(45),
            height: context.sp(AppDimensions.fontM),
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
    );
  }

  Widget _buildConnectionCardSkeleton(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(context.space(20)),
      decoration: BoxDecoration(
        color: Colors.white,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SkeletonLine(
            width: context.wp(35),
            height: context.sp(AppDimensions.fontM),
            borderRadius: BorderRadius.circular(4),
          ),
          ResponsiveHelper.verticalSpace(context, AppDimensions.spaceM),
          Row(
            children: [
              SkeletonAvatar(size: context.space(50)),
              ResponsiveHelper.horizontalSpace(context, AppDimensions.spaceM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SkeletonLine(
                      width: context.wp(30),
                      height: context.sp(AppDimensions.fontS),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    ResponsiveHelper.verticalSpace(
                      context,
                      AppDimensions.spaceXS,
                    ),
                    SkeletonLine(
                      width: context.wp(25),
                      height: context.sp(AppDimensions.fontXS),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsItemSkeleton(BuildContext context) {
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
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Skeleton.circle(size: context.space(AppDimensions.iconM)),
          ResponsiveHelper.horizontalSpace(context, AppDimensions.spaceM),
          Expanded(
            child: SkeletonLine(
              height: context.sp(AppDimensions.fontM),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          ResponsiveHelper.horizontalSpace(context, AppDimensions.spaceM),
          Skeleton.circle(size: context.space(AppDimensions.iconM)),
        ],
      ),
    );
  }

  Widget _buildLogoutButtonSkeleton(BuildContext context) {
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
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Skeleton.circle(size: context.space(AppDimensions.iconM)),
          ResponsiveHelper.horizontalSpace(context, AppDimensions.spaceM),
          SkeletonLine(
            width: context.wp(15),
            height: context.sp(AppDimensions.fontM),
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
    );
  }
}
