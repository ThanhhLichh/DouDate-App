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
    int coupleId,
  ) async {
    try {
      final token = await _storageService.getToken();
      if (token == null) {
        return ApiResponse.error(message: 'No authentication token found');
      }

      final response = await _apiClient.get<ConversationSettings>(
        ApiConfig.getChatSettings(coupleId),
        token: token,
        fromJsonT: (json) => ConversationSettings.fromJson(json),
      );

      return response;
    } catch (e) {
      return ApiResponse.error(
        message: 'Failed to load settings: ${e.toString()}',
      );
    }
  }

  Future<ApiResponse<ConversationSettings>> updateConversationSettings(
    int coupleId,
    ConversationSettings settings,
  ) async {
    try {
      final token = await _storageService.getToken();
      if (token == null) {
        return ApiResponse.error(message: 'No authentication token found');
      }

      // Prepare request body (exclude couple_id from body, it's in URL)
      final requestBody = {
        'bubble_color': settings.bubbleColor,
        'quick_emoji': settings.quickEmoji,
        'background_theme': settings.backgroundTheme.name,
        'your_nickname': settings.yourNickname,
        'partner_nickname': settings.partnerNickname,
      };

      final response = await _apiClient.put<Map<String, dynamic>>(
        ApiConfig.updateChatSettings(coupleId),
        token: token,
        data: requestBody,
      );

      if (response.success) {
        // Since PUT returns just a success message, return the settings we sent
        // (they're already validated by backend if success=true)
        return ApiResponse.success(
          message: 'Settings updated successfully',
          data: settings,
        );
      } else {
        return ApiResponse.error(
          message: response.message ?? 'Failed to update settings',
        );
      }
    } catch (e) {
      return ApiResponse.error(
        message: 'Failed to update settings: ${e.toString()}',
      );
    }
  }

  Future<ApiResponse<List<MediaItem>>> getMediaItems(int conversationId) async {
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

  Future<ApiResponse<Map<String, dynamic>>> reactToMessage(
    int messageId,
    String? emoji, // null = remove
  ) async {
    try {
      final token = await _storageService.getToken();
      if (token == null) {
        return ApiResponse.error(message: 'No authentication token found');
      }

      final request = ReactionRequest(emoji: emoji);

      final response = await _apiClient.post<Map<String, dynamic>>(
        ApiConfig.reactToMessage(messageId),
        token: token,
        data: request.toJson(),
        fromJsonT: (json) => json as Map<String, dynamic>,
      );

      return response;
    } catch (e) {
      return ApiResponse.error(
        message: 'Failed to react to message: ${e.toString()}',
      );
    }
  }
}
