import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import '../../../../core/utils/responsive_helper.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../models/chat_models.dart';
import '../../controllers/conversation_controller.dart';
import '../../controllers/chat_controller.dart';

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
    final chatController = context.watch<ChatController>();
    final conversationController = context.watch<ConversationController>();
    final settings = conversationController.settings;
    final bubbleColor = settings?.bubbleColor ?? '#0084FF';

    final avatar =
        chatController.partnerAvatar ??
        conversationController.conversation?.partnerAvatar;

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
                onLongPress: () => _showMessageOptions(context, chatController),
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
                              if (message.type == MessageType.image &&
                                  message.imgUrl != null)
                                GestureDetector(
                                  onTap: () => _showZoomableImage(
                                    context,
                                    message.imgUrl!,
                                  ),
                                  child: Hero(
                                    tag: 'msg_img_${message.id}',
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(
                                        context.space(12),
                                      ),
                                      child: Image.network(
                                        message.thumbnailUrl ?? message.imgUrl!,
                                        width: context.space(200),
                                        fit: BoxFit.cover,
                                        loadingBuilder:
                                            (context, child, loadingProgress) {
                                              if (loadingProgress == null) {
                                                return child;
                                              }
                                              return Container(
                                                width: context.space(200),
                                                height: context.space(150),
                                                color: isMe
                                                    ? Colors.white24
                                                    : Colors.grey[300],
                                                child: const Center(
                                                  child:
                                                      CircularProgressIndicator(
                                                        strokeWidth: 2,
                                                      ),
                                                ),
                                              );
                                            },
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                const Icon(
                                                  Icons.broken_image,
                                                  color: Colors.grey,
                                                ),
                                      ),
                                    ),
                                  ),
                                )
                              else
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (message.editedAt != null &&
                                        !message.isDeleted)
                                      Padding(
                                        padding: EdgeInsets.only(
                                          top: context.space(4),
                                        ),
                                        child: Text(
                                          'edited',
                                          style: TextStyle(
                                            color: isMe
                                                ? Colors.white60
                                                : Colors.grey[500],
                                            fontSize: context.sp(9),
                                            fontStyle: FontStyle.italic,
                                          ),
                                        ),
                                      ),
                                    Text(
                                      message.isDeleted
                                          ? 'This message has been deleted'
                                          : message.content,
                                      style: TextStyle(
                                        color: isMe
                                            ? Colors.white
                                            : Colors.black87,
                                        fontSize: context.sp(
                                          AppDimensions.fontS,
                                        ),
                                        fontStyle: message.isDeleted
                                            ? FontStyle.italic
                                            : FontStyle.normal,
                                      ),
                                    ),
                                  ],
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
                            bottom: -context.space(10),
                            right: 0,
                            child: Transform.translate(
                              offset: Offset(-context.space(6), 0),
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: context.space(6),
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
                                  children: () {
                                    final reactionCounts = <String, int>{};
                                    for (var emoji
                                        in message.reactionsByUserId!.values) {
                                      reactionCounts[emoji] =
                                          (reactionCounts[emoji] ?? 0) + 1;
                                    }

                                    return reactionCounts.entries.map((entry) {
                                      final emoji = entry.key;
                                      final count = entry.value;

                                      return Padding(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: context.space(1),
                                        ),
                                        child: Row(
                                          children: [
                                            Text(
                                              emoji,
                                              style: TextStyle(
                                                fontSize: context.sp(9),
                                                height: 1.2,
                                              ),
                                            ),
                                            if (count > 1)
                                              Padding(
                                                padding: EdgeInsets.only(
                                                  left: context.space(2),
                                                ),
                                                child: Text(
                                                  '$count',
                                                  style: TextStyle(
                                                    fontSize: context.sp(9),
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.grey[700],
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                      );
                                    }).toList();
                                  }(),
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

  void _showMessageOptions(
    BuildContext context,
    ChatController chatController,
  ) {
    final conversationController = context.read<ConversationController>();
    final quickEmoji = conversationController.settings?.quickEmoji ?? '❤️';
    final commonEmojis = ['❤️', '👍', '😂', '😮', '😢', '😡'];

    final canEdit =
        isMe && message.canEditOrDelete(controller.currentUserId ?? 0);

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
                      chatController.reactToMessage(message.id, quickEmoji);
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
                        style: TextStyle(fontSize: context.sp(16)),
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
                      fontSize: context.sp(AppDimensions.fontXS),
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
                    chatController.reactToMessage(message.id, emoji);
                    Navigator.pop(context);
                  },
                  child: Container(
                    padding: EdgeInsets.all(context.space(8)),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      emoji,
                      style: TextStyle(fontSize: context.sp(16)),
                    ),
                  ),
                );
              }).toList(),
            ),

            // Edit/Delete/Copy options (icon buttons nằm ngang)
            if (canEdit || !message.isDeleted) ...[
              ResponsiveHelper.verticalSpace(context, AppDimensions.spaceL),
              Divider(color: Colors.grey[300]),
              ResponsiveHelper.verticalSpace(context, AppDimensions.spaceS),

              // Icon buttons row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Copy button
                  if (!message.isDeleted)
                    _buildIconButton(
                      context: context,
                      icon: Icons.copy,
                      label: 'Copy',
                      color: Colors.grey[700]!,
                      onTap: () {
                        Navigator.pop(context);
                        _copyToClipboard(context);
                      },
                    ),

                  // Edit button (chỉ hiện nếu có thể edit)
                  if (canEdit)
                    _buildIconButton(
                      context: context,
                      icon: Icons.edit,
                      label: 'Edit',
                      color: const Color(0xFF0084FF),
                      onTap: () {
                        Navigator.pop(context);
                        _showEditDialog(context);
                      },
                    ),

                  // Delete button (chỉ hiện nếu có thể delete)
                  if (canEdit)
                    _buildIconButton(
                      context: context,
                      icon: Icons.delete,
                      label: 'Delete',
                      color: Colors.red,
                      onTap: () {
                        Navigator.pop(context);
                        _showDeleteConfirmation(context);
                      },
                    ),
                ],
              ),
            ],

            ResponsiveHelper.verticalSpace(context, AppDimensions.spaceM),
          ],
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context) {
    final textController = TextEditingController(text: message.content);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Message'),
        content: TextField(
          controller: textController,
          maxLines: 3,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Enter new message',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final newContent = textController.text.trim();
              if (newContent.isEmpty || newContent == message.content) {
                Navigator.pop(context);
                return;
              }

              final success = await controller.updateMessage(
                message.id,
                newContent,
              );
              if (context.mounted) {
                Navigator.pop(context);
                if (!success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        controller.errorMessage ?? 'Failed to edit message',
                      ),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Message'),
        content: const Text('Are you sure you want to delete this message?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final success = await controller.deleteMessage(message.id);
              if (context.mounted) {
                Navigator.pop(context);
                if (!success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        controller.errorMessage ?? 'Failed to delete message',
                      ),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showZoomableImage(BuildContext context, String imageUrl) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: Center(
            child: InteractiveViewer(
              panEnabled: true,
              minScale: 0.5,
              maxScale: 4.0,
              child: Hero(
                tag: 'msg_img_${message.id}',
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => const Center(
                    child: Icon(
                      Icons.broken_image,
                      color: Colors.white54,
                      size: 64,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _copyToClipboard(BuildContext context) async {
    if (message.isDeleted) return;

    await Clipboard.setData(ClipboardData(text: message.content));

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Message copied to clipboard'),
          duration: const Duration(seconds: 2),
          backgroundColor: Colors.grey[800],
        ),
      );
    }
  }

  // Helper method to build icon button for message options
  Widget _buildIconButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(context.space(12)),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: context.space(16),
          vertical: context.space(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(context.space(10)),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: context.space(24)),
            ),
            ResponsiveHelper.verticalSpace(context, 6),
            Text(
              label,
              style: TextStyle(
                fontSize: context.sp(12),
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
