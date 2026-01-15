import '../../../core/config/api_config.dart';
import '../../../core/models/api_response.dart';
import '../../../core/services/api_client.dart';
import '../../../core/services/storage_service.dart';
import '../models/chat_models.dart';
import '../models/conversation_settings_models.dart';

class ConversationRepository {
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

  // Get conversation settings
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

  // Update conversation settings
  Future<ApiResponse<ConversationSettings>> updateConversationSettings(
    int coupleId,
    ConversationSettings settings,
  ) async {
    try {
      final token = await _storageService.getToken();
      if (token == null) {
        return ApiResponse.error(message: 'No authentication token found');
      }

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
}
