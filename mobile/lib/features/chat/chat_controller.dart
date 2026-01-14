import 'package:flutter/material.dart';
import '../../core/services/storage_service.dart';
import 'models/chat_models.dart';
import 'models/conversation_settings_models.dart';
import 'repository/chat_repository.dart';
import '../../core/websocket/chat_websocket_service.dart';
import 'dart:async';
import '../home/home_controller.dart';

class ChatController extends ChangeNotifier {
  final ChatRepository _repository = ChatRepository();
  final StorageService _storageService = StorageService();
  final ChatWebSocketService _chatSocketService = ChatWebSocketService();
  final HomeController? homeController;

  List<Message> _messages = [];
  Conversation? _conversation;
  ConversationSettings? _settings;
  List<MediaItem> _mediaItems = [];
  bool _isLoading = false;
  bool _isSending = false;
  String? _errorMessage;
  int? _currentUserId;
  int? _partnerId;

  List<Message> get messages => _messages;
  Conversation? get conversation => _conversation;
  ConversationSettings? get settings => _settings;
  List<MediaItem> get mediaItems => _mediaItems;
  bool get isLoading => _isLoading;
  bool get isSending => _isSending;
  String? get errorMessage => _errorMessage;
  bool get isConnected => _chatSocketService.isConnected;
  int? get currentUserId => _currentUserId;
  int? get partnerId => _partnerId;

  StreamSubscription? _presenceSubscription;
  StreamSubscription? _settingsUpdateSubscription;
  StreamSubscription? _reactionSubscription;

  String? get partnerAvatar => homeController?.dashboardData?.partnerAvatar;
  String? get partnerName => homeController?.dashboardData?.partnerName;
  String? get yourAvatar => homeController?.dashboardData?.yourAvatar;
  String? get yourName => homeController?.dashboardData?.yourName;

  ChatController({this.homeController}) {
    _loadCurrentUserId();
    _loadPartnerId();
    _listenToWebSocket();
    _listenToPresence();
    _listenToSettingsUpdate();
    _listenToReactions();
  }

  Future<void> _loadCurrentUserId() async {
    final id = await _storageService.getUserId();
    if (id != null) {
      _currentUserId = id;
      notifyListeners();
    }
  }

  Future<void> _loadPartnerId() async {
    final id = await _storageService.getPartnerId();
    if (id != null) {
      _partnerId = id;
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
              ? (yourName ?? _conversation!.yourName)
              : (partnerName ?? _conversation!.partnerName),
          senderAvatar: isMe
              ? (yourAvatar ?? _conversation!.yourAvatar)
              : (partnerAvatar ?? _conversation!.partnerAvatar),
        );
      }

      if (message.id <= 0 || message.content.trim().isEmpty) {
        print('Invalid message received, skipping');
        return;
      }

      final existingIndex = _messages.indexWhere((m) => m.id == message.id);
      if (existingIndex == -1) {
        _messages.add(enrichedMessage);
        _conversation = _conversation?.copyWith(lastMessage: enrichedMessage);
        notifyListeners();
      }
    });
  }

  // Listen presence events
  void _listenToPresence() {
    _presenceSubscription = _chatSocketService.presenceStream.listen((event) {
      if (_conversation == null || _currentUserId == null) return;

      // Lấy partner ID
      final partnerId = _partnerId;

      // Chỉ cập nhật nếu event là của partner
      if (event.userId == partnerId) {
        final isOnline = event.status == 'online';

        _conversation = _conversation!.copyWith(
          isOnline: isOnline,
          lastSeen: isOnline ? null : DateTime.now(),
        );

        notifyListeners();
        print('Partner ${isOnline ? "is now online" : "went offline"}');
      }
    });
  }

  // Listen settings update events
  void _listenToSettingsUpdate() {
    _settingsUpdateSubscription = _chatSocketService.settingsUpdateStream
        .listen((_) async {
          if (_conversation == null) return;

          print('Reloading settings from server...');

          // Reload settings from server
          final response = await _repository.getConversationSettings(
            _conversation!.coupleId,
          );

          if (response.success && response.data != null) {
            _settings = response.data;
            await _saveSettingsToStorage();
            notifyListeners();
            print('Settings reloaded successfully');
          }
        });
  }

  // Listen reaction emoji events
  void _listenToReactions() {
    _reactionSubscription = _chatSocketService.reactionStream.listen((
      reaction,
    ) {
      _handleReactionEvent(reaction);
    });
  }

  Future<void> _requestPresenceState() async {
    if (_conversation == null) return;

    print('Waiting for presence state from server...');
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

        await _requestPresenceState();
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
        notifyListeners();
      }

      // Then fetch from server if we have conversation
      if (_conversation != null) {
        final response = await _repository.getConversationSettings(
          _conversation!.coupleId,
        );

        if (response.success && response.data != null) {
          _settings = response.data;
          await _saveSettingsToStorage();
          notifyListeners();
        } else if (settingsJson == null) {
          // No local cache and server failed, create default
          _settings = ConversationSettings(
            conversationId: _conversation!.coupleId,
          );
          await _saveSettingsToStorage();
          notifyListeners();
        }
      }
    } catch (e) {
      // Fallback to default if everything fails
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
        _messages = response.data!.map((msg) {
          final isMe = msg.senderId == _currentUserId;
          return msg.copyWith(
            senderName: isMe
                ? (yourName ?? _conversation!.yourName)
                : (partnerName ?? _conversation!.partnerName),
            senderAvatar: isMe
                ? (yourAvatar ?? _conversation!.yourAvatar)
                : (partnerAvatar ?? _conversation!.partnerAvatar),
          );
        }).toList();

        _errorMessage = null;

        await _repository.markAsRead(_conversation!.coupleId);

        notifyListeners();

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

  void _handleReactionEvent(MessageReaction reaction) {
    final messageIndex = _messages.indexWhere(
      (m) => m.id == reaction.messageId,
    );
    if (messageIndex == -1) return;

    final message = _messages[messageIndex];
    final currentReactions = Map<int, String>.from(
      message.reactionsByUserId ?? {},
    );

    if (reaction.emoji == null) {
      currentReactions.remove(reaction.userId);
    } else {
      currentReactions[reaction.userId] = reaction.emoji!;
    }

    _messages[messageIndex] = message.copyWith(
      reactionsByUserId: currentReactions.isEmpty ? null : currentReactions,
    );

    notifyListeners();
    print(
      'Reaction updated: message ${reaction.messageId}, user ${reaction.userId}, emoji: ${reaction.emoji}',
    );
  }

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
    if (_currentUserId == null) return false;

    try {
      // Optimistic update
      final messageIndex = _messages.indexWhere((m) => m.id == messageId);
      if (messageIndex == -1) return false;

      final message = _messages[messageIndex];
      final currentReactions = Map<int, String>.from(
        message.reactionsByUserId ?? {},
      );
      final existingEmoji = currentReactions[_currentUserId!];

      String? emojiToSend;
      if (existingEmoji == emoji) {
        // Tap lại cùng emoji → remove
        currentReactions.remove(_currentUserId!);
        emojiToSend = null;
      } else {
        // Thả emoji mới (replace cũ)
        currentReactions[_currentUserId!] = emoji;
        emojiToSend = emoji;
      }

      // Update UI ngay
      _messages[messageIndex] = message.copyWith(
        reactionsByUserId: currentReactions.isEmpty ? null : currentReactions,
      );
      notifyListeners();

      // Call API
      final response = await _repository.reactToMessage(messageId, emojiToSend);

      if (!response.success) {
        // Rollback nếu fail
        _messages[messageIndex] = message;
        notifyListeners();
        _errorMessage = response.message ?? 'Failed to react';
        return false;
      }

      return true;
    } catch (e) {
      _errorMessage = 'Failed to react: $e';
      return false;
    }
  }

  @override
  void dispose() {
    _presenceSubscription?.cancel();
    _settingsUpdateSubscription?.cancel();
    _reactionSubscription?.cancel();
    _chatSocketService.dispose();
    super.dispose();
  }
}
