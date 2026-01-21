import '../../../core/config/api_config.dart';
import '../../../core/models/api_response.dart';
import '../../../core/services/api_client.dart';
import '../../../core/services/storage_service.dart';
import '../models/memory_models.dart';

class MemoryRepository {
  final ApiClient _apiClient = ApiClient();
  final StorageService _storageService = StorageService();

  // Get all memories
  Future<ApiResponse<List<Memory>>> getMemories() async {
    try {
      final token = await _storageService.getToken();
      if (token == null) {
        return ApiResponse.error(message: 'Authentication required');
      }

      final response = await _apiClient.get<List<Memory>>(
        ApiConfig.getMemories,
        token: token,
        fromJsonT: (json) {
          if (json is List) {
            return json.map((item) => Memory.fromJson(item)).toList();
          }
          return [];
        },
      );

      return response;
    } catch (e) {
      return ApiResponse.error(
        message: 'Failed to load memories: ${e.toString()}',
      );
    }
  }

  // Create memory
  Future<ApiResponse<Memory>> createMemory(CreateMemoryRequest request) async {
    try {
      final token = await _storageService.getToken();
      if (token == null) {
        return ApiResponse.error(message: 'Authentication required');
      }

      final response = await _apiClient.post<Memory>(
        ApiConfig.createMemory,
        data: request.toJson(),
        token: token,
        fromJsonT: (json) => Memory.fromJson(json),
      );

      return response;
    } catch (e) {
      return ApiResponse.error(
        message: 'Failed to create memory: ${e.toString()}',
      );
    }
  }

  // Update memory
  Future<ApiResponse<Memory>> updateMemory(
    int memoryId,
    UpdateMemoryRequest request,
  ) async {
    try {
      final token = await _storageService.getToken();
      if (token == null) {
        return ApiResponse.error(message: 'Authentication required');
      }

      final response = await _apiClient.patch<Memory>(
        ApiConfig.updateMemory(memoryId),
        data: request.toJson(),
        token: token,
        fromJsonT: (json) => Memory.fromJson(json),
      );

      return response;
    } catch (e) {
      return ApiResponse.error(
        message: 'Failed to update memory: ${e.toString()}',
      );
    }
  }

  // Delete memory
  Future<ApiResponse<void>> deleteMemory(int memoryId) async {
    try {
      final token = await _storageService.getToken();
      if (token == null) {
        return ApiResponse.error(message: 'Authentication required');
      }

      final response = await _apiClient.delete(
        ApiConfig.deleteMemory(memoryId),
        token: token,
      );

      return response;
    } catch (e) {
      return ApiResponse.error(
        message: 'Failed to delete memory: ${e.toString()}',
      );
    }
  }

  // Get today's anniversary memories
  Future<ApiResponse<List<Memory>>> getTodayMemories() async {
    try {
      final token = await _storageService.getToken();
      if (token == null) {
        return ApiResponse.error(message: 'Authentication required');
      }

      final response = await _apiClient.get<List<Memory>>(
        ApiConfig.todayMemories,
        token: token,
        fromJsonT: (json) {
          if (json is List) {
            return json.map((item) => Memory.fromJson(item)).toList();
          }
          return [];
        },
      );

      return response;
    } catch (e) {
      return ApiResponse.error(
        message: 'Failed to load today memories: ${e.toString()}',
      );
    }
  }
}
