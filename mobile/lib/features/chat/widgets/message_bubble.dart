import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/utils/responsive_helper.dart';
import '../../../core/constants/app_dimensions.dart';
import '../models/chat_models.dart';
import '../chat_controller.dart';

class MessageBubble extends StatelessWidget {
  final Message message;
  final bool isMe;

  const MessageBubble({super.key, required this.message, required this.isMe});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<ChatController>();
    final settings = controller.settings;
    final bubbleColor = settings?.bubbleColor ?? '#0084FF';

    final avatar =
        controller.partnerAvatar ?? controller.conversation?.partnerAvatar;

    final hasAvatar = avatar != null && avatar.isNotEmpty;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        isMe ? context.space(4) : context.space(12),
        context.space(6),
        isMe ? context.space(2) : context.space(12),
        context.space(6),
      ),
      child: Row(
        mainAxisAlignment: isMe
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            CircleAvatar(
              radius: context.space(14),
              backgroundColor: Colors.grey[300],
              backgroundImage: hasAvatar ? NetworkImage(avatar) : null,
              child: hasAvatar
                  ? null
                  : Text(
                      message.senderName![0].toUpperCase(),
                      style: TextStyle(
                        fontSize: context.sp(AppDimensions.fontXS),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),

            ResponsiveHelper.horizontalSpace(context, AppDimensions.spaceS),
          ],

          Flexible(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.7,
              ),
              child: GestureDetector(
                onLongPress: () => _showReactionPicker(context, controller),
                child: Column(
                  crossAxisAlignment: isMe
                      ? CrossAxisAlignment.end
                      : CrossAxisAlignment.start,
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: context.space(16),
                            vertical: context.space(10),
                          ),
                          decoration: BoxDecoration(
                            color: isMe
                                ? Color(
                                    int.parse(
                                          bubbleColor.substring(1),
                                          radix: 16,
                                        ) +
                                        0xFF000000,
                                  )
                                : const Color(0xFFF0F2F5),
                            borderRadius: BorderRadius.circular(
                              context.space(18),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                message.content,
                                style: TextStyle(
                                  color: isMe ? Colors.white : Colors.black87,
                                  fontSize: context.sp(AppDimensions.fontS),
                                ),
                              ),
                              ResponsiveHelper.verticalSpace(context, 3),
                              Text(
                                _formatTimestamp(message.timestamp),
                                style: TextStyle(
                                  color: isMe
                                      ? Colors.white70
                                      : Colors.grey[600],
                                  fontSize: context.sp(10),
                                ),
                              ),
                            ],
                          ),
                        ),

                        if (message.reactionsByUserId != null &&
                            message.reactionsByUserId!.isNotEmpty)
                          Positioned(
                            bottom: -context.space(6),
                            right: 0,
                            child: Transform.translate(
                              offset: Offset(-context.space(6), 0),
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: context.space(4),
                                  vertical: context.space(1),
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(
                                    context.space(8),
                                  ),
                                  border: Border.all(
                                    color: Colors.grey[300]!,
                                    width: 0.5,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: message.reactionsByUserId!.values
                                      .map((emoji) {
                                        return Padding(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: context.space(0.5),
                                          ),
                                          child: Text(
                                            emoji,
                                            style: TextStyle(
                                              fontSize: context.sp(9),
                                              height: 1.2,
                                            ),
                                          ),
                                        );
                                      })
                                      .toList(),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          if (isMe) ...[
            ResponsiveHelper.horizontalSpace(context, AppDimensions.spaceS),
            Icon(
              message.isRead ? Icons.done_all : Icons.done,
              size: context.space(16),
              color: message.isRead
                  ? Color(
                      int.parse(bubbleColor.substring(1), radix: 16) +
                          0xFF000000,
                    )
                  : Colors.grey[600],
            ),
          ],
        ],
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return DateFormat('HH:mm').format(timestamp);
    } else if (difference.inDays < 7) {
      return DateFormat('E, HH:mm').format(timestamp);
    } else {
      return DateFormat('MMM d, HH:mm').format(timestamp);
    }
  }

  void _showReactionPicker(BuildContext context, ChatController controller) {
    final quickEmoji = controller.settings?.quickEmoji ?? '❤️';
    final commonEmojis = ['❤️', '👍', '😂', '😮', '😢', '😡'];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(context.space(20)),
          ),
        ),
        padding: EdgeInsets.all(context.space(20)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Quick reaction
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: context.space(12)),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(context.space(12)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () {
                      controller.reactToMessage(message.id, quickEmoji);
                      Navigator.pop(context);
                    },
                    child: Container(
                      padding: EdgeInsets.all(context.space(12)),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0084FF).withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        quickEmoji,
                        style: TextStyle(fontSize: context.sp(32)),
                      ),
                    ),
                  ),
                  ResponsiveHelper.horizontalSpace(
                    context,
                    AppDimensions.spaceS,
                  ),
                  Text(
                    'Quick Reaction',
                    style: TextStyle(
                      fontSize: context.sp(AppDimensions.fontS),
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ),
            ResponsiveHelper.verticalSpace(context, AppDimensions.spaceL),
            // All reactions
            Wrap(
              spacing: context.space(16),
              runSpacing: context.space(16),
              alignment: WrapAlignment.center,
              children: commonEmojis.map((emoji) {
                return GestureDetector(
                  onTap: () {
                    controller.reactToMessage(message.id, emoji);
                    Navigator.pop(context);
                  },
                  child: Container(
                    padding: EdgeInsets.all(context.space(12)),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      emoji,
                      style: TextStyle(fontSize: context.sp(28)),
                    ),
                  ),
                );
              }).toList(),
            ),
            ResponsiveHelper.verticalSpace(context, AppDimensions.spaceL),
          ],
        ),
      ),
    );
  }
}
