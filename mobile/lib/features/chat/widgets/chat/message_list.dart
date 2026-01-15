import 'package:flutter/material.dart';
import 'message_bubble.dart';
import '../../../../core/utils/responsive_helper.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../controllers/chat_controller.dart';

class MessageList extends StatelessWidget {
  final ChatController controller;
  final ScrollController scrollController;
  final Future<void> Function() onRefresh;

  const MessageList({
    super.key,
    required this.controller,
    required this.scrollController,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      color: const Color(0xFF0084FF),
      child: ListView.builder(
        controller: scrollController,
        reverse: true,
        padding: EdgeInsets.symmetric(
          vertical: context.space(AppDimensions.spaceM),
        ),
        itemCount: controller.messages.length,
        itemBuilder: (context, index) {
          final reversedIndex = controller.messages.length - 1 - index;
          final message = controller.messages[reversedIndex];

          final isMe =
              controller.currentUserId != null &&
              message.senderId.toString() ==
                  controller.currentUserId.toString();

          final showDateSeparator =
              reversedIndex == controller.messages.length - 1 ||
              !_isSameDay(
                controller.messages[reversedIndex + 1].timestamp,
                message.timestamp,
              );

          return Column(
            children: [
              MessageBubble(message: message, isMe: isMe),
              if (showDateSeparator)
                _buildDateSeparator(context, message.timestamp),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDateSeparator(BuildContext context, DateTime date) {
    String label;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(date.year, date.month, date.day);

    if (messageDate == today) {
      label = 'Today';
    } else if (messageDate == today.subtract(const Duration(days: 1))) {
      label = 'Yesterday';
    } else {
      label = '${date.day}/${date.month}/${date.year}';
    }

    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: context.space(AppDimensions.spaceM),
      ),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: context.space(12),
          vertical: context.space(6),
        ),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.4),
          borderRadius: BorderRadius.circular(context.space(12)),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: context.sp(AppDimensions.fontXXS),
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }
}
