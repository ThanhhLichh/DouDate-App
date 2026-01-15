import 'package:flutter/material.dart';
import '../../../../core/utils/responsive_helper.dart';
import '../../../../core/constants/app_dimensions.dart';

class ChatLoadingView extends StatelessWidget {
  const ChatLoadingView({super.key});
  @override
  Widget build(BuildContext context) => const Center(
    child: CircularProgressIndicator(
      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0084FF)),
    ),
  );
}

class ChatErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const ChatErrorView({
    super.key,
    required this.message,
    required this.onRetry,
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
            message,
            style: TextStyle(
              fontSize: context.sp(AppDimensions.fontM),
              color: Colors.grey[600],
            ),
          ),
          ResponsiveHelper.verticalSpace(context, AppDimensions.spaceL),
          ElevatedButton(
            onPressed: onRetry,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0084FF),
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}

class ChatEmptyView extends StatelessWidget {
  const ChatEmptyView({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: context.space(AppDimensions.iconXL),
            color: Colors.grey[400],
          ),
          ResponsiveHelper.verticalSpace(context, AppDimensions.spaceM),
          Text(
            'No messages yet',
            style: TextStyle(
              fontSize: context.sp(AppDimensions.fontL),
              color: Colors.grey[600],
              fontWeight: FontWeight.w600,
            ),
          ),
          ResponsiveHelper.verticalSpace(context, AppDimensions.spaceS),
          Text(
            'Say hi to your partner! 💕',
            style: TextStyle(
              fontSize: context.sp(AppDimensions.fontS),
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }
}
