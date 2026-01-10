import '../../../core/config/api_config.dart';
import '../../../core/models/api_response.dart';
import '../../../core/services/api_client.dart';
import '../../../core/services/storage_service.dart';
import '../models/chat_models.dart';
import '../models/conversation_settings_models.dart';

class ChatRepository {
  final ApiClient _apiClient = ApiClient();
  final StorageService _storageService = StorageService();

  // Get couple stats (conversation info)
  Future<ApiResponse<Conversation>> getPartnerConversation() async {
    try {
      final token = await _storageService.getToken();
      if (token == null) {
        return ApiResponse.error(message: 'No authentication token found');
      }

      final response = await _apiClient.get<Conversation>(
        ApiConfig.coupleStats,
        token: token,
        fromJsonT: (json) => Conversation.fromJson(json),
      );
      return response;
    } catch (e) {
      return ApiResponse.error(
        message: 'Failed to load conversation: ${e.toString()}',
      );
    }
  }

  // Get messages history
  Future<ApiResponse<List<Message>>> getMessages(int coupleId) async {
    try {
      final token = await _storageService.getToken();
      if (token == null) {
        return ApiResponse.error(message: 'No authentication token found');
      }

      final response = await _apiClient.get<List<Message>>(
        '${ApiConfig.getMessages}/$coupleId',
        token: token,
        fromJsonT: (json) {
          if (json is List) {
            return json.map((item) => Message.fromJson(item)).toList();
          }
          return [];
        },
      );
      return response;
    } catch (e) {
      return ApiResponse.error(
        message: 'Failed to load messages: ${e.toString()}',
      );
    }
  }

  // Mark messages as read (giữ lại để tương lai)
  Future<ApiResponse<bool>> markAsRead(int coupleId) async {
    // Chưa có API, trả về success
    await Future.delayed(const Duration(milliseconds: 100));
    return ApiResponse.success(data: true);
  }

  // ==================== CONVERSATION SETTINGS ====================

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

  Future<ApiResponse<ConversationSettings>> updateConversationSettings(
    String conversationId,
    ConversationSettings settings,
  ) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return ApiResponse.success(data: settings);
  }

  Future<ApiResponse<List<MediaItem>>> getMediaItems(
    String conversationId,
  ) async {
    await Future.delayed(const Duration(milliseconds: 500));

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

  Future<ApiResponse<bool>> reactToMessage(int messageId, String emoji) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return ApiResponse.success(data: true);
  }
}
