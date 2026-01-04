import '../../../core/models/api_response.dart';
import '../../../core/services/api_client.dart';
import '../../../core/services/storage_service.dart';
import '../models/memory_models.dart';

class MemoryRepository {
  final ApiClient _apiClient = ApiClient();
  final StorageService _storageService = StorageService();

  // Mock data for testing
  final List<Memory> _mockMemories = [
    Memory(
      id: '1',
      userId: '1',
      title: 'First Date',
      description:
          'Coffee at that cute little café downtown. You made me laugh so much!',
      imageUrl:
          'https://images.unsplash.com/photo-1511920170033-f8396924c348?w=800',
      createdAt: DateTime(2024, 1, 15),
      tags: ['date', 'coffee'],
    ),
    Memory(
      id: '2',
      userId: '1',
      title: 'Our First Trip',
      description: 'Weekend getaway to the mountains. Best decision ever.',
      imageUrl:
          'https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?w=800',
      createdAt: DateTime(2024, 3, 22),
      tags: ['travel', 'mountains'],
    ),
  ];

  // Get all memories
  Future<ApiResponse<List<Memory>>> getMemories() async {
    // Mock response
    await Future.delayed(const Duration(milliseconds: 800));
    return ApiResponse.success(data: _mockMemories);

    // Real API call (uncomment when ready)
    /*
    final token = await _storageService.getToken();
    return await _apiClient.get<List<Memory>>(
      '/memories',
      token: token,
      fromJsonT: (json) => (json as List)
          .map((item) => Memory.fromJson(item))
          .toList(),
    );
    */
  }

  // Create memory
  Future<ApiResponse<Memory>> createMemory(CreateMemoryRequest request) async {
    // Mock response
    await Future.delayed(const Duration(milliseconds: 1000));

    final newMemory = Memory(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: '1',
      title: request.title,
      description: request.description,
      imageUrl:
          'https://images.unsplash.com/photo-1502086223501-7ea6ecd79368?w=800',
      createdAt: DateTime.now(),
      tags: request.tags,
    );

    _mockMemories.insert(0, newMemory);
    return ApiResponse.success(
      message: 'Memory created successfully',
      data: newMemory,
    );

    // Real API call (uncomment when ready)
    /*
    final token = await _storageService.getToken();
    return await _apiClient.post<Memory>(
      '/memories',
      data: request.toJson(),
      token: token,
      fromJsonT: (json) => Memory.fromJson(json),
    );
    */
  }

  // Delete memory
  Future<ApiResponse<void>> deleteMemory(String memoryId) async {
    // Mock response
    await Future.delayed(const Duration(milliseconds: 500));
    _mockMemories.removeWhere((m) => m.id == memoryId);
    return ApiResponse.success(message: 'Memory deleted successfully');

    // Real API call (uncomment when ready)
    /*
    final token = await _storageService.getToken();
    return await _apiClient.delete(
      '/memories/$memoryId',
      token: token,
    );
    */
  }

  // Get memories for today (anniversary reminders)
  Future<ApiResponse<List<Memory>>> getTodayMemories() async {
    await Future.delayed(const Duration(milliseconds: 500));

    final now = DateTime.now();
    final todayMemories = _mockMemories.where((memory) {
      return memory.createdAt.month == now.month &&
          memory.createdAt.day == now.day;
    }).toList();

    return ApiResponse.success(data: todayMemories);
  }

  // Update memory
  Future<ApiResponse<Memory>> updateMemory({
    required String memoryId,
    required String title,
    required String description,
    String? imageBase64,
    List<String>? tags,
  }) async {
    // Mock response
    await Future.delayed(const Duration(milliseconds: 1000));

    final index = _mockMemories.indexWhere((m) => m.id == memoryId);
    if (index != -1) {
      final updatedMemory = Memory(
        id: memoryId,
        userId: _mockMemories[index].userId,
        title: title,
        description: description,
        imageUrl: imageBase64 != null
            ? 'https://images.unsplash.com/photo-1502086223501-7ea6ecd79368?w=800'
            : _mockMemories[index].imageUrl,
        createdAt: _mockMemories[index].createdAt,
        tags: tags,
      );

      _mockMemories[index] = updatedMemory;
      return ApiResponse.success(
        message: 'Memory updated successfully',
        data: updatedMemory,
      );
    }

    return ApiResponse.error(message: 'Memory not found');

    // Real API call (uncomment when ready)
    /*
    final token = await _storageService.getToken();
    return await _apiClient.put<Memory>(
      '/memories/$memoryId',
      data: {
        'title': title,
        'description': description,
        if (imageBase64 != null) 'image_base64': imageBase64,
        if (tags != null) 'tags': tags,
      },
      token: token,
      fromJsonT: (json) => Memory.fromJson(json),
    );
    */
  }
}
