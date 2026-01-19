import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/utils/responsive_helper.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../models/chat_models.dart';
import '../../controllers/conversation_controller.dart';
import '../../controllers/chat_controller.dart';
import 'message_content/message_content_widget.dart';
import 'message_content/message_reaction_badge.dart';
import 'message_actions/message_options_sheet.dart';

class MessageBubble extends StatelessWidget {
  final Message message;
  final bool isMe;
  final ChatController controller;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isMe,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Selector<ChatController, _MessageData>(
      selector: (_, controller) {
        final currentMessage = controller.messages.firstWhere(
          (m) => m.id == message.id,
          orElse: () => message,
        );

        return _MessageData(
          reactions: currentMessage.reactionsByUserId ?? {},
          isRead: currentMessage.isRead,
          content: currentMessage.content,
          isDeleted: currentMessage.isDeleted,
          editedAt: currentMessage.editedAt,
        );
      },
      builder: (context, messageData, _) {
        final currentMessage = controller.messages.firstWhere(
          (m) => m.id == message.id,
          orElse: () => message,
        );

        debugPrint('[MessageBubble] Building message ${message.id}');
        debugPrint('Reactions: ${currentMessage.reactionsByUserId}');

        return Selector<ConversationController, _BubbleData>(
          selector: (_, conversationController) {
            return _BubbleData(
              bubbleColor:
                  conversationController.settings?.bubbleColor ?? '#0084FF',
              avatar:
                  controller.partnerAvatar ??
                  conversationController.conversation?.partnerAvatar,
            );
          },
          builder: (context, data, child) {
            final hasAvatar = data.avatar != null && data.avatar!.isNotEmpty;

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
                    _buildAvatar(context, hasAvatar, data, currentMessage),
                    ResponsiveHelper.horizontalSpace(
                      context,
                      AppDimensions.spaceS,
                    ),
                  ],
                  Flexible(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.7,
                      ),
                      child: GestureDetector(
                        onLongPress: () =>
                            _showMessageOptions(context, data, currentMessage),
                        child: _buildMessageBubble(
                          context,
                          data,
                          currentMessage,
                        ),
                      ),
                    ),
                  ),
                  if (isMe) ...[
                    ResponsiveHelper.horizontalSpace(
                      context,
                      AppDimensions.spaceS,
                    ),
                    _buildReadStatus(context, data, currentMessage),
                  ],
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildAvatar(
    BuildContext context,
    bool hasAvatar,
    _BubbleData data,
    Message currentMessage,
  ) {
    return CircleAvatar(
      radius: context.space(14),
      backgroundColor: Colors.grey[300],
      backgroundImage: hasAvatar ? NetworkImage(data.avatar!) : null,
      child: hasAvatar
          ? null
          : Text(
              currentMessage.senderName![0].toUpperCase(),
              style: TextStyle(
                fontSize: context.sp(AppDimensions.fontXS),
                fontWeight: FontWeight.bold,
              ),
            ),
    );
  }

  Widget _buildMessageBubble(
    BuildContext context,
    _BubbleData data,
    Message currentMessage,
  ) {
    return Column(
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
                        int.parse(data.bubbleColor.substring(1), radix: 16) +
                            0xFF000000,
                      )
                    : const Color(0xFFF0F2F5),
                borderRadius: BorderRadius.circular(context.space(18)),
              ),
              child: MessageContentWidget(message: currentMessage, isMe: isMe),
            ),
            if (currentMessage.reactionsByUserId != null &&
                currentMessage.reactionsByUserId!.isNotEmpty)
              MessageReactionBadge(
                reactions: currentMessage.reactionsByUserId!,
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildReadStatus(
    BuildContext context,
    _BubbleData data,
    Message currentMessage,
  ) {
    return Icon(
      currentMessage.isRead ? Icons.done_all : Icons.done,
      size: context.space(16),
      color: currentMessage.isRead
          ? Color(
              int.parse(data.bubbleColor.substring(1), radix: 16) + 0xFF000000,
            )
          : Colors.grey[600],
    );
  }

  void _showMessageOptions(
    BuildContext context,
    _BubbleData data,
    Message currentMessage,
  ) {
    FocusScope.of(context).unfocus();

    showMessageOptionsSheet(
      context: context,
      message: currentMessage,
      isMe: isMe,
      controller: controller,
      bubbleColor: data.bubbleColor,
    );
  }
}

// Data classes for Selector comparison
class _MessageData {
  final Map<int, String> reactions;
  final bool isRead;
  final String content;
  final bool isDeleted;
  final DateTime? editedAt;

  _MessageData({
    required this.reactions,
    required this.isRead,
    required this.content,
    required this.isDeleted,
    required this.editedAt,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _MessageData &&
          runtimeType == other.runtimeType &&
          _mapsEqual(reactions, other.reactions) &&
          isRead == other.isRead &&
          content == other.content &&
          isDeleted == other.isDeleted &&
          editedAt == other.editedAt;

  @override
  int get hashCode =>
      reactions.hashCode ^
      isRead.hashCode ^
      content.hashCode ^
      isDeleted.hashCode ^
      editedAt.hashCode;

  bool _mapsEqual(Map<int, String> a, Map<int, String> b) {
    if (a.length != b.length) return false;
    for (var key in a.keys) {
      if (a[key] != b[key]) return false;
    }
    return true;
  }
}

class _BubbleData {
  final String bubbleColor;
  final String? avatar;

  _BubbleData({required this.bubbleColor, required this.avatar});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _BubbleData &&
          runtimeType == other.runtimeType &&
          bubbleColor == other.bubbleColor &&
          avatar == other.avatar;

  @override
  int get hashCode => bubbleColor.hashCode ^ avatar.hashCode;
}
