import 'package:flutter/material.dart';
import '../../../../core/widgets/skeleton.dart';
import '../../../../core/utils/responsive_helper.dart';
import '../../../../core/constants/app_dimensions.dart';

class SinglePageSkeleton extends StatelessWidget {
  const SinglePageSkeleton({super.key});

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
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ResponsiveHelper.verticalSpace(context, AppDimensions.spaceXL),

              // Title Skeleton
              SkeletonLine(
                width: context.wp(60),
                height: context.sp(AppDimensions.fontXL),
              ),

              ResponsiveHelper.verticalSpace(context, AppDimensions.spaceM),

              // Subtitle Skeleton
              SkeletonLine(
                width: context.wp(70),
                height: context.sp(AppDimensions.fontS),
              ),
              ResponsiveHelper.verticalSpace(context, AppDimensions.spaceXS),
              SkeletonLine(
                width: context.wp(65),
                height: context.sp(AppDimensions.fontS),
              ),

              ResponsiveHelper.verticalSpace(context, AppDimensions.spaceXL),

              // QR Code Card Skeleton
              Container(
                padding: EdgeInsets.all(context.space(20)),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: ResponsiveHelper.radius(
                    context,
                    AppDimensions.radiusXL,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Skeleton.rectangular(
                  width: context.space(200),
                  height: context.space(200),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),

              ResponsiveHelper.verticalSpace(context, AppDimensions.spaceXL),

              // Button Skeleton
              Skeleton.rectangular(
                width: context.wp(80),
                height: context.space(50),
                borderRadius: BorderRadius.circular(context.space(30)),
              ),

              ResponsiveHelper.verticalSpace(context, AppDimensions.spaceL),

              // Back button skeleton
              SkeletonLine(
                width: context.wp(30),
                height: context.sp(AppDimensions.fontS),
              ),

              ResponsiveHelper.verticalSpace(context, AppDimensions.spaceL),
            ],
          ),
        ),
      ),
    );
  }
}
