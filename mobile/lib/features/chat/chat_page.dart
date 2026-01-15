import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'controllers/chat_controller.dart';
import 'controllers/conversation_controller.dart';
import 'widgets/chat/chat_app_bar.dart';
import 'widgets/chat/chat_input.dart';
import 'widgets/chat/message_list.dart';
import 'widgets/chat/chat_state_views.dart';
import 'models/conversation_settings_models.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final chatController = context.read<ChatController>();
      final conversationController = context.read<ConversationController>();

      if (conversationController.conversation == null) {
        chatController.initialize().then((_) {
          if (conversationController.conversation != null) {
            chatController.fetchMessages();
          }
        });
      } else {
        chatController.fetchMessages();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _handleSendMessage(String content) async {
    final controller = context.read<ChatController>();
    final success = await controller.sendMessage(content);

    if (success) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(controller.errorMessage ?? 'Failed to send message'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final chatController = context.watch<ChatController>();
    final conversationController = context.watch<ConversationController>();

    // 1. Initial Loading
    if (conversationController.isLoading &&
        conversationController.conversation == null) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: AppBar(title: const Text('Chat')),
        ),
        body: const ChatLoadingView(),
      );
    }

    // 2. Conversation Error
    if (conversationController.conversation == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Chat')),
        body: ChatErrorView(
          message:
              conversationController.errorMessage ??
              'Failed to load conversation',
          onRetry: () => chatController.initialize().then((_) {
            if (conversationController.conversation != null) {
              chatController.fetchMessages();
            }
          }),
        ),
      );
    }

    final backgroundTheme =
        conversationController.settings?.backgroundTheme ??
        BackgroundTheme.defaultTheme;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: ChatAppBar(conversation: conversationController.conversation!),
      body: Container(
        decoration: backgroundTheme.decoration,
        child: Column(
          children: [
            Expanded(child: _buildBodyContent(chatController)),
            ChatInput(
              onSend: _handleSendMessage,
              isSending: chatController.isSending,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBodyContent(ChatController controller) {
    if (controller.isLoading && controller.messages.isEmpty) {
      return const ChatLoadingView();
    }
    if (controller.errorMessage != null && controller.messages.isEmpty) {
      return ChatErrorView(
        message: controller.errorMessage!,
        onRetry: () => controller.fetchMessages(),
      );
    }
    if (controller.messages.isEmpty) return const ChatEmptyView();

    return MessageList(
      controller: controller,
      scrollController: _scrollController,
      onRefresh: () => controller.refreshMessages(),
    );
  }
}
