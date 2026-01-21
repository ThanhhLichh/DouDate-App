import 'package:flutter/material.dart';
import 'dart:io';
import '../models/memory_models.dart';
import '../repository/memory_repository.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/services/image_upload_service.dart';

class MemoryController extends ChangeNotifier {
  final MemoryRepository _repository = MemoryRepository();
  final StorageService _storageService = StorageService();
  final ImageUploadService _imageUploadService = ImageUploadService();

  List<Memory> _memories = [];
  bool _isLoading = false;
  String? _errorMessage;
  File? _selectedImage;

  // For edit mode
  Memory? _editingMemory;

  // For anniversary reminder - track if shown today
  String? _lastShownDate;

  List<Memory> get memories => _memories;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  File? get selectedImage => _selectedImage;
  Memory? get editingMemory => _editingMemory;

  void setEditingMemory(Memory? memory) {
    _editingMemory = memory;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void clearSelectedImage() {
    _selectedImage = null;
    notifyListeners();
  }

  void setSelectedImage(File? image) {
    _selectedImage = image;
    notifyListeners();
  }

  // Load memories
  Future<void> loadMemories() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _repository.getMemories();
      if (response.success && response.data != null) {
        _memories = response.data!;
        // Sort by memory date descending (newest first)
        _memories.sort((a, b) => b.memoryDate.compareTo(a.memoryDate));
      } else {
        _errorMessage = response.message ?? 'Failed to load memories';
      }
    } catch (e) {
      _errorMessage = 'An error occurred while loading memories';
    }

    _isLoading = false;
    notifyListeners();
  }

  // Pick image from camera
  Future<void> pickImageFromCamera() async {
    try {
      final coupleId = await _storageService.getUserId();
      if (coupleId == null) {
        _errorMessage = 'User not found';
        notifyListeners();
        return;
      }

      // Take photo and upload to Cloudinary
      final response = await _imageUploadService.takePhotoAndUploadChatImage(
        coupleId,
      );

      if (response != null && response.secureUrl.isNotEmpty) {
        // Create a temporary file to show preview
        // (we don't need the actual file since we have the URL)
        _selectedImage = null; // Clear previous selection
        notifyListeners();
      } else {
        _errorMessage = 'Failed to upload image';
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Failed to capture image';
      notifyListeners();
    }
  }

  // Pick image from gallery
  Future<void> pickImageFromGallery() async {
    try {
      final coupleId = await _storageService.getUserId();
      if (coupleId == null) {
        _errorMessage = 'User not found';
        notifyListeners();
        return;
      }

      // Pick and upload to Cloudinary
      final response = await _imageUploadService.pickAndUploadMemoryImage(
        coupleId,
      );

      if (response != null && response.secureUrl.isNotEmpty) {
        // Store the cloudinary URL temporarily
        _selectedImage = null; // Clear previous selection
        notifyListeners();
      } else {
        _errorMessage = 'Failed to upload image';
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Failed to select image';
      notifyListeners();
    }
  }

  // Upload image and return URL
  Future<String?> uploadImageToCloudinary(File imageFile) async {
    try {
      final coupleId = await _storageService.getUserId();
      if (coupleId == null) {
        _errorMessage = 'User not found';
        notifyListeners();
        return null;
      }

      final response = await _imageUploadService.pickAndUploadMemoryImage(
        coupleId,
      );

      if (response != null && response.secureUrl.isNotEmpty) {
        return response.secureUrl;
      }
      return null;
    } catch (e) {
      debugPrint('Upload error: $e');
      return null;
    }
  }

  // Create memory
  Future<bool> createMemory({
    required String title,
    required String description,
    required String imageUrl,
    DateTime? memoryDate,
  }) async {
    if (imageUrl.isEmpty) {
      _errorMessage = 'Please select an image';
      notifyListeners();
      return false;
    }

    if (title.isEmpty || description.isEmpty) {
      _errorMessage = 'Title and description are required';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final request = CreateMemoryRequest(
        title: title,
        description: description,
        imageUrl: imageUrl,
        memoryDate: memoryDate ?? DateTime.now(),
      );

      final response = await _repository.createMemory(request);

      if (response.success && response.data != null) {
        await loadMemories();
        _selectedImage = null;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.message ?? 'Failed to create memory';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'An error occurred while creating memory';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Update memory
  Future<bool> updateMemory({
    required int memoryId,
    required String title,
    required String description,
    String? imageUrl,
    DateTime? memoryDate,
  }) async {
    if (title.isEmpty || description.isEmpty) {
      _errorMessage = 'Title and description are required';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final request = UpdateMemoryRequest(
        title: title,
        description: description,
        imageUrl: imageUrl,
        memoryDate: memoryDate ?? _editingMemory?.memoryDate ?? DateTime.now(),
      );

      final response = await _repository.updateMemory(memoryId, request);

      if (response.success) {
        await loadMemories();
        _selectedImage = null;
        _editingMemory = null;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.message ?? 'Failed to update memory';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'An error occurred while updating memory';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Delete memory
  Future<bool> deleteMemory(int memoryId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _repository.deleteMemory(memoryId);
      if (response.success) {
        await loadMemories();
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.message ?? 'Failed to delete memory';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'An error occurred while deleting memory';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Get today's anniversary memories
  Future<List<Memory>> getTodayMemories() async {
    try {
      // Check if we've already shown the reminder today
      final today = DateTime.now().toIso8601String().split('T')[0];
      if (_lastShownDate == today) {
        return [];
      }

      final response = await _repository.getTodayMemories();
      if (response.success && response.data != null) {
        final todayMemories = response.data!;

        // Mark as shown for today
        if (todayMemories.isNotEmpty) {
          _lastShownDate = today;
        }

        return todayMemories;
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // Mark anniversary reminder as viewed for today
  void markAnniversaryViewed() {
    final today = DateTime.now().toIso8601String().split('T')[0];
    _lastShownDate = today;
    notifyListeners();
  }
}
