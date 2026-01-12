import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/utils/responsive_helper.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/theme/theme_constants.dart';
import 'chat_controller.dart';
import 'models/conversation_settings_models.dart';
import 'widgets/media_gallery_page.dart';

class ConversationSettingsPage extends StatefulWidget {
  const ConversationSettingsPage({super.key});

  @override
  State<ConversationSettingsPage> createState() =>
      _ConversationSettingsPageState();
}

class _ConversationSettingsPageState extends State<ConversationSettingsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChatController>().loadSettings();
      context.read<ChatController>().loadMediaItems();
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<ChatController>();
    final conversation = controller.conversation;
    final settings = controller.settings;

    if (conversation == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Conversation Settings')),
        body: const Center(child: Text('No conversation found')),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: const Text(
          'Conversation Settings',
          style: TextStyle(color: Colors.black87),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        children: [
          // Partner Info Header
          _buildPartnerHeader(context, conversation, settings),

          const SizedBox(height: 16),

          // Nicknames
          _buildNicknamesSection(context, controller, settings),

          const SizedBox(height: 16),

          // Background Theme
          _buildBackgroundThemeSection(context, controller, settings),

          const SizedBox(height: 16),

          // Bubble Color
          _buildBubbleColorSection(context, controller, settings),

          const SizedBox(height: 16),

          // Quick Emoji
          _buildQuickEmojiSection(context, controller, settings),

          const SizedBox(height: 16),

          // Media Gallery
          _buildMediaSection(context, controller),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildPartnerHeader(
    BuildContext context,
    conversation,
    ConversationSettings? settings,
  ) {
    final controller = context.watch<ChatController>();

    // Use nickname if set
    final displayName =
        settings?.partnerNickname ??
        controller.partnerName ??
        conversation.partnerName;

    final avatar = controller.partnerAvatar ?? conversation.partnerAvatar;

    return Container(
      color: Colors.white,
      padding: EdgeInsets.all(context.space(20)),
      child: Column(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: context.space(40),
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
                    width: context.space(16),
                    height: context.space(16),
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
          ResponsiveHelper.verticalSpace(context, AppDimensions.spaceM),
          Text(
            displayName,
            style: TextStyle(
              fontSize: context.sp(AppDimensions.fontL),
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            conversation.isOnline ? 'Active now' : 'Offline',
            style: TextStyle(
              fontSize: context.sp(AppDimensions.fontS),
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNicknamesSection(
    BuildContext context,
    ChatController controller,
    ConversationSettings? settings,
  ) {
    return Container(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(context.space(16)),
            child: Text(
              'Nicknames',
              style: TextStyle(
                fontSize: context.sp(AppDimensions.fontM),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          _buildSettingItem(
            context,
            icon: Icons.person,
            title: 'Your nickname',
            subtitle: settings?.yourNickname ?? 'Not set',
            onTap: () => _showNicknameDialog(
              context,
              controller,
              isYours: true,
              currentNickname: settings?.yourNickname,
            ),
          ),
          Divider(height: 1, color: Colors.grey[200]),
          _buildSettingItem(
            context,
            icon: Icons.person_outline,
            title: 'Partner\'s nickname',
            subtitle: settings?.partnerNickname ?? 'Not set',
            onTap: () => _showNicknameDialog(
              context,
              controller,
              isYours: false,
              currentNickname: settings?.partnerNickname,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackgroundThemeSection(
    BuildContext context,
    ChatController controller,
    ConversationSettings? settings,
  ) {
    final currentTheme =
        settings?.backgroundTheme ?? BackgroundTheme.defaultTheme;

    return Container(
      color: Colors.white,
      padding: EdgeInsets.all(context.space(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Chat Background',
            style: TextStyle(
              fontSize: context.sp(AppDimensions.fontM),
              fontWeight: FontWeight.bold,
            ),
          ),
          ResponsiveHelper.verticalSpace(context, AppDimensions.spaceS),
          Text(
            'Message color will be adjusted automatically',
            style: TextStyle(
              fontSize: context.sp(AppDimensions.fontXS),
              color: Colors.grey[600],
            ),
          ),
          ResponsiveHelper.verticalSpace(context, AppDimensions.spaceM),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: context.space(12),
              mainAxisSpacing: context.space(12),
              childAspectRatio: 1,
            ),
            itemCount: BackgroundTheme.values.length,
            itemBuilder: (context, index) {
              final theme = BackgroundTheme.values[index];
              final isSelected = currentTheme == theme;

              return GestureDetector(
                onTap: () async {
                  final success = await controller.updateBackgroundTheme(theme);
                  if (success && mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Background theme updated!'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  }
                },
                child: Container(
                  decoration: BoxDecoration(
                    gradient: theme.previewGradient,
                    borderRadius: BorderRadius.circular(context.space(12)),
                    border: isSelected
                        ? Border.all(color: const Color(0xFF0084FF), width: 3)
                        : Border.all(color: Colors.grey[300]!, width: 1),
                  ),
                  child: Stack(
                    children: [
                      // Theme name
                      Positioned(
                        bottom: context.space(8),
                        left: 0,
                        right: 0,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: context.space(4),
                            vertical: context.space(4),
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(
                              context.space(4),
                            ),
                          ),
                          child: Text(
                            theme.displayName,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: context.sp(10),
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      // Selected indicator
                      if (isSelected)
                        Center(
                          child: Container(
                            padding: EdgeInsets.all(context.space(8)),
                            decoration: const BoxDecoration(
                              color: Color(0xFF0084FF),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.check,
                              color: Colors.white,
                              size: context.space(20),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBubbleColorSection(
    BuildContext context,
    ChatController controller,
    ConversationSettings? settings,
  ) {
    final currentColor = settings?.bubbleColor ?? '#0084FF';

    return Container(
      color: Colors.white,
      padding: EdgeInsets.all(context.space(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Message Color',
            style: TextStyle(
              fontSize: context.sp(AppDimensions.fontM),
              fontWeight: FontWeight.bold,
            ),
          ),
          ResponsiveHelper.verticalSpace(context, AppDimensions.spaceM),
          Wrap(
            spacing: context.space(12),
            runSpacing: context.space(12),
            children: BubbleColorOption.options.map((option) {
              final isSelected = currentColor == option.hexColor;
              return GestureDetector(
                onTap: () async {
                  final success = await controller.updateBubbleColor(
                    option.hexColor,
                  );
                  if (success && mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Message color updated!'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  }
                },
                child: Container(
                  width: context.space(50),
                  height: context.space(50),
                  decoration: BoxDecoration(
                    color: Color(
                      int.parse(option.hexColor.substring(1), radix: 16) +
                          0xFF000000,
                    ),
                    shape: BoxShape.circle,
                    border: isSelected
                        ? Border.all(color: Colors.black, width: 3)
                        : null,
                  ),
                  child: isSelected
                      ? const Icon(Icons.check, color: Colors.white)
                      : null,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickEmojiSection(
    BuildContext context,
    ChatController controller,
    ConversationSettings? settings,
  ) {
    final emojis = ['❤️', '👍', '😂', '😮', '😢', '😡', '🎉', '🔥'];
    final currentEmoji = settings?.quickEmoji ?? '👍';

    return Container(
      color: Colors.white,
      padding: EdgeInsets.all(context.space(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Reaction',
            style: TextStyle(
              fontSize: context.sp(AppDimensions.fontM),
              fontWeight: FontWeight.bold,
            ),
          ),
          ResponsiveHelper.verticalSpace(context, AppDimensions.spaceM),
          Wrap(
            spacing: context.space(12),
            runSpacing: context.space(12),
            children: emojis.map((emoji) {
              final isSelected = currentEmoji == emoji;
              return GestureDetector(
                onTap: () async {
                  final success = await controller.updateQuickEmoji(emoji);
                  if (success && mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Quick reaction updated!'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  }
                },
                child: Container(
                  width: context.space(50),
                  height: context.space(50),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF0084FF).withOpacity(0.1)
                        : Colors.grey[100],
                    shape: BoxShape.circle,
                    border: isSelected
                        ? Border.all(color: const Color(0xFF0084FF), width: 2)
                        : null,
                  ),
                  child: Center(
                    child: Text(
                      emoji,
                      style: TextStyle(fontSize: context.sp(24)),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildMediaSection(BuildContext context, ChatController controller) {
    final mediaCount = controller.mediaItems.length;

    return Container(
      color: Colors.white,
      child: _buildSettingItem(
        context,
        icon: Icons.photo_library,
        title: 'Shared Photos & Videos',
        subtitle: '$mediaCount items',
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const MediaGalleryPage()),
          );
        },
      ),
    );
  }

  Widget _buildSettingItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF0084FF)),
      title: Text(
        title,
        style: TextStyle(fontSize: context.sp(AppDimensions.fontM)),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: context.sp(AppDimensions.fontS),
          color: Colors.grey[600],
        ),
      ),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
    );
  }

  Future<void> _showNicknameDialog(
    BuildContext context,
    ChatController controller, {
    required bool isYours,
    String? currentNickname,
  }) async {
    final textController = TextEditingController(text: currentNickname);

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isYours ? 'Your Nickname' : 'Partner\'s Nickname'),
        content: TextField(
          controller: textController,
          decoration: const InputDecoration(
            hintText: 'Enter nickname',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final nickname = textController.text.trim();
              final success = await controller.updateNicknames(
                yourNickname: isYours ? nickname : null,
                partnerNickname: !isYours ? nickname : null,
              );

              if (context.mounted) {
                Navigator.pop(context);
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Nickname updated!'),
                      duration: Duration(seconds: 2),
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
}
