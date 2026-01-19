import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../../../core/utils/responsive_helper.dart';
import '../../../../../core/constants/app_dimensions.dart';
import '../../../models/chat_models.dart';
import '../../../controllers/chat_controller.dart';
import '../../../controllers/conversation_controller.dart';
import 'message_action_button.dart';
import 'message_edit_dialog.dart';
import 'message_delete_dialog.dart';

void showMessageOptionsSheet({
  required BuildContext context,
  required Message message,
  required bool isMe,
  required ChatController controller,
  required String bubbleColor,
}) {
  final quickEmoji =
      context.read<ConversationController>().settings?.quickEmoji ?? '❤️';
  final commonEmojis = ['❤️', '👍', '😂', '😮', '😢', '😡'];

  final canEdit =
      isMe && message.canEditOrDelete(controller.currentUserId ?? 0);

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
          _buildQuickReaction(
            context,
            modalContext,
            quickEmoji,
            controller,
            message,
          ),
          ResponsiveHelper.verticalSpace(context, AppDimensions.spaceL),
          _buildEmojiGrid(
            context,
            modalContext,
            commonEmojis,
            controller,
            message,
          ),
          if (canEdit || !message.isDeleted) ...[
            ResponsiveHelper.verticalSpace(context, AppDimensions.spaceL),
            Divider(color: Colors.grey[300]),
            ResponsiveHelper.verticalSpace(context, AppDimensions.spaceS),
            _buildActionButtons(
              context,
              modalContext,
              message,
              canEdit,
              controller,
            ),
          ],
          ResponsiveHelper.verticalSpace(context, AppDimensions.spaceM),
        ],
      ),
    ),
  ).then((_) {
    Future.microtask(() {
      if (context.mounted) {
        FocusScope.of(context).unfocus();
      }
    });
  });
}

Widget _buildQuickReaction(
  BuildContext context,
  BuildContext modalContext,
  String quickEmoji,
  ChatController controller,
  Message message,
) {
  return Container(
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
              if (context.mounted) {
                FocusScope.of(context).unfocus();
              }
              controller.reactToMessage(message.id, quickEmoji);
            });
          },
          child: Container(
            padding: EdgeInsets.all(context.space(12)),
            decoration: BoxDecoration(
              color: const Color(0xFF0084FF).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Text(quickEmoji, style: TextStyle(fontSize: context.sp(16))),
          ),
        ),
        ResponsiveHelper.horizontalSpace(context, AppDimensions.spaceS),
        Text(
          'Quick Reaction',
          style: TextStyle(
            fontSize: context.sp(AppDimensions.fontXS),
            color: Colors.grey[700],
          ),
        ),
      ],
    ),
  );
}

Widget _buildEmojiGrid(
  BuildContext context,
  BuildContext modalContext,
  List<String> emojis,
  ChatController controller,
  Message message,
) {
  return Wrap(
    spacing: context.space(16),
    runSpacing: context.space(16),
    alignment: WrapAlignment.center,
    children: emojis.map((emoji) {
      return GestureDetector(
        onTap: () {
          Navigator.pop(modalContext);
          Future.microtask(() {
            if (context.mounted) {
              FocusScope.of(context).unfocus();
            }
            controller.reactToMessage(message.id, emoji);
          });
        },
        child: Container(
          padding: EdgeInsets.all(context.space(8)),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            shape: BoxShape.circle,
          ),
          child: Text(emoji, style: TextStyle(fontSize: context.sp(16))),
        ),
      );
    }).toList(),
  );
}

Widget _buildActionButtons(
  BuildContext context,
  BuildContext modalContext,
  Message message,
  bool canEdit,
  ChatController controller,
) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    children: [
      if (!message.isDeleted)
        MessageActionButton(
          icon: Icons.copy,
          label: 'Copy',
          color: Colors.grey[700]!,
          onTap: () {
            Navigator.pop(modalContext);
            _copyToClipboard(context, message);
          },
        ),
      if (canEdit)
        MessageActionButton(
          icon: Icons.edit,
          label: 'Edit',
          color: const Color(0xFF0084FF),
          onTap: () {
            Navigator.pop(modalContext);
            Future.delayed(const Duration(milliseconds: 100), () {
              if (!context.mounted) return;
              showMessageEditDialog(context, message, controller);
            });
          },
        ),
      if (canEdit)
        MessageActionButton(
          icon: Icons.delete,
          label: 'Delete',
          color: Colors.red,
          onTap: () {
            Navigator.pop(modalContext);
            Future.delayed(const Duration(milliseconds: 100), () {
              if (!context.mounted) return;
              showMessageDeleteDialog(context, message, controller);
            });
          },
        ),
    ],
  );
}

void _copyToClipboard(BuildContext context, Message message) async {
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
