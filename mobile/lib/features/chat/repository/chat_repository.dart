import '../../../core/config/api_config.dart';
import '../../../core/models/api_response.dart';
import '../../../core/services/api_client.dart';
import '../../../core/services/storage_service.dart';
import '../models/chat_models.dart';

class ChatRepository {
  final ApiClient _apiClient = ApiClient();
  final StorageService _storageService = StorageService();

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

  // Mark messages as read
  Future<ApiResponse<bool>> markMessagesAsRead({
    required int coupleId,
    required int lastMessageId,
  }) async {
    try {
      final token = await _storageService.getToken();
      if (token == null) {
        return ApiResponse.error(message: 'No authentication token found');
      }

      final response = await _apiClient.post<Map<String, dynamic>>(
        ApiConfig.checkReadStatus,
        token: token,
        data: {'couple_id': coupleId, 'last_message_id': lastMessageId},
      );

      return ApiResponse.success(data: response.success);
    } catch (e) {
      return ApiResponse.error(
        message: 'Failed to mark messages as read: ${e.toString()}',
      );
    }
  }

  // React to message
  Future<ApiResponse<Map<String, dynamic>>> reactToMessage(
    int messageId,
    String? emoji,
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
