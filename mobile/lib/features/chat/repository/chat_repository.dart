import '../../../core/models/api_response.dart';
import '../../../core/services/api_client.dart';
import '../models/chat_models.dart';
import '../models/conversation_settings_models.dart';

class ChatRepository {
  final ApiClient _apiClient = ApiClient();

  // Get partner conversation (only one conversation for couple app)
  Future<ApiResponse<Conversation>> getPartnerConversation() async {
    // Mock data - thay bằng API thực khi có
    await Future.delayed(const Duration(milliseconds: 500));

    final mockConversation = Conversation(
      id: '1',
      partnerId: 'partner_1',
      partnerName: 'My Love ❤️',
      partnerAvatar: null,
      lastMessage: Message(
        id: 'm1',
        conversationId: '1',
        senderId: 'partner_1',
        senderName: 'My Love',
        content: 'I miss you so much! 💕',
        type: MessageType.text,
        timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
        isRead: false,
      ),
      unreadCount: 3,
      isOnline: true,
    );

    return ApiResponse.success(data: mockConversation);
  }

  // Get messages in a conversation
  Future<ApiResponse<List<Message>>> getMessages(String conversationId) async {
    // Mock data
    await Future.delayed(const Duration(milliseconds: 500));

    final mockMessages = [
      Message(
        id: 'm1',
        conversationId: conversationId,
        senderId: 'user_1',
        senderName: 'You',
        content: 'Hey baby! How was your day?',
        type: MessageType.text,
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        isRead: true,
      ),
      Message(
        id: 'm2',
        conversationId: conversationId,
        senderId: 'partner_1',
        senderName: 'My Love',
        content: 'It was great! I kept thinking about you 💕',
        type: MessageType.text,
        timestamp: DateTime.now().subtract(
          const Duration(hours: 1, minutes: 55),
        ),
        isRead: true,
      ),
      Message(
        id: 'm3',
        conversationId: conversationId,
        senderId: 'user_1',
        senderName: 'You',
        content: 'Aww that\'s so sweet! Can\'t wait to see you tonight',
        type: MessageType.text,
        timestamp: DateTime.now().subtract(
          const Duration(hours: 1, minutes: 50),
        ),
        isRead: true,
      ),
      Message(
        id: 'm4',
        conversationId: conversationId,
        senderId: 'partner_1',
        senderName: 'My Love',
        content: 'Me too! What should we do for dinner?',
        type: MessageType.text,
        timestamp: DateTime.now().subtract(
          const Duration(hours: 1, minutes: 45),
        ),
        isRead: true,
      ),
      Message(
        id: 'm5',
        conversationId: conversationId,
        senderId: 'user_1',
        senderName: 'You',
        content: 'How about that new Italian restaurant? 🍝',
        type: MessageType.text,
        timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
        isRead: true,
      ),
      Message(
        id: 'm6',
        conversationId: conversationId,
        senderId: 'partner_1',
        senderName: 'My Love',
        content: 'Perfect! I love you so much! ❤️',
        type: MessageType.text,
        timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
        isRead: false,
      ),
    ];

    return ApiResponse.success(data: mockMessages);
  }

  // Send message
  Future<ApiResponse<Message>> sendMessage({
    required String conversationId,
    required String content,
    required MessageType type,
  }) async {
    // Mock sending
    await Future.delayed(const Duration(milliseconds: 300));

    final newMessage = Message(
      id: 'm_${DateTime.now().millisecondsSinceEpoch}',
      conversationId: conversationId,
      senderId: 'user_1', // Current user ID
      senderName: 'You',
      content: content,
      type: type,
      timestamp: DateTime.now(),
      isRead: false,
    );

    return ApiResponse.success(data: newMessage);
  }

  // Mark messages as read
  Future<ApiResponse<bool>> markAsRead(String conversationId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return ApiResponse.success(data: true);
  }

  // ==================== CONVERSATION SETTINGS ====================

  // Get conversation settings
  Future<ApiResponse<ConversationSettings>> getConversationSettings(
    String conversationId,
  ) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final mockSettings = ConversationSettings(
      conversationId: conversationId,
      bubbleColor: '#0084FF',
      quickEmoji: '❤️',
      yourNickname: null,
      partnerNickname: null,
    );

    return ApiResponse.success(data: mockSettings);
  }

  // Update conversation settings
  Future<ApiResponse<ConversationSettings>> updateConversationSettings(
    String conversationId,
    ConversationSettings settings,
  ) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return ApiResponse.success(data: settings);
  }

  // Get media items (images/videos)
  Future<ApiResponse<List<MediaItem>>> getMediaItems(
    String conversationId,
  ) async {
    await Future.delayed(const Duration(milliseconds: 500));

    // Mock media items
    final mockMedia = <MediaItem>[
      MediaItem(
        id: 'media_1',
        url: 'https://picsum.photos/400/300?random=1',
        type: MediaType.image,
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
      ),
      MediaItem(
        id: 'media_2',
        url: 'https://picsum.photos/400/300?random=2',
        type: MediaType.image,
        timestamp: DateTime.now().subtract(const Duration(days: 2)),
      ),
      MediaItem(
        id: 'media_3',
        url: 'https://picsum.photos/400/300?random=3',
        type: MediaType.image,
        timestamp: DateTime.now().subtract(const Duration(days: 3)),
      ),
    ];

    return ApiResponse.success(data: mockMedia);
  }

  // React to message
  Future<ApiResponse<bool>> reactToMessage(
    String messageId,
    String emoji,
  ) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return ApiResponse.success(data: true);
  }
}
