import 'package:flutter/material.dart';
import '../../../../core/widgets/skeleton.dart';
import '../../../../core/utils/responsive_helper.dart';
import '../../../../core/constants/app_dimensions.dart';

class HomePageSkeleton extends StatelessWidget {
  const HomePageSkeleton({super.key});

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
                width: context.wp(40),
                height: context.sp(AppDimensions.fontXXL),
              ),
              ResponsiveHelper.verticalSpace(context, AppDimensions.spaceXS),
              SkeletonLine(
                width: context.wp(50),
                height: context.sp(AppDimensions.fontS),
              ),

              ResponsiveHelper.verticalSpace(context, AppDimensions.spaceXL),

              // Couple Card Skeleton
              _buildCoupleCardSkeleton(context),

              ResponsiveHelper.verticalSpace(context, AppDimensions.spaceL),

              // Quote Card Skeleton
              _buildQuoteCardSkeleton(context),

              ResponsiveHelper.verticalSpace(context, AppDimensions.spaceL),

              // Stats Grid Skeleton
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child: _buildStatCardSkeleton(context)),
                  ResponsiveHelper.horizontalSpace(
                    context,
                    AppDimensions.spaceM,
                  ),
                  Expanded(child: _buildStatCardSkeleton(context)),
                  ResponsiveHelper.horizontalSpace(
                    context,
                    AppDimensions.spaceM,
                  ),
                  Expanded(child: _buildStatCardSkeleton(context)),
                ],
              ),

              ResponsiveHelper.verticalSpace(context, AppDimensions.spaceL),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCoupleCardSkeleton(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: context.space(30),
        horizontal: context.space(20),
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: ResponsiveHelper.radius(context, AppDimensions.radiusXL),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Avatars Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              SkeletonAvatar(size: context.space(80)),
              Skeleton.circle(size: context.space(30)),
              SkeletonAvatar(size: context.space(80)),
            ],
          ),

          ResponsiveHelper.verticalSpace(context, AppDimensions.spaceM),

          // Names
          SkeletonLine(
            width: context.wp(50),
            height: context.sp(AppDimensions.fontL),
          ),

          ResponsiveHelper.verticalSpace(context, AppDimensions.spaceL),

          // Together for text
          SkeletonLine(
            width: context.wp(30),
            height: context.sp(AppDimensions.fontS),
          ),

          ResponsiveHelper.verticalSpace(context, AppDimensions.spaceXS),

          // Days number
          Skeleton.rectangular(
            width: context.space(120),
            height: context.sp(48),
            borderRadius: BorderRadius.circular(8),
          ),

          ResponsiveHelper.verticalSpace(context, AppDimensions.spaceXS),

          // Beautiful days text
          SkeletonLine(
            width: context.wp(35),
            height: context.sp(AppDimensions.fontS),
          ),
        ],
      ),
    );
  }

  Widget _buildQuoteCardSkeleton(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(context.space(20)),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Skeleton.circle(size: context.space(AppDimensions.iconL)),
          ResponsiveHelper.horizontalSpace(context, AppDimensions.spaceM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonLine(
                  width: context.wp(25),
                  height: context.sp(AppDimensions.fontXS),
                ),
                ResponsiveHelper.verticalSpace(context, AppDimensions.spaceXS),
                SkeletonLine(
                  width: double.infinity,
                  height: context.sp(AppDimensions.fontS),
                ),
                ResponsiveHelper.verticalSpace(context, AppDimensions.spaceXS),
                SkeletonLine(
                  width: context.wp(60),
                  height: context.sp(AppDimensions.fontS),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCardSkeleton(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(context.space(15)),
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
      child: Column(
        children: [
          Skeleton.circle(size: context.space(AppDimensions.iconL)),
          ResponsiveHelper.verticalSpace(context, AppDimensions.spaceS),
          SkeletonLine(
            width: context.space(40),
            height: context.sp(AppDimensions.fontL),
          ),
          ResponsiveHelper.verticalSpace(context, AppDimensions.spaceXS),
          SkeletonLine(
            width: context.space(50),
            height: context.sp(AppDimensions.fontXS),
          ),
        ],
      ),
    );
  }
}
