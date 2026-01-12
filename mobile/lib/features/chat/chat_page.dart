import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'chat_controller.dart';
import 'widgets/chat_app_bar.dart';
import 'widgets/message_bubble.dart';
import 'widgets/chat_input.dart';
import '../../core/utils/responsive_helper.dart';
import '../../core/constants/app_dimensions.dart';
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
      final controller = context.read<ChatController>();
      if (controller.conversation == null) {
        controller.initializeConversation().then((_) {
          if (controller.conversation != null) {
            controller.fetchMessages().then((_) {
              // Scroll sau khi load xong messages
              if (controller.messages.isNotEmpty) {
                _scrollToBottom();
              }
            });
          }
        });
      } else {
        controller.fetchMessages().then((_) {
          if (controller.messages.isNotEmpty) {
            _scrollToBottom();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (!mounted || !_scrollController.hasClients) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) return;

      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> _handleSendMessage(String content) async {
    final controller = context.read<ChatController>();
    final success = await controller.sendMessage(content);

    if (success) {
      _scrollToBottom();
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(controller.errorMessage ?? 'Failed to send message'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _handleRefresh() async {
    await context.read<ChatController>().refreshMessages();
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<ChatController>();

    // Loading initial conversation
    if (controller.isLoading && controller.conversation == null) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 1,
          title: const Text('Chat'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0084FF)),
          ),
        ),
      );
    }

    // Error loading conversation
    if (controller.conversation == null) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 1,
          title: const Text('Chat'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: context.space(AppDimensions.iconXL),
                color: Colors.red,
              ),
              ResponsiveHelper.verticalSpace(context, AppDimensions.spaceM),
              Text(
                controller.errorMessage ?? 'Failed to load conversation',
                style: TextStyle(
                  fontSize: context.sp(AppDimensions.fontM),
                  color: Colors.grey[600],
                ),
              ),
              ResponsiveHelper.verticalSpace(context, AppDimensions.spaceL),
              ElevatedButton(
                onPressed: () {
                  controller.initializeConversation().then((_) {
                    if (controller.conversation != null) {
                      controller.fetchMessages();
                    }
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0084FF),
                ),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    // Get background theme
    final backgroundTheme =
        controller.settings?.backgroundTheme ?? BackgroundTheme.defaultTheme;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: ChatAppBar(conversation: controller.conversation!),
      body: Container(
        decoration: backgroundTheme.decoration,
        child: Column(
          children: [
            Expanded(child: _buildMessageList(context, controller)),
            ChatInput(
              onSend: _handleSendMessage,
              isSending: controller.isSending,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageList(BuildContext context, ChatController controller) {
    if (controller.isLoading && controller.messages.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0084FF)),
        ),
      );
    }

    if (controller.errorMessage != null && controller.messages.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: context.space(AppDimensions.iconXL),
              color: Colors.red,
            ),
            ResponsiveHelper.verticalSpace(context, AppDimensions.spaceM),
            Text(
              controller.errorMessage!,
              style: TextStyle(
                fontSize: context.sp(AppDimensions.fontM),
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            ResponsiveHelper.verticalSpace(context, AppDimensions.spaceL),
            ElevatedButton(
              onPressed: () => controller.fetchMessages(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0084FF),
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (controller.messages.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: context.space(AppDimensions.iconXL),
              color: Colors.grey[400],
            ),
            ResponsiveHelper.verticalSpace(context, AppDimensions.spaceM),
            Text(
              'No messages yet',
              style: TextStyle(
                fontSize: context.sp(AppDimensions.fontL),
                color: Colors.grey[600],
                fontWeight: FontWeight.w600,
              ),
            ),
            ResponsiveHelper.verticalSpace(context, AppDimensions.spaceS),
            Text(
              'Say hi to your partner! 💕',
              style: TextStyle(
                fontSize: context.sp(AppDimensions.fontS),
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    // Scroll to bottom when messages load
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   if (controller.messages.isNotEmpty) {
    //     _scrollToBottom();
    //   }
    // });

    return RefreshIndicator(
      onRefresh: _handleRefresh,
      color: const Color(0xFF0084FF),
      child: ListView.builder(
        controller: _scrollController,
        padding: EdgeInsets.symmetric(
          vertical: context.space(AppDimensions.spaceM),
        ),
        itemCount: controller.messages.length,
        itemBuilder: (context, index) {
          final message = controller.messages[index];

          // Lấy currentUserId từ controller
          final myId = controller.currentUserId;

          final isMe =
              controller.currentUserId != null &&
              message.senderId.toString() ==
                  controller.currentUserId.toString();

          final showDateSeparator =
              index == 0 ||
              !_isSameDay(
                controller.messages[index - 1].timestamp,
                message.timestamp,
              );

          return Column(
            children: [
              if (showDateSeparator)
                _buildDateSeparator(context, message.timestamp),
              MessageBubble(message: message, isMe: isMe),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDateSeparator(BuildContext context, DateTime date) {
    String label;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(date.year, date.month, date.day);

    if (messageDate == today) {
      label = 'Today';
    } else if (messageDate == today.subtract(const Duration(days: 1))) {
      label = 'Yesterday';
    } else {
      label = '${date.day}/${date.month}/${date.year}';
    }

    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: context.space(AppDimensions.spaceM),
      ),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: context.space(12),
          vertical: context.space(6),
        ),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.4),
          borderRadius: BorderRadius.circular(context.space(12)),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: context.sp(AppDimensions.fontXXS),
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }
}
