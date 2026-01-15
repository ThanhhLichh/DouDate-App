import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/utils/responsive_helper.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/theme/theme_constants.dart';
import '../../models/chat_models.dart';
import '../../conversation_settings_page.dart';
import '../../controllers/chat_controller.dart';
import '../../controllers/conversation_controller.dart';

class ChatAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Conversation conversation;
  final VoidCallback? onCallPressed;
  final VoidCallback? onVideoCallPressed;
  final VoidCallback? onInfoPressed;

  const ChatAppBar({
    super.key,
    required this.conversation,
    this.onCallPressed,
    this.onVideoCallPressed,
    this.onInfoPressed,
  });

  @override
  Size get preferredSize => const Size.fromHeight(60);

  @override
  Widget build(BuildContext context) {
    final conversationController = context.watch<ConversationController>();
    final chatController = context.watch<ChatController>();
    final settings = conversationController.settings;

    final displayName =
        settings?.partnerNickname ??
        chatController.partnerName ??
        conversation.partnerName;

    final avatar = chatController.partnerAvatar ?? conversation.partnerAvatar;

    return AppBar(
      backgroundColor: Colors.white,
      elevation: 1,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black87),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Row(
        children: [
          // Avatar with online status
          Stack(
            children: [
              CircleAvatar(
                radius: context.space(20),
                backgroundImage: avatar?.isNotEmpty == true
                    ? NetworkImage(avatar!)
                    : const AssetImage(ThemeConstants.defaultAvatar)
                          as ImageProvider,
              ),
              if (conversation.isOnline)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: context.space(12),
                    height: context.space(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF31A24C),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white,
                        width: context.space(2),
                      ),
                    ),
                  ),
                ),
            ],
          ),

          ResponsiveHelper.horizontalSpace(context, AppDimensions.spaceS),

          // Name and status
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  displayName,
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: context.sp(AppDimensions.fontM),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  conversation.isOnline
                      ? 'Active now'
                      : _formatLastSeen(conversation.lastSeen),
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: context.sp(AppDimensions.fontXXS),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        // Call button
        IconButton(
          icon: Icon(
            Icons.call,
            color: const Color(0xFF0084FF),
            size: context.space(AppDimensions.iconM),
          ),
          onPressed:
              onCallPressed ??
              () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Voice call coming soon!'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
        ),

        // Video call button
        IconButton(
          icon: Icon(
            Icons.videocam,
            color: const Color(0xFF0084FF),
            size: context.space(AppDimensions.iconM),
          ),
          onPressed:
              onVideoCallPressed ??
              () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Video call coming soon!'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
        ),

        // Info button
        IconButton(
          icon: Icon(
            Icons.info_outline,
            color: const Color(0xFF0084FF),
            size: context.space(AppDimensions.iconM),
          ),
          onPressed:
              onInfoPressed ??
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ConversationSettingsPage(),
                  ),
                );
              },
        ),
      ],
    );
  }

  String _formatLastSeen(DateTime? lastSeen) {
    if (lastSeen == null) return 'Offline';

    final now = DateTime.now();
    final difference = now.difference(lastSeen);

    if (difference.inMinutes < 1) {
      return 'Active just now';
    } else if (difference.inMinutes < 60) {
      return 'Active ${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return 'Active ${difference.inHours}h ago';
    } else {
      return 'Active ${difference.inDays}d ago';
    }
  }
}
