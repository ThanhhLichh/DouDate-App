import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/chat_controller.dart';
import '../controllers/conversation_controller.dart';
import '../widgets/chat/chat_app_bar.dart';
import '../widgets/chat/chat_input.dart';
import '../widgets/chat/message_list.dart';
import '../widgets/chat/chat_state_views.dart';
import '../models/conversation_settings_models.dart';
import '../../../core/services/fcm_service.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> with WidgetsBindingObserver {
  final ScrollController _scrollController = ScrollController();
  ChatController? _controller;
  FCMService? _fcmService;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Get FCM service và notify visibility
    _fcmService = context.read<FCMService>();
    _fcmService?.setChatPageVisibility(true);
    debugPrint('Chat page opened - FCM notified');

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final chatController = context.read<ChatController>();
      final conversationController = context.read<ConversationController>();

      _controller = chatController;

      if (conversationController.conversation == null) {
        chatController.initialize().then((_) {
          if (conversationController.conversation != null) {
            chatController.fetchMessages();
          }
        });
      } else {
        chatController.fetchMessages();
      }

      chatController.onScreenVisible();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (_controller != null) {
      if (state == AppLifecycleState.resumed) {
        _controller!.onScreenVisible();
        // Notify FCM when app resumes
        _fcmService?.setChatPageVisibility(true);
        debugPrint('App resumed on chat page - FCM notified');
      } else if (state == AppLifecycleState.paused ||
          state == AppLifecycleState.inactive) {
        _controller!.onScreenHidden();
        // Notify FCM when app goes background
        _fcmService?.setChatPageVisibility(false);
        debugPrint('App paused/inactive - FCM notified');
      }
    }
  }

  @override
  void dispose() {
    debugPrint('ChatPage: DISPOSING');
    WidgetsBinding.instance.removeObserver(this);
    _scrollController.dispose();

    // Notify FCM chat page hidden
    _fcmService?.setChatPageVisibility(false);
    debugPrint('Chat page closed - FCM notified');

    if (_controller != null) {
      debugPrint('ChatPage: Calling onScreenHidden');
      _controller!.onScreenHidden();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // CHỈ watch những field cần thiết cho initial loading
    final isConversationLoading = context.select<ConversationController, bool>(
      (c) => c.isLoading && c.conversation == null,
    );

    final conversation = context.select<ConversationController, dynamic>(
      (c) => c.conversation,
    );

    final conversationError = context.select<ConversationController, String?>(
      (c) => c.conversation == null ? c.errorMessage : null,
    );

    // 1. Initial Loading
    if (isConversationLoading) {
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
    if (conversation == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Chat')),
        body: ChatErrorView(
          message: conversationError ?? 'Failed to load conversation',
          onRetry: () {
            final chatController = context.read<ChatController>();
            final conversationController = context
                .read<ConversationController>();
            chatController.initialize().then((_) {
              if (conversationController.conversation != null) {
                chatController.fetchMessages();
              }
            });
          },
        ),
      );
    }

    // 3. Main Chat UI với background theme selector
    return Selector<ConversationController, BackgroundTheme>(
      selector: (_, controller) =>
          controller.settings?.backgroundTheme ?? BackgroundTheme.defaultTheme,
      builder: (context, backgroundTheme, child) {
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: ChatAppBar(conversation: conversation),
          body: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: Container(
              decoration: backgroundTheme.decoration,
              child: Column(
                children: [
                  Expanded(
                    child: _ChatBody(scrollController: _scrollController),
                  ),
                  const _ChatInputWrapper(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// Tách riêng body để tránh rebuild không cần thiết
class _ChatBody extends StatelessWidget {
  final ScrollController scrollController;

  const _ChatBody({required this.scrollController});

  @override
  Widget build(BuildContext context) {
    final messageCount = context.select<ChatController, int>(
      (c) => c.messages.length,
    );

    final isLoading = context.select<ChatController, bool>(
      (c) => c.isLoading && c.messages.isEmpty,
    );
    final errorMessage = context.select<ChatController, String?>(
      (c) => c.messages.isEmpty ? c.errorMessage : null,
    );

    final hasMessages = messageCount > 0;

    if (isLoading) {
      return const ChatLoadingView();
    }

    if (errorMessage != null) {
      return ChatErrorView(
        message: errorMessage,
        onRetry: () => context.read<ChatController>().fetchMessages(),
      );
    }

    if (!hasMessages) {
      return const ChatEmptyView();
    }

    return MessageList(
      controller: context.read<ChatController>(),
      scrollController: scrollController,
      onRefresh: () => context.read<ChatController>().refreshMessages(),
    );
  }
}

// Tách riêng input để chỉ rebuild khi isSending thay đổi
class _ChatInputWrapper extends StatelessWidget {
  const _ChatInputWrapper();

  @override
  Widget build(BuildContext context) {
    final isSending = context.select<ChatController, bool>((c) => c.isSending);

    return ChatInput(
      onSend: (content) {
        final controller = context.read<ChatController>();
        controller.sendMessage(content).then((success) {
          if (!success && context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  controller.errorMessage ?? 'Failed to send message',
                ),
                backgroundColor: Colors.red,
              ),
            );
          }
        });
      },
      isSending: isSending,
    );
  }
}
