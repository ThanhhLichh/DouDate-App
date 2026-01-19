import 'package:flutter/material.dart';
import '../../../core/services/storage_service.dart';
import '../models/chat_models.dart';
import '../models/conversation_settings_models.dart';
import '../repository/conversation_repository.dart';
import '../../../core/websocket/chat_websocket_service.dart';
import 'dart:async';

class ConversationController extends ChangeNotifier {
  final ConversationRepository _repository = ConversationRepository();
  final StorageService _storageService = StorageService();

  ChatWebSocketService? _chatSocketService;

  Conversation? _conversation;
  ConversationSettings? _settings;
  bool _isLoading = false;
  String? _errorMessage;
  final List<MediaItem> _mediaItems = [];

  Conversation? get conversation => _conversation;
  ConversationSettings? get settings => _settings;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<MediaItem> get mediaItems => _mediaItems;

  StreamSubscription? _settingsUpdateSubscription;

  ConversationController();

  void setWebSocketService(ChatWebSocketService service) {
    _chatSocketService = service;
    _listenToSettingsUpdate();
  }

  void _listenToSettingsUpdate() {
    if (_chatSocketService == null) {
      debugPrint(
        'WebSocket service not set, cannot listen to settings updates',
      );
      return;
    }

    _settingsUpdateSubscription = _chatSocketService!.settingsUpdateStream
        .listen((_) async {
          if (_conversation == null) return;

          debugPrint('Settings update event received, reloading...');

          final response = await _repository.getConversationSettings(
            _conversation!.coupleId,
          );

          if (response.success && response.data != null) {
            _settings = response.data;
            await _saveSettingsToStorage();
            notifyListeners();
            debugPrint('Settings reloaded successfully');
          }
        });
  }

  /// Load conversation từ API
  Future<void> loadConversation() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _repository.getPartnerConversation();

      if (response.success && response.data != null) {
        _conversation = response.data;
        _errorMessage = null;
        await _loadSettingsFromStorage();
      } else {
        _errorMessage = response.message ?? 'Failed to load conversation';
      }
    } catch (e) {
      _errorMessage = 'An error occurred. Please try again.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load settings từ storage và server
  Future<void> loadSettings() async {
    if (_conversation == null) return;
    await _loadSettingsFromStorage();
  }

  Future<void> _loadSettingsFromStorage() async {
    try {
      final settingsJson = await _storageService.getConversationSettings();

      if (settingsJson != null) {
        _settings = ConversationSettings.fromJson(settingsJson);
        notifyListeners();
      }

      if (_conversation != null) {
        final response = await _repository.getConversationSettings(
          _conversation!.coupleId,
        );

        if (response.success && response.data != null) {
          _settings = response.data;
          await _saveSettingsToStorage();
          notifyListeners();
        } else if (settingsJson == null) {
          _settings = ConversationSettings(
            conversationId: _conversation!.coupleId,
          );
          await _saveSettingsToStorage();
          notifyListeners();
        }
      }
    } catch (e) {
      if (_conversation != null && _settings == null) {
        _settings = ConversationSettings(
          conversationId: _conversation!.coupleId,
        );
      }
    }
  }

  Future<void> _saveSettingsToStorage() async {
    if (_settings != null) {
      try {
        await _storageService.saveConversationSettings(_settings!.toJson());
      } catch (e) {
        debugPrint('Failed to save settings: $e');
      }
    }
  }

  /// Update bubble color
  Future<bool> updateBubbleColor(String hexColor) async {
    if (_conversation == null || _settings == null) return false;

    try {
      final oldSettings = _settings;
      _settings = _settings!.copyWith(bubbleColor: hexColor);
      await _saveSettingsToStorage();
      notifyListeners();

      final response = await _repository.updateConversationSettings(
        _conversation!.id,
        _settings!,
      );

      if (response.success && response.data != null) {
        _settings = response.data;
        await _saveSettingsToStorage();
      } else {
        _settings = oldSettings;
        await _saveSettingsToStorage();
        notifyListeners();
      }

      return response.success;
    } catch (e) {
      return false;
    }
  }

  /// Update quick emoji
  Future<bool> updateQuickEmoji(String emoji) async {
    if (_conversation == null || _settings == null) return false;

    try {
      final oldSettings = _settings;
      _settings = _settings!.copyWith(quickEmoji: emoji);
      await _saveSettingsToStorage();
      notifyListeners();

      final response = await _repository.updateConversationSettings(
        _conversation!.id,
        _settings!,
      );

      if (!response.success) {
        _settings = oldSettings;
        await _saveSettingsToStorage();
        notifyListeners();
      }

      return response.success;
    } catch (e) {
      return false;
    }
  }

  /// Update nicknames
  Future<bool> updateNicknames({
    String? yourNickname,
    String? partnerNickname,
  }) async {
    if (_conversation == null || _settings == null) return false;

    try {
      final oldSettings = _settings;
      _settings = _settings!.copyWith(
        yourNickname: yourNickname ?? _settings!.yourNickname,
        partnerNickname: partnerNickname ?? _settings!.partnerNickname,
      );

      await _saveSettingsToStorage();
      notifyListeners();

      final response = await _repository.updateConversationSettings(
        _conversation!.id,
        _settings!,
      );

      if (!response.success) {
        _settings = oldSettings;
        await _saveSettingsToStorage();
        notifyListeners();
      }

      return response.success;
    } catch (e) {
      return false;
    }
  }

  /// Update background theme
  Future<bool> updateBackgroundTheme(BackgroundTheme theme) async {
    if (_conversation == null || _settings == null) return false;

    try {
      final oldSettings = _settings;
      _settings = _settings!.copyWith(
        backgroundTheme: theme,
        bubbleColor: theme.recommendedBubbleColor,
      );

      await _saveSettingsToStorage();
      notifyListeners();

      final response = await _repository.updateConversationSettings(
        _conversation!.id,
        _settings!,
      );

      if (!response.success) {
        _settings = oldSettings;
        await _saveSettingsToStorage();
        notifyListeners();
      }

      return response.success;
    } catch (e) {
      return false;
    }
  }

  /// Update conversation online status
  void updateOnlineStatus(bool isOnline) {
    if (_conversation == null) return;

    _conversation = _conversation!.copyWith(
      isOnline: isOnline,
      lastSeen: isOnline ? null : DateTime.now(),
    );
    notifyListeners();
  }

  /// Update last message
  void updateLastMessage(Message message) {
    if (_conversation == null) return;

    _conversation = _conversation!.copyWith(
      lastMessage: message,
      unreadCount: 0,
    );
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _settingsUpdateSubscription?.cancel();
    super.dispose();
  }
}
