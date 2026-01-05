import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/services/storage_service.dart';
import 'models/user_profile.dart';
import 'repository/settings_repository.dart';

class SettingsController extends ChangeNotifier {
  final StorageService _storageService = StorageService();
  final SettingsRepository _repository = SettingsRepository();
  final ImagePicker _imagePicker = ImagePicker();

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
        _errorMessage = 'Not authenticated';
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
      _errorMessage = 'Name cannot be empty';
      notifyListeners();
      return false;
    }

    try {
      final token = await _storageService.getToken();
      if (token == null) return false;

      final response = await _repository.updateProfile(token, {
        'name': newName,
      });

      if (response.success) {
        _userProfile = _userProfile?.copyWith(name: newName);
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.message ?? 'Failed to update name';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'An error occurred. Please try again.';
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
        'birthday': birthday.toIso8601String(),
      });

      if (response.success) {
        _userProfile = _userProfile?.copyWith(
          birthday: birthday.toIso8601String(),
        );
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.message ?? 'Failed to update birthday';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'An error occurred. Please try again.';
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

      if (response.success) {
        _userProfile = _userProfile?.copyWith(gender: gender);
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.message ?? 'Failed to update gender';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'An error occurred. Please try again.';
      notifyListeners();
      return false;
    }
  }

  // Update Avatar
  Future<bool> updateAvatar() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );

      if (image == null) return false;

      final token = await _storageService.getToken();
      if (token == null) return false;

      _isLoading = true;
      notifyListeners();

      final response = await _repository.updateAvatar(token, File(image.path));

      if (response.success && response.data != null) {
        _userProfile = _userProfile?.copyWith(avatarUrl: response.data);
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.message ?? 'Failed to update avatar';
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

      if (response.success) {
        _userProfile = _userProfile?.copyWith(
          isConnected: false,
          partnerName: null,
        );
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.message ?? 'Failed to break connection';
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

  // Logout
  Future<void> logout() async {
    try {
      await _storageService.clearAll();
      _userProfile = null;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to logout';
      notifyListeners();
    }
  }
}
