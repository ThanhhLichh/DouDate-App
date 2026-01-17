import 'package:flutter/material.dart';
import 'message_bubble.dart';
import '../../../../core/utils/responsive_helper.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../controllers/chat_controller.dart';

class MessageList extends StatefulWidget {
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
  State<MessageList> createState() => _MessageListState();
}

class _MessageListState extends State<MessageList> {
  @override
  void initState() {
    super.initState();
    widget.scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    widget.scrollController.removeListener(_onScroll);
    super.dispose();
  }

  void _onScroll() {
    // Khi scroll gần đến cuối danh sách (90% chiều cao tối đa)
    if (widget.scrollController.position.pixels >=
        widget.scrollController.position.maxScrollExtent * 0.9) {
      if (widget.controller.hasMoreMessages &&
          !widget.controller.isLoadingMore) {
        widget.controller.loadMoreMessages();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: widget.onRefresh,
      color: const Color(0xFF0084FF),
      child: ListView.builder(
        controller: widget.scrollController,
        reverse: true,
        padding: EdgeInsets.symmetric(
          vertical: context.space(AppDimensions.spaceM),
        ),
        itemCount:
            widget.controller.messages.length +
            (widget.controller.hasMoreMessages ? 1 : 0),
        itemBuilder: (context, index) {
          // Loading indicator ở cuối
          if (index == widget.controller.messages.length) {
            return Padding(
              padding: EdgeInsets.all(context.space(16)),
              child: const Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0084FF)),
                ),
              ),
            );
          }

          final reversedIndex = widget.controller.messages.length - 1 - index;
          final message = widget.controller.messages[reversedIndex];

          final isMe =
              widget.controller.currentUserId != null &&
              message.senderId.toString() ==
                  widget.controller.currentUserId.toString();

          final showDateSeparator =
              reversedIndex == widget.controller.messages.length - 1 ||
              !_isSameDay(
                widget.controller.messages[reversedIndex + 1].timestamp,
                message.timestamp,
              );

          return Column(
            children: [
              MessageBubble(
                message: message,
                isMe: isMe,
                controller: widget.controller,
              ),
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
