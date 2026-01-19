import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../../core/utils/responsive_helper.dart';
import '../../../../../core/constants/app_dimensions.dart';
import '../../../models/chat_models.dart';
import 'message_image_content.dart';

class MessageContentWidget extends StatelessWidget {
  final Message message;
  final bool isMe;

  const MessageContentWidget({
    super.key,
    required this.message,
    required this.isMe,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (message.type == MessageType.image && message.imgUrl != null)
          MessageImageContent(message: message, isMe: isMe)
        else
          _buildTextContent(context),
        ResponsiveHelper.verticalSpace(context, 3),
        Text(
          _formatTimestamp(message.timestamp),
          style: TextStyle(
            color: isMe ? Colors.white70 : Colors.grey[600],
            fontSize: context.sp(10),
          ),
        ),
      ],
    );
  }

  Widget _buildTextContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (message.editedAt != null && !message.isDeleted)
          Padding(
            padding: EdgeInsets.only(top: context.space(4)),
            child: Text(
              'edited',
              style: TextStyle(
                color: isMe ? Colors.white60 : Colors.grey[500],
                fontSize: context.sp(9),
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        Text(
          message.isDeleted ? 'Message has been deleted' : message.content,
          style: TextStyle(
            color: isMe ? Colors.white : Colors.black87,
            fontSize: context.sp(AppDimensions.fontXS),
            fontWeight: FontWeight.w500,
            fontStyle: message.isDeleted ? FontStyle.italic : FontStyle.normal,
          ),
        ),
      ],
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
}
