// Message Model
class Message {
  final int id;
  final int coupleId;
  final int senderId;
  final String content;
  final DateTime createdAt;
  final Map<int, String>? reactionsByUserId;

  // UI fields
  final String? senderName;
  final String? senderAvatar;
  final bool isRead;

  Message({
    required this.id,
    required this.coupleId,
    required this.senderId,
    required this.content,
    required this.createdAt,
    this.senderName,
    this.senderAvatar,
    this.isRead = true,
    this.reactionsByUserId,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] ?? 0,
      coupleId: json['couple_id'] ?? 0,
      senderId: json['sender_id'] ?? 0,
      content: json['content'] ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      isRead: json['is_read'] ?? true,
      reactionsByUserId: json['reactions'] != null
          ? {
              for (var r in (json['reactions'] as List))
                r['user_id'] as int: r['emoji'] as String,
            }
          : null,
    );
  }

  Map<String, dynamic> toJson() => {'couple_id': coupleId, 'content': content};

  // Backward compatible getters
  String get conversationId => coupleId.toString();
  DateTime get timestamp => createdAt;
  MessageType get type => MessageType.text;

  Message copyWith({
    int? id,
    int? coupleId,
    int? senderId,
    String? senderName,
    String? senderAvatar,
    String? content,
    DateTime? createdAt,
    bool? isRead,
    Map<int, String>? reactionsByUserId,
  }) {
    return Message(
      id: id ?? this.id,
      coupleId: coupleId ?? this.coupleId,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      senderAvatar: senderAvatar ?? this.senderAvatar,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
      reactionsByUserId: reactionsByUserId ?? this.reactionsByUserId,
    );
  }

  // Helper getters
  List<String> get reactions => reactionsByUserId?.values.toList() ?? [];

  String? getReactionByUser(int userId) => reactionsByUserId?[userId];

  bool hasReactionFromUser(int userId) =>
      reactionsByUserId?.containsKey(userId) ?? false;
}

enum MessageType { text, image, sticker, voice, video }

// Conversation Model
class Conversation {
  final int coupleId;
  final String yourName;
  final String? yourAvatar;
  final String partnerName;
  final String? partnerAvatar;
  final DateTime startDate;
  final int messageCount;

  // UI fields
  final Message? lastMessage;
  final int unreadCount;
  final bool isOnline;
  final DateTime? lastSeen;

  Conversation({
    required this.coupleId,
    required this.yourName,
    this.yourAvatar,
    required this.partnerName,
    this.partnerAvatar,
    required this.startDate,
    required this.messageCount,
    this.lastMessage,
    this.unreadCount = 0,
    this.isOnline = false,
    this.lastSeen,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      coupleId: json['couple_id'] ?? 0,
      yourName: json['your_name'] ?? '',
      yourAvatar: json['your_avatar'],
      partnerName: json['partner_name'] ?? '',
      partnerAvatar: json['partner_avatar'],
      startDate: json['start_date'] != null
          ? DateTime.parse(json['start_date'])
          : DateTime.now(),
      messageCount: json['message_count'] ?? 0,
      unreadCount: json['unread_count'] ?? 0,
      isOnline: json['is_online'] ?? false,
    );
  }

  // Backward compatible getters
  int get id => coupleId;
  String get partnerId => ''; // Not needed for couple app

  Conversation copyWith({
    int? coupleId,
    String? yourName,
    String? yourAvatar,
    String? partnerName,
    String? partnerAvatar,
    DateTime? startDate,
    int? messageCount,
    Message? lastMessage,
    int? unreadCount,
    bool? isOnline,
    DateTime? lastSeen,
  }) {
    return Conversation(
      coupleId: coupleId ?? this.coupleId,
      yourName: yourName ?? this.yourName,
      yourAvatar: yourAvatar ?? this.yourAvatar,
      partnerName: partnerName ?? this.partnerName,
      partnerAvatar: partnerAvatar ?? this.partnerAvatar,
      startDate: startDate ?? this.startDate,
      messageCount: messageCount ?? this.messageCount,
      lastMessage: lastMessage ?? this.lastMessage,
      unreadCount: unreadCount ?? this.unreadCount,
      isOnline: isOnline ?? this.isOnline,
      lastSeen: lastSeen ?? this.lastSeen,
    );
  }
}

// Message Reaction Model
class MessageReaction {
  final int? id;
  final int messageId;
  final int userId;
  final String? emoji;
  final DateTime? createdAt;

  MessageReaction({
    this.id,
    required this.messageId,
    required this.userId,
    this.emoji,
    this.createdAt,
  });

  factory MessageReaction.fromJson(Map<String, dynamic> json) {
    return MessageReaction(
      id: json['id'],
      messageId: json['message_id'],
      userId: json['user_id'],
      emoji: json['emoji'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
    );
  }

  // Factory cho WebSocket event
  factory MessageReaction.fromWebSocket(Map<String, dynamic> json) {
    return MessageReaction(
      messageId: json['message_id'],
      userId: json['user_id'],
      emoji: json['emoji'],
    );
  }

  // Factory cho DB record
  // factory MessageReaction.fromDatabase(Map<String, dynamic> json) {
  //   return MessageReaction(
  //     id: json['id'],
  //     messageId: json['message_id'],
  //     userId: json['user_id'],
  //     emoji: json['emoji'],
  //     createdAt: DateTime.parse(json['created_at']),
  //   );
  // }
}

class ReactionRequest {
  final String? emoji;

  ReactionRequest({this.emoji});

  Map<String, dynamic> toJson() => {'emoji': emoji};
}
