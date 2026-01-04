import 'package:flutter/material.dart';
import '../../core/services/storage_service.dart';
import 'models/chat_models.dart';
import 'models/conversation_settings_models.dart';
import 'repository/chat_repository.dart';

class ChatController extends ChangeNotifier {
  final ChatRepository _repository = ChatRepository();
  final StorageService _storageService = StorageService();

  // State
  List<Message> _messages = [];
  Conversation? _conversation;
  ConversationSettings? _settings;
  List<MediaItem> _mediaItems = [];
  bool _isLoading = false;
  bool _isSending = false;
  String? _errorMessage;

  // Getters
  List<Message> get messages => _messages;
  Conversation? get conversation => _conversation;
  ConversationSettings? get settings => _settings;
  List<MediaItem> get mediaItems => _mediaItems;
  bool get isLoading => _isLoading;
  bool get isSending => _isSending;
  String? get errorMessage => _errorMessage;

  // Initialize conversation
  Future<void> initializeConversation() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _repository.getPartnerConversation();

      if (response.success && response.data != null) {
        _conversation = response.data;
        _errorMessage = null;

        // Load settings from local storage
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

  // Load settings from local storage
  Future<void> _loadSettingsFromStorage() async {
    try {
      final settingsJson = await _storageService.getConversationSettings();

      if (settingsJson != null) {
        _settings = ConversationSettings.fromJson(settingsJson);
      } else if (_conversation != null) {
        // Create default settings
        _settings = ConversationSettings(conversationId: _conversation!.id);
        await _saveSettingsToStorage();
      }

      notifyListeners();
    } catch (e) {
      // Use default settings if loading fails
      if (_conversation != null) {
        _settings = ConversationSettings(conversationId: _conversation!.id);
      }
    }
  }

  // Save settings to local storage
  Future<void> _saveSettingsToStorage() async {
    if (_settings != null) {
      try {
        await _storageService.saveConversationSettings(_settings!.toJson());
      } catch (e) {
        print('Failed to save settings: $e');
      }
    }
  }

  // Fetch messages
  Future<void> fetchMessages() async {
    if (_conversation == null) {
      await initializeConversation();
      if (_conversation == null) return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _repository.getMessages(_conversation!.id);

      if (response.success && response.data != null) {
        _messages = response.data!;
        _errorMessage = null;

        await _repository.markAsRead(_conversation!.id);

        if (_conversation != null) {
          _conversation = _conversation!.copyWith(unreadCount: 0);
        }
      } else {
        _errorMessage = response.message ?? 'Failed to load messages';
      }
    } catch (e) {
      _errorMessage = 'An error occurred. Please try again.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Send message
  Future<bool> sendMessage(String content) async {
    if (content.trim().isEmpty || _conversation == null) return false;

    _isSending = true;
    notifyListeners();

    try {
      final response = await _repository.sendMessage(
        conversationId: _conversation!.id,
        content: content.trim(),
        type: MessageType.text,
      );

      if (response.success && response.data != null) {
        _messages.add(response.data!);
        _conversation = _conversation!.copyWith(lastMessage: response.data!);

        _isSending = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.message ?? 'Failed to send message';
        _isSending = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Failed to send message';
      _isSending = false;
      notifyListeners();
      return false;
    }
  }

  int get unreadCount => _conversation?.unreadCount ?? 0;

  Future<void> refreshMessages() async {
    await fetchMessages();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // ==================== CONVERSATION SETTINGS ====================

  // Load conversation settings
  Future<void> loadSettings() async {
    if (_conversation == null) return;

    // Load from local storage first
    await _loadSettingsFromStorage();

    // DON'T sync with backend on every load
    // Backend sync only happens when user explicitly updates settings
    // This prevents overwriting local changes with stale backend data
  }

  // Update bubble color
  Future<bool> updateBubbleColor(String hexColor) async {
    if (_conversation == null || _settings == null) return false;

    try {
      // Update local state immediately
      _settings = _settings!.copyWith(bubbleColor: hexColor);
      await _saveSettingsToStorage();
      notifyListeners();

      // Sync with backend
      final response = await _repository.updateConversationSettings(
        _conversation!.id,
        _settings!,
      );

      if (response.success && response.data != null) {
        _settings = response.data;
        await _saveSettingsToStorage();
        notifyListeners();
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  // Update quick emoji
  Future<bool> updateQuickEmoji(String emoji) async {
    if (_conversation == null || _settings == null) return false;

    try {
      _settings = _settings!.copyWith(quickEmoji: emoji);
      await _saveSettingsToStorage();
      notifyListeners();

      final response = await _repository.updateConversationSettings(
        _conversation!.id,
        _settings!,
      );

      if (response.success && response.data != null) {
        _settings = response.data;
        await _saveSettingsToStorage();
        notifyListeners();
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  // Update nicknames
  Future<bool> updateNicknames({
    String? yourNickname,
    String? partnerNickname,
  }) async {
    if (_conversation == null || _settings == null) return false;

    try {
      // Update settings
      _settings = _settings!.copyWith(
        yourNickname: yourNickname ?? _settings!.yourNickname,
        partnerNickname: partnerNickname ?? _settings!.partnerNickname,
      );

      await _saveSettingsToStorage();
      notifyListeners();

      // Sync with backend
      final response = await _repository.updateConversationSettings(
        _conversation!.id,
        _settings!,
      );

      if (response.success && response.data != null) {
        _settings = response.data;
        await _saveSettingsToStorage();
        notifyListeners();
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  // Update background theme
  Future<bool> updateBackgroundTheme(BackgroundTheme theme) async {
    if (_conversation == null || _settings == null) return false;

    try {
      // Update theme and auto-adjust bubble color
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

      if (response.success && response.data != null) {
        _settings = response.data;
        await _saveSettingsToStorage();
        notifyListeners();
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  // Load media items
  Future<void> loadMediaItems() async {
    if (_conversation == null) return;

    try {
      final response = await _repository.getMediaItems(_conversation!.id);

      if (response.success && response.data != null) {
        _mediaItems = response.data!;
        notifyListeners();
      }
    } catch (e) {
      // Silent fail
    }
  }

  // React to message
  Future<bool> reactToMessage(String messageId, String emoji) async {
    try {
      final response = await _repository.reactToMessage(messageId, emoji);

      if (response.success) {
        final index = _messages.indexWhere((m) => m.id == messageId);
        if (index != -1) {
          final currentReactions = _messages[index].reactions ?? [];
          final newReactions = [...currentReactions];

          if (newReactions.contains(emoji)) {
            newReactions.remove(emoji);
          } else {
            newReactions.add(emoji);
          }

          _messages[index] = _messages[index].copyWith(reactions: newReactions);
          notifyListeners();
        }
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}
