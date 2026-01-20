import 'package:flutter/material.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/services/image_upload_service.dart';
import '../../../core/models/cloudinary_models.dart';
import '../models/user_profile.dart';
import '../repository/settings_repository.dart';
import '../../../core/constants/app_constants.dart';

class SettingsController extends ChangeNotifier {
  final StorageService _storageService = StorageService();
  final SettingsRepository _repository = SettingsRepository();
  final ImageUploadService _uploadService = ImageUploadService();

  bool _isLoading = false;
  UserProfile? _userProfile;
  String? _errorMessage;
  bool _notificationsEnabled = true;

  bool get isLoading => _isLoading;
  UserProfile? get userProfile => _userProfile;
  String? get errorMessage => _errorMessage;
  bool get notificationsEnabled => _notificationsEnabled;

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Load User Profile
  Future<bool> loadUserProfile() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final token = await _storageService.getToken();
      if (token == null) {
        _errorMessage = ErrorMessages.notAuthenticated;
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final response = await _repository.getUserProfile(token);

      if (response.success && response.data != null) {
        _userProfile = response.data;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.message ?? 'Failed to load profile';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'An error occurred. Please try again.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Update Name
  Future<bool> updateName(String newName) async {
    if (newName.trim().isEmpty) {
      _errorMessage = ErrorMessages.nameCannotBeEmpty;
      notifyListeners();
      return false;
    }

    try {
      final token = await _storageService.getToken();
      if (token == null) return false;

      final response = await _repository.updateProfile(token, {
        'full_name': newName,
      });

      if (response.success && response.data != null) {
        _userProfile = response.data;
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.message ?? 'Failed to update name';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = ErrorMessages.unknownError;
      notifyListeners();
      return false;
    }
  }

  // Update Birthday
  Future<bool> updateBirthday(DateTime birthday) async {
    try {
      final token = await _storageService.getToken();
      if (token == null) return false;

      final response = await _repository.updateProfile(token, {
        'birth_date': birthday.toIso8601String().split(
          'T',
        )[0], // Format: YYYY-MM-DD
      });

      if (response.success && response.data != null) {
        _userProfile = response.data;
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.message ?? 'Failed to update birthday';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = ErrorMessages.unknownError;
      notifyListeners();
      return false;
    }
  }

  // Update Gender
  Future<bool> updateGender(String gender) async {
    try {
      final token = await _storageService.getToken();
      if (token == null) return false;

      final response = await _repository.updateProfile(token, {
        'gender': gender,
      });

      if (response.success && response.data != null) {
        _userProfile = response.data;
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.message ?? 'Failed to update gender';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = ErrorMessages.unknownError;
      notifyListeners();
      return false;
    }
  }

  // Update Avatar
  Future<bool> updateAvatar() async {
    if (_userProfile == null) {
      _errorMessage = 'User profile not loaded';
      return false;
    }

    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      // 1. Upload to Cloudinary (trả về URL)
      final avatarUrl = await _uploadService.pickAndUploadAvatar(
        _userProfile!.id,
      );

      // User cancelled image picker
      if (avatarUrl == null) {
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // 2. Update backend với URL
      final token = await _storageService.getToken();
      if (token == null) {
        _errorMessage = ErrorMessages.notAuthenticated;
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final response = await _repository.updateAvatarUrl(token, avatarUrl);

      if (response.success && response.data != null) {
        _userProfile = response.data;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.message ?? 'Failed to update avatar';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } on CloudinaryException catch (e) {
      // Handle Cloudinary-specific errors
      _errorMessage = _getCloudinaryErrorMessage(e);
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Failed to update avatar: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Take photo for Avatar
  Future<bool> takePhotoForAvatar() async {
    if (_userProfile == null) {
      _errorMessage = 'User profile not loaded';
      return false;
    }

    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      // 1. Take photo và upload to Cloudinary
      final avatarUrl = await _uploadService.takePhotoAndUploadAvatar(
        _userProfile!.id,
      );

      if (avatarUrl == null) {
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // 2. Update backend với URL
      final token = await _storageService.getToken();
      if (token == null) {
        _errorMessage = ErrorMessages.notAuthenticated;
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final response = await _repository.updateAvatarUrl(token, avatarUrl);

      if (response.success && response.data != null) {
        _userProfile = response.data;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.message ?? 'Failed to update avatar';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } on CloudinaryException catch (e) {
      _errorMessage = _getCloudinaryErrorMessage(e);
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Failed to update avatar: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Toggle Notifications
  Future<void> toggleNotifications(bool value) async {
    _notificationsEnabled = value;
    notifyListeners();

    try {
      final token = await _storageService.getToken();
      if (token == null) return;

      await _repository.updateNotificationSettings(token, value);
    } catch (e) {
      // Revert on error
      _notificationsEnabled = !value;
      _errorMessage = 'Failed to update notification settings';
      notifyListeners();
    }
  }

  // Break Connection
  Future<bool> breakConnection() async {
    try {
      final token = await _storageService.getToken();
      if (token == null) return false;

      _isLoading = true;
      notifyListeners();

      final response = await _repository.breakConnection(token);

      print('Break connection response: ${response.success}');

      if (response.success) {
        // Chỉ cập nhật state local, không reload profile
        _userProfile = _userProfile?.copyWith(partnerName: null);
        _isLoading = false;
        notifyListeners();
        print('Break connection completed successfully');
        return true;
      } else {
        _errorMessage = response.message ?? 'Failed to break connection';
        _isLoading = false;
        notifyListeners();
        print('Break connection failed: $_errorMessage');
        return false;
      }
    } catch (e) {
      _errorMessage = 'An error occurred. Please try again.';
      _isLoading = false;
      notifyListeners();
      print('Break connection error: $e');
      return false;
    }
  }

  // ============ HELPER METHOD ============
  String _getCloudinaryErrorMessage(CloudinaryException e) {
    switch (e.type) {
      case CloudinaryErrorType.fileTooLarge:
        return 'Image is too large. Please choose a smaller image (max 10MB).';
      case CloudinaryErrorType.invalidFormat:
        return 'Invalid image format. Please choose JPG, PNG, or WEBP.';
      case CloudinaryErrorType.networkError:
        return 'Network error. Please check your internet connection.';
      case CloudinaryErrorType.uploadFailed:
        return 'Upload failed. Please try again.';
      case CloudinaryErrorType.compressionFailed:
        return 'Failed to process image. Please try another image.';
      default:
        return e.message;
    }
  }
}
