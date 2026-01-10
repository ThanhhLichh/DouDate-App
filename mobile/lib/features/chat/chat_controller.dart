import 'package:flutter/material.dart';
import '../../core/services/storage_service.dart';
import 'models/chat_models.dart';
import 'models/conversation_settings_models.dart';
import 'repository/chat_repository.dart';
// import '../../core/services/websocket_service.dart';
import '../../core/websocket/chat_websocket_service.dart';

class ChatController extends ChangeNotifier {
  final ChatRepository _repository = ChatRepository();
  final StorageService _storageService = StorageService();
  final ChatWebSocketService _chatSocketService = ChatWebSocketService();

  List<Message> _messages = [];
  Conversation? _conversation;
  ConversationSettings? _settings;
  List<MediaItem> _mediaItems = [];
  bool _isLoading = false;
  bool _isSending = false;
  String? _errorMessage;
  int? _currentUserId;

  List<Message> get messages => _messages;
  Conversation? get conversation => _conversation;
  ConversationSettings? get settings => _settings;
  List<MediaItem> get mediaItems => _mediaItems;
  bool get isLoading => _isLoading;
  bool get isSending => _isSending;
  String? get errorMessage => _errorMessage;
  bool get isConnected => _chatSocketService.isConnected;
  int? get currentUserId => _currentUserId;

  ChatController() {
    _loadCurrentUserId();
    _listenToWebSocket();
  }

  Future<void> _loadCurrentUserId() async {
    final id = await _storageService.getUserId();
    if (id != null) {
      _currentUserId = id;
      notifyListeners();
    }
  }

  void _listenToWebSocket() {
    _chatSocketService.messageStream.listen((message) {
      // Thêm sender info từ conversation
      Message enrichedMessage = message;

      if (_conversation != null && _currentUserId != null) {
        final isMe = message.senderId == _currentUserId;
        enrichedMessage = message.copyWith(
          senderName: isMe
              ? _conversation!.yourName
              : _conversation!.partnerName,
          senderAvatar: isMe
              ? _conversation!.yourAvatar
              : _conversation!.partnerAvatar,
        );
      }

      // Kiểm tra message đã tồn tại chưa
      final existingIndex = _messages.indexWhere((m) => m.id == message.id);
      if (existingIndex == -1) {
        _messages.add(enrichedMessage);
        _conversation = _conversation?.copyWith(lastMessage: enrichedMessage);
        notifyListeners();
      }
    });
  }

  Future<void> initializeConversation() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Load current user ID
      await _loadCurrentUserId();

      // Get conversation info
      final response = await _repository.getPartnerConversation();

      if (response.success && response.data != null) {
        _conversation = response.data;
        _errorMessage = null;

        // Load settings
        await _loadSettingsFromStorage();

        // Connect WebSocket
        await _connectWebSocket();
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

  Future<void> _connectWebSocket() async {
    if (_conversation == null) return;

    try {
      final token = await _storageService.getToken();
      if (token != null) {
        await _chatSocketService.connect({
          'coupleId': _conversation!.coupleId,
          'token': token,
        });
      }
    } catch (e) {
      print('Failed to connect WebSocket: $e');
    }
  }

  Future<void> _loadSettingsFromStorage() async {
    try {
      final settingsJson = await _storageService.getConversationSettings();

      if (settingsJson != null) {
        _settings = ConversationSettings.fromJson(settingsJson);
      } else if (_conversation != null) {
        _settings = ConversationSettings(conversationId: _conversation!.id);
        await _saveSettingsToStorage();
      }

      notifyListeners();
    } catch (e) {
      if (_conversation != null) {
        _settings = ConversationSettings(conversationId: _conversation!.id);
      }
    }
  }

  Future<void> _saveSettingsToStorage() async {
    if (_settings != null) {
      try {
        await _storageService.saveConversationSettings(_settings!.toJson());
      } catch (e) {
        print('Failed to save settings: $e');
      }
    }
  }

  Future<void> fetchMessages() async {
    if (_conversation == null) {
      await initializeConversation();
      if (_conversation == null) return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _repository.getMessages(_conversation!.coupleId);

      if (response.success && response.data != null) {
        // Enrich messages with sender info
        _messages = response.data!.map((msg) {
          final isMe = msg.senderId == _currentUserId;
          return msg.copyWith(
            senderName: isMe
                ? _conversation!.yourName
                : _conversation!.partnerName,
            senderAvatar: isMe
                ? _conversation!.yourAvatar
                : _conversation!.partnerAvatar,
          );
        }).toList();

        _errorMessage = null;

        await _repository.markAsRead(_conversation!.coupleId);

        if (_messages.isNotEmpty) {
          _conversation = _conversation!.copyWith(
            lastMessage: _messages.last,
            unreadCount: 0,
          );
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

  Future<bool> sendMessage(String content) async {
    if (content.trim().isEmpty ||
        _conversation == null ||
        !_chatSocketService.isConnected) {
      return false;
    }

    _isSending = true;
    notifyListeners();

    try {
      _chatSocketService.sendMessage(content.trim());
      _isSending = false;
      notifyListeners();
      return true;
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

  // Conversation settings methods giữ nguyên...
  Future<void> loadSettings() async {
    if (_conversation == null) return;
    await _loadSettingsFromStorage();
  }

  Future<bool> updateBubbleColor(String hexColor) async {
    if (_conversation == null || _settings == null) return false;

    try {
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
        notifyListeners();
      }

      return true;
    } catch (e) {
      return false;
    }
  }

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

  Future<bool> updateNicknames({
    String? yourNickname,
    String? partnerNickname,
  }) async {
    if (_conversation == null || _settings == null) return false;

    try {
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

  Future<bool> updateBackgroundTheme(BackgroundTheme theme) async {
    if (_conversation == null || _settings == null) return false;

    try {
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

  Future<bool> reactToMessage(int messageId, String emoji) async {
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

  @override
  void dispose() {
    _chatSocketService.dispose();
    super.dispose();
  }
}
