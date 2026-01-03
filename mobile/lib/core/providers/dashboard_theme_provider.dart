import 'dart:io';
import 'package:flutter/material.dart';
import '../theme/dashboard_theme.dart';
import '../theme/theme_presets.dart';
import '../services/theme_storage_service.dart';
import '../services/image_storage_service.dart';

class DashboardThemeProvider extends ChangeNotifier {
  final ThemeStorageService _storageService;
  final ImageStorageService _imageService;

  DashboardTheme _currentTheme = ThemePresets.defaultTheme;
  bool _isLoading = false;
  String? _errorMessage;

  DashboardThemeProvider({
    required ThemeStorageService storageService,
    required ImageStorageService imageService,
  }) : _storageService = storageService,
       _imageService = imageService {
    _initialize();
  }

  // Getters
  DashboardTheme get currentTheme => _currentTheme;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isCustomTheme => _currentTheme.isCustom;

  /// Initialize and load saved theme
  Future<void> _initialize() async {
    await loadSavedTheme();
  }

  /// Load saved theme from storage
  Future<void> loadSavedTheme() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final savedTheme = await _storageService.loadTheme();

      if (savedTheme != null) {
        _currentTheme = savedTheme;
        await _storageService.addToThemeHistory(savedTheme.id);
      } else {
        // No saved theme, use default
        _currentTheme = ThemePresets.defaultTheme;
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load theme: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
    }
  }

  // ========== PHASE 1: THEME PRESETS ==========

  /// Apply a preset theme
  Future<void> applyPreset(DashboardTheme preset) async {
    try {
      _errorMessage = null;

      // Apply preset
      _currentTheme = preset;
      notifyListeners();

      // Save to storage
      final saved = await _storageService.saveTheme(preset);
      if (!saved) {
        _errorMessage = 'Failed to save theme';
      } else {
        await _storageService.addToThemeHistory(preset.id);
      }

      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to apply preset: ${e.toString()}';
      notifyListeners();
    }
  }

  /// Get all available presets
  List<DashboardTheme> getAvailablePresets() {
    return ThemePresets.all;
  }

  /// Check if current theme is a preset
  bool isPresetTheme(String presetId) {
    return _currentTheme.id == presetId && !_currentTheme.isCustom;
  }

  // ========== PHASE 2: CUSTOM COLORS ==========

  /// Update a specific color property
  Future<void> updateColor(String property, Color value) async {
    try {
      _errorMessage = null;

      DashboardTheme updatedTheme;

      switch (property) {
        case 'primaryColor':
          updatedTheme = _currentTheme.copyWith(
            primaryColor: value,
            isCustom: true,
            name: _currentTheme.name,
          );
          break;
        case 'accentColor':
          updatedTheme = _currentTheme.copyWith(
            accentColor: value,
            isCustom: true,
            name: _currentTheme.name,
          );
          break;
        case 'cardBackground':
          updatedTheme = _currentTheme.copyWith(
            cardBackground: value,
            isCustom: true,
            name: _currentTheme.name,
          );
          break;
        case 'heartIconColor':
          updatedTheme = _currentTheme.copyWith(
            heartIconColor: value,
            isCustom: true,
            name: _currentTheme.name,
          );
          break;
        case 'partnerBorderColor':
          updatedTheme = _currentTheme.copyWith(
            partnerBorderColor: value,
            isCustom: true,
            name: _currentTheme.name,
          );
          break;
        case 'yourBorderColor':
          updatedTheme = _currentTheme.copyWith(
            yourBorderColor: value,
            isCustom: true,
            name: _currentTheme.name,
          );
          break;
        case 'textPrimaryColor':
          updatedTheme = _currentTheme.copyWith(
            textPrimaryColor: value,
            isCustom: true,
            name: _currentTheme.name,
          );
          break;
        case 'textSecondaryColor':
          updatedTheme = _currentTheme.copyWith(
            textSecondaryColor: value,
            isCustom: true,
            name: _currentTheme.name,
          );
          break;
        default:
          throw Exception('Unknown property: $property');
      }

      _currentTheme = updatedTheme;
      notifyListeners();

      // Save to storage
      await _storageService.saveTheme(updatedTheme);
    } catch (e) {
      _errorMessage = 'Failed to update color: ${e.toString()}';
      notifyListeners();
    }
  }

  /// Update multiple colors at once
  Future<void> updateColors(Map<String, Color> updates) async {
    try {
      _errorMessage = null;

      for (final entry in updates.entries) {
        await updateColor(entry.key, entry.value);
      }
    } catch (e) {
      _errorMessage = 'Failed to update colors: ${e.toString()}';
      notifyListeners();
    }
  }

  // ========== PHASE 2: CUSTOM IMAGES ==========

  /// Update couple background image
  Future<void> updateCoupleBackground(File imageFile) async {
    try {
      _errorMessage = null;
      _isLoading = true;
      notifyListeners();

      // Delete old image if exists
      if (_currentTheme.coupleBackgroundPath != null) {
        await _imageService.deleteImage(_currentTheme.coupleBackgroundPath);
      }

      // Save new image
      final imagePath = await _imageService.saveCoupleBackground(imageFile);

      // Update theme
      final updatedTheme = _currentTheme.copyWith(
        coupleBackgroundPath: imagePath,
        isCustom: true,
        name: _currentTheme.name,
      );

      _currentTheme = updatedTheme;
      _isLoading = false;
      notifyListeners();

      // Save to storage
      await _storageService.saveTheme(updatedTheme);
    } catch (e) {
      _errorMessage = 'Failed to update background: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Remove custom couple background (revert to default)
  Future<void> removeCoupleBackground() async {
    try {
      _errorMessage = null;

      // Delete image file
      if (_currentTheme.coupleBackgroundPath != null) {
        await _imageService.deleteImage(_currentTheme.coupleBackgroundPath);
      }

      // Update theme
      final updatedTheme = _currentTheme.copyWith(coupleBackgroundPath: null);

      _currentTheme = updatedTheme;
      notifyListeners();

      // Save to storage
      await _storageService.saveTheme(updatedTheme);
    } catch (e) {
      _errorMessage = 'Failed to remove background: ${e.toString()}';
      notifyListeners();
    }
  }

  /// Get couple background image file
  Future<File?> getCoupleBackgroundImage() async {
    if (_currentTheme.coupleBackgroundPath == null) {
      return null;
    }
    return await _imageService.loadImage(_currentTheme.coupleBackgroundPath);
  }

  /// Check if custom background exists
  Future<bool> hasCustomBackground() async {
    if (_currentTheme.coupleBackgroundPath == null) {
      return false;
    }
    return await _imageService.imageExists(_currentTheme.coupleBackgroundPath);
  }

  // ========== THEME MANAGEMENT ==========

  /// Reset to default theme
  Future<void> resetToDefault() async {
    try {
      _errorMessage = null;

      // Delete custom images
      if (_currentTheme.coupleBackgroundPath != null) {
        await _imageService.deleteImage(_currentTheme.coupleBackgroundPath);
      }

      // Reset to default preset
      _currentTheme = ThemePresets.defaultTheme;
      notifyListeners();

      // Clear storage
      await _storageService.clearTheme();
    } catch (e) {
      _errorMessage = 'Failed to reset theme: ${e.toString()}';
      notifyListeners();
    }
  }

  /// Reset only colors (keep custom images)
  Future<void> resetColors() async {
    try {
      _errorMessage = null;

      // Find the base preset
      final basePreset =
          ThemePresets.getById(_currentTheme.id) ?? ThemePresets.defaultTheme;

      // Keep custom background but reset colors
      final updatedTheme = basePreset.copyWith(
        coupleBackgroundPath: _currentTheme.coupleBackgroundPath,
        isCustom: _currentTheme.coupleBackgroundPath != null,
      );

      _currentTheme = updatedTheme;
      notifyListeners();

      await _storageService.saveTheme(updatedTheme);
    } catch (e) {
      _errorMessage = 'Failed to reset colors: ${e.toString()}';
      notifyListeners();
    }
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Export current theme as JSON
  String? exportTheme() {
    return _storageService.exportTheme();
  }

  /// Import theme from JSON
  Future<void> importTheme(String jsonString) async {
    try {
      _errorMessage = null;
      _isLoading = true;
      notifyListeners();

      final success = await _storageService.importTheme(jsonString);

      if (success) {
        await loadSavedTheme();
      } else {
        _errorMessage = 'Failed to import theme';
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to import theme: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Get theme history
  List<String> getThemeHistory() {
    return _storageService.getThemeHistory();
  }

  @override
  void dispose() {
    super.dispose();
  }
}
