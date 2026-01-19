import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/chat_controller.dart';
import '../controllers/conversation_controller.dart';
import '../widgets/conversation/media_gallery_page.dart';
import '../widgets/conversation/partner_header.dart';
import '../widgets/conversation/nicknames_section.dart';
import '../widgets/conversation/background_theme_section.dart';
import '../widgets/conversation/bubble_color_section.dart';
import '../widgets/conversation/quick_emoji_section.dart';
import '../widgets/conversation/setting_item_title.dart';

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
      context.read<ConversationController>().loadSettings();
    });
  }

  @override
  Widget build(BuildContext context) {
    final conversationController = context.watch<ConversationController>();
    final conversation = conversationController.conversation;
    final settings = conversationController.settings;

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
          PartnerHeader(
            controller: conversationController,
            conversation: conversation,
            settings: settings,
          ),
          const SizedBox(height: 16),
          NicknamesSection(
            controller: conversationController,
            settings: settings,
          ),
          const SizedBox(height: 16),
          BackgroundThemeSection(
            controller: conversationController,
            settings: settings,
          ),
          const SizedBox(height: 16),
          BubbleColorSection(
            controller: conversationController,
            settings: settings,
          ),
          const SizedBox(height: 16),
          QuickEmojiSection(
            controller: conversationController,
            settings: settings,
          ),
          const SizedBox(height: 16),
          _MediaGalleryTile(),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _MediaGalleryTile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Selector<ChatController, int>(
      selector: (_, controller) => controller.mediaItems.length,
      builder: (context, mediaCount, _) {
        return Container(
          color: Colors.white,
          child: SettingItemTile(
            icon: Icons.photo_library,
            title: 'Shared Photos & Videos',
            subtitle: '$mediaCount items',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const MediaGalleryPage()),
            ),
          ),
        );
      },
    );
  }
}
