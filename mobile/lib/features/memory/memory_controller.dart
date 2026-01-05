import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'dart:io';
import 'models/memory_models.dart';
import 'repository/memory_repository.dart';

class MemoryController extends ChangeNotifier {
  final MemoryRepository _repository = MemoryRepository();
  final ImagePicker _picker = ImagePicker();

  List<Memory> _memories = [];
  bool _isLoading = false;
  String? _errorMessage;
  File? _selectedImage;

  List<Memory> get memories => _memories;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  File? get selectedImage => _selectedImage;

  // For edit mode
  Memory? _editingMemory;
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

  // Load memories
  Future<void> loadMemories() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _repository.getMemories();
      if (response.success && response.data != null) {
        _memories = response.data!;
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
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        _selectedImage = File(image.path);
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
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        _selectedImage = File(image.path);
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Failed to select image';
      notifyListeners();
    }
  }

  // Create memory
  Future<bool> createMemory({
    required String title,
    required String description,
    List<String>? tags,
  }) async {
    if (_selectedImage == null) {
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
      // Convert image to base64
      final bytes = await _selectedImage!.readAsBytes();
      final base64Image = base64Encode(bytes);

      final request = CreateMemoryRequest(
        title: title,
        description: description,
        imageBase64: base64Image,
      );

      final response = await _repository.createMemory(request);

      if (response.success && response.data != null) {
        // Reload memories instead of inserting to avoid duplicates
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

  // Delete memory
  Future<bool> deleteMemory(String memoryId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _repository.deleteMemory(memoryId);
      if (response.success) {
        // Reload memories instead of removing locally
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
      final response = await _repository.getTodayMemories();
      if (response.success && response.data != null) {
        return response.data!;
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // Update memory
  Future<bool> updateMemory({
    required String memoryId,
    required String title,
    required String description,
    String? imageBase64,
    List<String>? tags,
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
      final response = await _repository.updateMemory(
        memoryId: memoryId,
        title: title,
        description: description,
        imageBase64: imageBase64,
        tags: tags,
      );

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
}
