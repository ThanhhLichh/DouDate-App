import 'package:flutter/material.dart';
import '../../../core/utils/responsive_helper.dart';
import '../../../core/constants/app_dimensions.dart';

class HomeErrorState extends StatelessWidget {
  final String errorMessage;
  final VoidCallback onRetry;
  final dynamic theme;

  const HomeErrorState({
    super.key,
    required this.errorMessage,
    required this.onRetry,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: context.space(AppDimensions.iconXL),
            color: Colors.red,
          ),
          ResponsiveHelper.verticalSpace(context, AppDimensions.spaceM),
          Text(
            errorMessage,
            style: TextStyle(
              fontSize: context.sp(AppDimensions.fontM),
              color: theme.textSecondaryColor,
            ),
          ),
          ResponsiveHelper.verticalSpace(context, AppDimensions.spaceL),
          ElevatedButton(
            onPressed: onRetry,
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.primaryColor,
              padding: EdgeInsets.symmetric(
                horizontal: context.space(30),
                vertical: context.space(15),
              ),
            ),
            child: Text(
              'Retry',
              style: TextStyle(fontSize: context.sp(AppDimensions.fontM)),
            ),
          ),
        ],
      ),
    );
  }
}
