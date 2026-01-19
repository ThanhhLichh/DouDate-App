import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/utils/responsive_helper.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/theme/theme_constants.dart';
import '../../models/chat_models.dart';
import '../../pages/conversation_settings_page.dart';
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
    // Chỉ select những field thực sự cần thiết
    return Selector2<ConversationController, ChatController, _AppBarData>(
      selector: (_, conversationController, chatController) {
        final conversation = conversationController.conversation;
        if (conversation == null) {
          return _AppBarData(
            displayName: 'Unknown',
            avatar: null,
            isOnline: false,
            lastSeen: null,
          );
        }

        return _AppBarData(
          displayName:
              conversationController.settings?.partnerNickname ??
              chatController.partnerName ??
              conversation.partnerName,
          avatar: chatController.partnerAvatar ?? conversation.partnerAvatar,
          isOnline: conversation.isOnline,
          lastSeen: conversation.lastSeen,
        );
      },
      builder: (context, data, child) {
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
                    backgroundImage: data.avatar?.isNotEmpty == true
                        ? NetworkImage(data.avatar!)
                        : const AssetImage(ThemeConstants.defaultAvatar)
                              as ImageProvider,
                  ),
                  if (data.isOnline)
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
                      data.displayName,
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: context.sp(AppDimensions.fontM),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      data.isOnline
                          ? 'Active now'
                          : _formatLastSeen(data.lastSeen),
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
      },
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

// Data class để so sánh chính xác khi nào cần rebuild
class _AppBarData {
  final String displayName;
  final String? avatar;
  final bool isOnline;
  final DateTime? lastSeen;

  _AppBarData({
    required this.displayName,
    required this.avatar,
    required this.isOnline,
    required this.lastSeen,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _AppBarData &&
          runtimeType == other.runtimeType &&
          displayName == other.displayName &&
          avatar == other.avatar &&
          isOnline == other.isOnline &&
          lastSeen == other.lastSeen;

  @override
  int get hashCode =>
      displayName.hashCode ^
      avatar.hashCode ^
      isOnline.hashCode ^
      lastSeen.hashCode;
}
