import 'package:flutter/material.dart';
import 'package:mobile/features/chat/models/conversation_settings_models.dart';
import '../../../core/services/storage_service.dart';
import '../models/chat_models.dart';
import '../repository/chat_repository.dart';
import '../../../core/websocket/chat_websocket_service.dart';
import '../../../core/models/cloudinary_models.dart';
import 'dart:async';
import '../../home/controllers/home_controller.dart';
import '../../../core/services/image_upload_service.dart';
import 'conversation_controller.dart';

class ChatController extends ChangeNotifier {
  final ChatRepository _repository = ChatRepository();
  final StorageService _storageService = StorageService();
  final ChatWebSocketService _chatSocketService = ChatWebSocketService();
  final HomeController? homeController;
  final ConversationController conversationController;
  final ImageUploadService _imageUploadService = ImageUploadService();

  List<Message> _messages = [];
  bool _isLoading = false;
  bool _isSending = false;
  String? _errorMessage;
  int? _currentUserId;
  int? _partnerId;
  bool _hasMoreMessages = true;
  bool _isLoadingMore = false;

  List<Message> get messages => _messages;
  List<MediaItem> get mediaItems {
    return _messages
        .where(
          (m) => m.type == MessageType.image && (m.imgUrl?.isNotEmpty ?? false),
        )
        .map(
          (m) => MediaItem(
            id: m.id.toString(),
            url: m.imgUrl!,
            type: MediaType.image,
            timestamp: m.createdAt,
          ),
        )
        .toList()
        .reversed
        .toList();
  }

  bool get isLoading => _isLoading;
  bool get isSending => _isSending;
  String? get errorMessage => _errorMessage;
  bool get isConnected => _chatSocketService.isConnected;
  int? get currentUserId => _currentUserId;
  int? get partnerId => _partnerId;
  bool get hasMoreMessages => _hasMoreMessages;
  bool get isLoadingMore => _isLoadingMore;

  StreamSubscription? _presenceSubscription;
  StreamSubscription? _reactionSubscription;
  StreamSubscription? _readReceiptSubscription;
  StreamSubscription? _messageUpdatedSubscription;
  StreamSubscription? _messageDeletedSubscription;

  String? get partnerAvatar => homeController?.dashboardData?.partnerAvatar;
  String? get partnerName => homeController?.dashboardData?.partnerName;
  String? get yourAvatar => homeController?.dashboardData?.yourAvatar;
  String? get yourName => homeController?.dashboardData?.yourName;

  // Track lifecycle
  bool _isScreenVisible = false;

  ChatController({this.homeController, required this.conversationController}) {
    _loadCurrentUserId();
    _loadPartnerId();
    _listenToWebSocket();
    _listenToPresence();
    _listenToReactions();
    _listenToReadReceipts();
    _listenToMessageUpdates();
    _listenToMessageDeletes();

    conversationController.setWebSocketService(_chatSocketService);
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

  Future<void> loadMoreMessages() async {
    await fetchMessages(loadMore: true);
  }

  void _listenToWebSocket() {
    _chatSocketService.messageStream.listen((message) {
      Message enrichedMessage = message;

      if (conversationController.conversation != null &&
          _currentUserId != null) {
        final isMe = message.senderId == _currentUserId;
        final conversation = conversationController.conversation!;

        enrichedMessage = message.copyWith(
          senderName: isMe
              ? (yourName ?? conversation.yourName)
              : (partnerName ?? conversation.partnerName),
          senderAvatar: isMe
              ? (yourAvatar ?? conversation.yourAvatar)
              : (partnerAvatar ?? conversation.partnerAvatar),
        );
      }

      bool isInvalid = message.id <= 0;

      if (message.type == MessageType.text) {
        isInvalid |= message.content.trim().isEmpty;
      } else if (message.type == MessageType.image) {
        isInvalid |= (message.imgUrl == null || message.imgUrl!.isEmpty);
      }

      if (isInvalid) {
        debugPrint('Invalid message received, skipping');
        return;
      }

      final existingIndex = _messages.indexWhere((m) => m.id == message.id);
      if (existingIndex == -1) {
        _messages.add(enrichedMessage);
        conversationController.updateLastMessage(enrichedMessage);
        notifyListeners();

        // CHỈ mark as read khi screen visible VÀ tin nhắn từ partner
        if (_isScreenVisible && message.senderId != _currentUserId) {
          debugPrint(
            'New message received while screen is visible, marking as read',
          );
          _markNewMessagesAsRead();
        } else {
          debugPrint('Screen not visible or own message, NOT marking as read');
        }
      }
    });
  }

  void _listenToPresence() {
    _presenceSubscription = _chatSocketService.presenceStream.listen((event) {
      if (conversationController.conversation == null ||
          _currentUserId == null) {
        return;
      }

      final partnerId = _partnerId;

      if (event.userId == partnerId) {
        final isOnline = event.status == 'online';
        conversationController.updateOnlineStatus(isOnline);
        debugPrint('Partner ${isOnline ? "is now online" : "went offline"}');
      }
    });
  }

  void _listenToReactions() {
    _reactionSubscription = _chatSocketService.reactionStream.listen((
      reaction,
    ) {
      _handleReactionEvent(reaction);
    });
  }

  void _listenToReadReceipts() {
    _readReceiptSubscription = _chatSocketService.readReceiptStream.listen((
      receipt,
    ) {
      // Update messages that were read by partner
      for (int i = 0; i < _messages.length; i++) {
        if (_messages[i].id <= receipt.lastMessageId &&
            _messages[i].senderId == _currentUserId) {
          _messages[i] = _messages[i].copyWith(
            isRead: true,
            readAt: receipt.readAt,
          );
        }
      }
      notifyListeners();
      debugPrint('Partner read messages up to ID: ${receipt.lastMessageId}');
    });
  }

  void _listenToMessageUpdates() {
    _messageUpdatedSubscription = _chatSocketService.messageUpdatedStream
        .listen((data) {
          final messageId = data['message_id'] as int;
          final content = data['content'] as String;
          final editedAt = DateTime.parse(data['edited_at'] as String);

          final messageIndex = _messages.indexWhere((m) => m.id == messageId);
          if (messageIndex != -1) {
            _messages[messageIndex] = _messages[messageIndex].copyWith(
              content: content,
              editedAt: editedAt,
            );
            notifyListeners();
            debugPrint('Message $messageId updated');
          }
        });
  }

  void _listenToMessageDeletes() {
    _messageDeletedSubscription = _chatSocketService.messageDeletedStream
        .listen((messageId) {
          final messageIndex = _messages.indexWhere((m) => m.id == messageId);
          if (messageIndex != -1) {
            _messages[messageIndex] = _messages[messageIndex].copyWith(
              isDeleted: true,
              content: 'This message has been deleted',
            );
            notifyListeners();
            debugPrint('Message $messageId deleted');
          }
        });
  }

  Future<void> _requestPresenceState() async {
    if (conversationController.conversation == null) return;
    debugPrint('Waiting for presence state from server...');
  }

  Future<void> initialize() async {
    if (conversationController.conversation == null) {
      await conversationController.loadConversation();
    }

    if (conversationController.conversation != null) {
      await _connectWebSocket();
    }
  }

  Future<void> _connectWebSocket() async {
    if (conversationController.conversation == null) return;

    try {
      final token = await _storageService.getToken();
      if (token != null) {
        await _chatSocketService.connect({
          'coupleId': conversationController.conversation!.coupleId,
          'token': token,
        });

        await _requestPresenceState();

        debugPrint('WebSocket connected, settings listener is active');
      }
    } catch (e) {
      debugPrint('Failed to connect WebSocket: $e');
    }
  }

  Future<void> fetchMessages({bool loadMore = false}) async {
    if (conversationController.conversation == null) {
      await initialize();
      if (conversationController.conversation == null) return;
    }

    if (loadMore) {
      if (!_hasMoreMessages || _isLoadingMore) return;
      _isLoadingMore = true;
    } else {
      _isLoading = true;
      _messages.clear();
      _hasMoreMessages = true;
    }

    _errorMessage = null;
    notifyListeners();

    try {
      final conversation = conversationController.conversation!;
      final beforeId = loadMore && _messages.isNotEmpty
          ? _messages.first.id
          : null;

      final response = await _repository.getMessagesPaginated(
        coupleId: conversation.coupleId,
        limit: 20,
        beforeId: beforeId,
      );

      if (response.success && response.data != null) {
        final newMessages = response.data!.map((msg) {
          final isMe = msg.senderId == _currentUserId;
          return msg.copyWith(
            senderName: isMe
                ? (yourName ?? conversation.yourName)
                : (partnerName ?? conversation.partnerName),
            senderAvatar: isMe
                ? (yourAvatar ?? conversation.yourAvatar)
                : (partnerAvatar ?? conversation.partnerAvatar),
          );
        }).toList();

        if (loadMore) {
          _messages.insertAll(0, newMessages);
        } else {
          _messages = newMessages;
        }

        // Nếu số message nhận được ít hơn limit -> không còn message nào
        if (newMessages.length < 20) {
          _hasMoreMessages = false;
        }

        _errorMessage = null;
        notifyListeners();

        if (_isScreenVisible && !loadMore) {
          await markMessagesAsRead();
        }

        if (_messages.isNotEmpty && !loadMore) {
          conversationController.updateLastMessage(_messages.last);
        }
      } else {
        _errorMessage = response.message ?? 'Failed to load messages';
      }
    } catch (e) {
      _errorMessage = 'An error occurred. Please try again.';
    } finally {
      if (loadMore) {
        _isLoadingMore = false;
      } else {
        _isLoading = false;
      }
      notifyListeners();
    }
  }

  Future<bool> sendMessage(String content) async {
    if (content.trim().isEmpty ||
        conversationController.conversation == null ||
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

  Future<void> sendImageMessages() async {
    if (conversationController.conversation == null ||
        !_chatSocketService.isConnected) {
      return;
    }

    _isSending = true;
    notifyListeners();

    try {
      final conversation = conversationController.conversation!;
      final responses = await _imageUploadService
          .pickAndUploadMultipleChatImages(conversation.coupleId);

      for (final res in responses) {
        _sendImagePayload(res);
      }
    } catch (e) {
      _errorMessage = 'Failed to send images';
    } finally {
      _isSending = false;
      notifyListeners();
    }
  }

  Future<void> sendImagesFromGallery() async {
    if (conversationController.conversation == null ||
        !_chatSocketService.isConnected) {
      return;
    }

    _isSending = true;
    notifyListeners();

    try {
      final conversation = conversationController.conversation!;
      final responses = await _imageUploadService
          .pickAndUploadMultipleChatImages(conversation.coupleId);

      for (final res in responses) {
        _sendImagePayload(res);
      }
    } catch (e) {
      debugPrint('Error sending gallery images: $e');
    } finally {
      _isSending = false;
      notifyListeners();
    }
  }

  Future<void> sendImageFromCamera() async {
    if (conversationController.conversation == null ||
        !_chatSocketService.isConnected) {
      return;
    }

    _isSending = true;
    notifyListeners();

    try {
      final conversation = conversationController.conversation!;
      final response = await _imageUploadService.takePhotoAndUploadChatImage(
        conversation.coupleId,
      );

      if (response != null) {
        _sendImagePayload(response);
      }
    } catch (e) {
      debugPrint('Error sending camera image: $e');
    } finally {
      _isSending = false;
      notifyListeners();
    }
  }

  Future<bool> updateMessage(int messageId, String newContent) async {
    if (newContent.trim().isEmpty) return false;

    try {
      // Optimistic update
      final messageIndex = _messages.indexWhere((m) => m.id == messageId);
      if (messageIndex == -1) return false;

      final oldMessage = _messages[messageIndex];
      _messages[messageIndex] = oldMessage.copyWith(
        content: newContent.trim(),
        editedAt: DateTime.now(),
      );
      notifyListeners();

      final response = await _repository.updateMessage(
        messageId: messageId,
        content: newContent.trim(),
      );

      if (!response.success) {
        // Rollback on failure
        _messages[messageIndex] = oldMessage;
        notifyListeners();
        _errorMessage = response.message ?? 'Failed to update message';
        return false;
      }

      return true;
    } catch (e) {
      _errorMessage = 'Failed to update message: $e';
      return false;
    }
  }

  Future<bool> deleteMessage(int messageId) async {
    try {
      // Optimistic update
      final messageIndex = _messages.indexWhere((m) => m.id == messageId);
      if (messageIndex == -1) return false;

      final oldMessage = _messages[messageIndex];
      _messages[messageIndex] = oldMessage.copyWith(
        isDeleted: true,
        content: 'This message has been deleted',
      );
      notifyListeners();

      final response = await _repository.deleteMessage(messageId: messageId);

      if (!response.success) {
        // Rollback on failure
        _messages[messageIndex] = oldMessage;
        notifyListeners();
        _errorMessage = response.message ?? 'Failed to delete message';
        return false;
      }

      return true;
    } catch (e) {
      _errorMessage = 'Failed to delete message: $e';
      return false;
    }
  }

  void _sendImagePayload(CloudinaryUploadResponse res) {
    final thumbUrl = res.secureUrl.replaceFirst(
      '/upload/',
      '/upload/w_300,h_300,c_fill/',
    );

    _chatSocketService.sendMessage(
      '',
      type: 'image',
      imgUrl: res.secureUrl,
      thumbnailUrl: thumbUrl,
    );
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

    debugPrint(
      'Received reaction event: userId=${reaction.userId}, emoji=${reaction.emoji}',
    );

    if (reaction.emoji == null) {
      currentReactions.remove(reaction.userId);
      debugPrint('Removed reaction for user ${reaction.userId}');
    } else {
      currentReactions[reaction.userId] = reaction.emoji!;
      debugPrint(
        'Added/Updated reaction for user ${reaction.userId}: ${reaction.emoji}',
      );
    }

    _messages[messageIndex] = message.copyWith(
      reactionsByUserId: currentReactions.isEmpty ? null : currentReactions,
    );

    notifyListeners();
    debugPrint(
      'Reaction event processed: message ${reaction.messageId}, user ${reaction.userId}, emoji: ${reaction.emoji}',
    );
  }

  Future<bool> reactToMessage(int messageId, String? emoji) async {
    if (_currentUserId == null) return false;

    try {
      final messageIndex = _messages.indexWhere((m) => m.id == messageId);
      if (messageIndex == -1) return false;

      final message = _messages[messageIndex];
      final currentReactions = Map<int, String>.from(
        message.reactionsByUserId ?? {},
      );
      final existingEmoji = currentReactions[_currentUserId!];

      debugPrint('Current emoji for user $_currentUserId: $existingEmoji');
      debugPrint('New emoji: $emoji');

      String? emojiToSend;
      Map<int, String>? newReactions;

      if (existingEmoji == emoji) {
        debugPrint('Removing reaction');
        currentReactions.remove(_currentUserId!);
        emojiToSend = null;
        newReactions = {};
      } else {
        debugPrint('Adding/Updating reaction');
        currentReactions[_currentUserId!] = emoji!;
        emojiToSend = emoji;
        newReactions = currentReactions;
      }

      // Optimistic update với state mới
      final oldMessage = message;
      _messages[messageIndex] = message.copyWith(
        reactionsByUserId: newReactions,
      );

      debugPrint('Optimistic update: newReactions = $newReactions');
      notifyListeners();

      debugPrint('Sending to server: emoji=$emojiToSend');

      // Gửi request đến server
      final response = await _repository.reactToMessage(messageId, emojiToSend);

      if (!response.success) {
        debugPrint('Server request failed, rolling back');
        _messages[messageIndex] = oldMessage;
        notifyListeners();
        _errorMessage = response.message ?? 'Failed to react';
        return false;
      }

      debugPrint('Reaction updated successfully');
      return true;
    } catch (e) {
      debugPrint('Error in reactToMessage: $e');
      _errorMessage = 'Failed to react: $e';
      return false;
    }
  }

  Future<void> refreshMessages() async {
    await fetchMessages();
  }

  Future<void> markMessagesAsRead() async {
    if (conversationController.conversation == null || _messages.isEmpty) {
      return;
    }

    try {
      final partnerMessages = _messages
          .where((msg) => msg.senderId != _currentUserId)
          .toList();

      if (partnerMessages.isEmpty) return;

      final lastMessageId = partnerMessages.last.id;
      final coupleId = conversationController.conversation!.coupleId;

      final response = await _repository.markMessagesAsRead(
        coupleId: coupleId,
        lastMessageId: lastMessageId,
      );

      if (response.success) {
        for (int i = 0; i < _messages.length; i++) {
          if (_messages[i].senderId != _currentUserId &&
              _messages[i].id <= lastMessageId) {
            _messages[i] = _messages[i].copyWith(
              isRead: true,
              readAt: DateTime.now(),
            );
          }
        }
        notifyListeners();

        debugPrint('Messages marked as read up to ID: $lastMessageId');
      }
    } catch (e) {
      debugPrint('Failed to mark messages as read: $e');
    }
  }

  Future<void> _markNewMessagesAsRead() async {
    debugPrint('conversation: ${conversationController.conversation != null}');

    if (!_isScreenVisible) {
      debugPrint('Screen NOT visible, skipping mark as read');
      return;
    }

    if (conversationController.conversation == null || _messages.isEmpty) {
      debugPrint('No conversation or messages, skipping');
      return;
    }

    final unreadMessages = _messages
        .where((msg) => msg.senderId != _currentUserId && !msg.isRead)
        .toList();

    if (unreadMessages.isEmpty) {
      debugPrint('No unread messages');
      return;
    }

    final lastUnreadId = unreadMessages.last.id;

    try {
      debugPrint('Marking messages as read up to ID: $lastUnreadId');
      await markMessagesAsRead();
      debugPrint('Successfully marked as read');
    } catch (e) {
      debugPrint('Failed to auto-mark messages: $e');
    }
  }

  // Lifecycle methods
  void onScreenVisible() {
    debugPrint('ChatController: Screen VISIBLE');
    _isScreenVisible = true;

    // Mark as read khi vào screen
    if (_messages.isNotEmpty) {
      _markNewMessagesAsRead();
    }
  }

  void onScreenHidden() {
    debugPrint('ChatController: Screen HIDDEN');
    _isScreenVisible = false;
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    debugPrint('ChatController: DISPOSING');
    _presenceSubscription?.cancel();
    _reactionSubscription?.cancel();
    _readReceiptSubscription?.cancel();
    _messageUpdatedSubscription?.cancel();
    _messageDeletedSubscription?.cancel();
    _chatSocketService.dispose();
    super.dispose();
  }
}
