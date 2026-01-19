import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import '../../../../core/utils/responsive_helper.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../models/chat_models.dart';
import '../../controllers/conversation_controller.dart';
import '../../controllers/chat_controller.dart';

// ✅ GIẢI PHÁP: StatefulWidget để listen stream hoặc dùng AnimatedBuilder
class MessageBubble extends StatefulWidget {
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
  State<MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<MessageBubble> {
  late Message _currentMessage;

  @override
  void initState() {
    super.initState();
    _currentMessage = widget.message;
    // ✅ Listen to controller để update message khi có thay đổi
    widget.controller.addListener(_updateMessage);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_updateMessage);
    super.dispose();
  }

  void _updateMessage() {
    // ✅ Tìm message mới nhất trong controller
    final updatedMessage = widget.controller.messages.firstWhere(
      (m) => m.id == widget.message.id,
      orElse: () => widget.message,
    );

    // ✅ Chỉ setState nếu reactions thực sự thay đổi
    if (!_reactionsEqual(
      _currentMessage.reactionsByUserId,
      updatedMessage.reactionsByUserId,
    )) {
      setState(() {
        _currentMessage = updatedMessage;
      });
    }
  }

  bool _reactionsEqual(Map<int, String>? a, Map<int, String>? b) {
    if (a == null && b == null) return true;
    if (a == null || b == null) return false;
    if (a.length != b.length) return false;

    for (var key in a.keys) {
      if (a[key] != b[key]) return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    // ✅ CHỈ select bubbleColor và avatar - KHÔNG listen messages
    return Selector<ConversationController, _BubbleData>(
      selector: (_, conversationController) {
        return _BubbleData(
          bubbleColor:
              conversationController.settings?.bubbleColor ?? '#0084FF',
          avatar:
              widget.controller.partnerAvatar ??
              conversationController.conversation?.partnerAvatar,
        );
      },
      builder: (context, data, child) {
        final hasAvatar = data.avatar != null && data.avatar!.isNotEmpty;

        return Padding(
          padding: EdgeInsets.fromLTRB(
            widget.isMe ? context.space(4) : context.space(12),
            context.space(6),
            widget.isMe ? context.space(2) : context.space(12),
            context.space(6),
          ),
          child: Row(
            mainAxisAlignment: widget.isMe
                ? MainAxisAlignment.end
                : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (!widget.isMe) ...[
                CircleAvatar(
                  radius: context.space(14),
                  backgroundColor: Colors.grey[300],
                  backgroundImage: hasAvatar
                      ? NetworkImage(data.avatar!)
                      : null,
                  child: hasAvatar
                      ? null
                      : Text(
                          _currentMessage.senderName![0].toUpperCase(),
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
                    onLongPress: () => _showMessageOptions(context, data),
                    child: Column(
                      crossAxisAlignment: widget.isMe
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
                                color: widget.isMe
                                    ? Color(
                                        int.parse(
                                              data.bubbleColor.substring(1),
                                              radix: 16,
                                            ) +
                                            0xFF000000,
                                      )
                                    : const Color(0xFFF0F2F5),
                                borderRadius: BorderRadius.circular(
                                  context.space(18),
                                ),
                              ),
                              child: _buildMessageContent(context, data),
                            ),

                            // ✅ Sử dụng _currentMessage.reactionsByUserId
                            if (_currentMessage.reactionsByUserId != null &&
                                _currentMessage.reactionsByUserId!.isNotEmpty)
                              _buildReactionBadge(
                                context,
                                _currentMessage.reactionsByUserId!,
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              if (widget.isMe) ...[
                ResponsiveHelper.horizontalSpace(context, AppDimensions.spaceS),
                Icon(
                  _currentMessage.isRead ? Icons.done_all : Icons.done,
                  size: context.space(16),
                  color: _currentMessage.isRead
                      ? Color(
                          int.parse(data.bubbleColor.substring(1), radix: 16) +
                              0xFF000000,
                        )
                      : Colors.grey[600],
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildMessageContent(BuildContext context, _BubbleData data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (_currentMessage.type == MessageType.image &&
            _currentMessage.imgUrl != null)
          GestureDetector(
            onTap: () => _showZoomableImage(context, _currentMessage.imgUrl!),
            child: Hero(
              tag: 'msg_img_${_currentMessage.id}',
              child: ClipRRect(
                borderRadius: BorderRadius.circular(context.space(12)),
                child: Image.network(
                  _currentMessage.thumbnailUrl ?? _currentMessage.imgUrl!,
                  width: context.space(200),
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      width: context.space(200),
                      height: context.space(150),
                      color: widget.isMe ? Colors.white24 : Colors.grey[300],
                      child: const Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.broken_image, color: Colors.grey),
                ),
              ),
            ),
          )
        else
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_currentMessage.editedAt != null &&
                  !_currentMessage.isDeleted)
                Padding(
                  padding: EdgeInsets.only(top: context.space(4)),
                  child: Text(
                    'edited',
                    style: TextStyle(
                      color: widget.isMe ? Colors.white60 : Colors.grey[500],
                      fontSize: context.sp(9),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              Text(
                _currentMessage.isDeleted
                    ? 'Message has been deleted'
                    : _currentMessage.content,
                style: TextStyle(
                  color: widget.isMe ? Colors.white : Colors.black87,
                  fontSize: context.sp(AppDimensions.fontXS),
                  fontWeight: FontWeight.w500,
                  fontStyle: _currentMessage.isDeleted
                      ? FontStyle.italic
                      : FontStyle.normal,
                ),
              ),
            ],
          ),

        ResponsiveHelper.verticalSpace(context, 3),
        Text(
          _formatTimestamp(_currentMessage.timestamp),
          style: TextStyle(
            color: widget.isMe ? Colors.white70 : Colors.grey[600],
            fontSize: context.sp(10),
          ),
        ),
      ],
    );
  }

  Widget _buildReactionBadge(BuildContext context, Map<int, String> reactions) {
    return Positioned(
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
            borderRadius: BorderRadius.circular(context.space(8)),
            border: Border.all(color: Colors.grey[300]!, width: 0.5),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: () {
              final reactionCounts = <String, int>{};
              for (var emoji in reactions.values) {
                reactionCounts[emoji] = (reactionCounts[emoji] ?? 0) + 1;
              }

              return reactionCounts.entries.map((entry) {
                final emoji = entry.key;
                final count = entry.value;

                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: context.space(1)),
                  child: Row(
                    children: [
                      Text(
                        emoji,
                        style: TextStyle(fontSize: context.sp(9), height: 1.2),
                      ),
                      if (count > 1)
                        Padding(
                          padding: EdgeInsets.only(left: context.space(2)),
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

  void _showMessageOptions(BuildContext context, _BubbleData data) {
    final quickEmoji =
        context.read<ConversationController>().settings?.quickEmoji ?? '❤️';
    final commonEmojis = ['❤️', '👍', '😂', '😮', '😢', '😡'];

    final canEdit =
        widget.isMe &&
        _currentMessage.canEditOrDelete(widget.controller.currentUserId ?? 0);

    // ✅ Unfocus để đóng keyboard
    FocusScope.of(context).unfocus();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: false,
      enableDrag: true,
      builder: (modalContext) => Container(
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
                      Navigator.pop(modalContext);
                      Future.microtask(() {
                        FocusScope.of(context).unfocus();
                        widget.controller.reactToMessage(
                          _currentMessage.id,
                          quickEmoji,
                        );
                      });
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
                    Navigator.pop(modalContext);
                    Future.microtask(() {
                      FocusScope.of(context).unfocus();
                      widget.controller.reactToMessage(
                        _currentMessage.id,
                        emoji,
                      );
                    });
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

            if (canEdit || !_currentMessage.isDeleted) ...[
              ResponsiveHelper.verticalSpace(context, AppDimensions.spaceL),
              Divider(color: Colors.grey[300]),
              ResponsiveHelper.verticalSpace(context, AppDimensions.spaceS),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  if (!_currentMessage.isDeleted)
                    _buildIconButton(
                      context: context,
                      icon: Icons.copy,
                      label: 'Copy',
                      color: Colors.grey[700]!,
                      onTap: () {
                        Navigator.pop(modalContext);
                        _copyToClipboard(context);
                      },
                    ),

                  if (canEdit)
                    _buildIconButton(
                      context: context,
                      icon: Icons.edit,
                      label: 'Edit',
                      color: const Color(0xFF0084FF),
                      onTap: () {
                        Navigator.pop(modalContext);
                        Future.delayed(const Duration(milliseconds: 100), () {
                          _showEditDialog(context);
                        });
                      },
                    ),

                  if (canEdit)
                    _buildIconButton(
                      context: context,
                      icon: Icons.delete,
                      label: 'Delete',
                      color: Colors.red,
                      onTap: () {
                        Navigator.pop(modalContext);
                        Future.delayed(const Duration(milliseconds: 100), () {
                          _showDeleteConfirmation(context);
                        });
                      },
                    ),
                ],
              ),
            ],

            ResponsiveHelper.verticalSpace(context, AppDimensions.spaceM),
          ],
        ),
      ),
    ).then((_) {
      Future.microtask(() => FocusScope.of(context).unfocus());
    });
  }

  void _showEditDialog(BuildContext context) {
    final textController = TextEditingController(text: _currentMessage.content);

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
              if (newContent.isEmpty || newContent == _currentMessage.content) {
                Navigator.pop(context);
                return;
              }

              final success = await widget.controller.updateMessage(
                _currentMessage.id,
                newContent,
              );
              if (context.mounted) {
                Navigator.pop(context);
                if (!success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        widget.controller.errorMessage ??
                            'Failed to edit message',
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
              final success = await widget.controller.deleteMessage(
                _currentMessage.id,
              );
              if (context.mounted) {
                Navigator.pop(context);
                if (!success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        widget.controller.errorMessage ??
                            'Failed to delete message',
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
                tag: 'msg_img_${_currentMessage.id}',
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
    if (_currentMessage.isDeleted) return;

    await Clipboard.setData(ClipboardData(text: _currentMessage.content));

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

// ✅ GIẢM _BubbleData xuống chỉ còn bubbleColor và avatar
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
