// 1. ENUMS
enum MessageType { text, image, sticker, voice, video }

/// 2. MESSAGE MODEL
class Message {
  final int id;
  final int coupleId;
  final int senderId;
  final String content;
  final MessageType type;
  final String? imgUrl;
  final String? thumbnailUrl;
  final DateTime createdAt;
  final Map<int, String>? reactionsByUserId;

  // UI Fields (Not from DB)
  final String? senderName;
  final String? senderAvatar;
  final bool isRead;
  final DateTime? readAt;

  Message({
    required this.id,
    required this.coupleId,
    required this.senderId,
    required this.content,
    required this.type,
    required this.createdAt,
    this.imgUrl,
    this.thumbnailUrl,
    this.senderName,
    this.senderAvatar,
    this.isRead = true,
    this.reactionsByUserId,
    this.readAt,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] ?? 0,
      coupleId: json['couple_id'] ?? 0,
      senderId: json['sender_id'] ?? 0,
      content: json['content'] ?? '',
      imgUrl: json['img_url'],
      thumbnailUrl: json['thumbnail_url'],
      type: json['type'] == 'image' ? MessageType.image : MessageType.text,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      isRead: json['is_read'] ?? false,
      reactionsByUserId: json['reactions'] != null
          ? {
              for (var r in (json['reactions'] as List))
                r['user_id'] as int: r['emoji'] as String,
            }
          : null,
      readAt: json['read_at'] != null ? DateTime.parse(json['read_at']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'couple_id': coupleId,
    'sender_id': senderId,
    'content': content,
    'type': type.name,
    'img_url': imgUrl,
    'thumbnail_url': thumbnailUrl,
  };

  Message copyWith({
    int? id,
    int? coupleId,
    int? senderId,
    String? content,
    MessageType? type,
    String? imgUrl,
    String? thumbnailUrl,
    DateTime? createdAt,
    Map<int, String>? reactionsByUserId,
    String? senderName,
    String? senderAvatar,
    bool? isRead,
    DateTime? readAt,
  }) {
    return Message(
      id: id ?? this.id,
      coupleId: coupleId ?? this.coupleId,
      senderId: senderId ?? this.senderId,
      content: content ?? this.content,
      type: type ?? this.type,
      imgUrl: imgUrl ?? this.imgUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      createdAt: createdAt ?? this.createdAt,
      reactionsByUserId: reactionsByUserId ?? this.reactionsByUserId,
      senderName: senderName ?? this.senderName,
      senderAvatar: senderAvatar ?? this.senderAvatar,
      isRead: isRead ?? this.isRead,
      readAt: readAt ?? this.readAt,
    );
  }

  // --- Helpers ---
  String get conversationId => coupleId.toString();
  DateTime get timestamp => createdAt;
  List<String> get reactions => reactionsByUserId?.values.toList() ?? [];
  String? getReactionByUser(int userId) => reactionsByUserId?[userId];
  bool hasReactionFromUser(int userId) =>
      reactionsByUserId?.containsKey(userId) ?? false;
}

/// 3. REACTION MODELS
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
      messageId: json['message_id'] ?? 0,
      userId: json['user_id'] ?? 0,
      emoji: json['emoji'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
    );
  }

  factory MessageReaction.fromWebSocket(Map<String, dynamic> json) {
    return MessageReaction(
      messageId: json['message_id'] ?? 0,
      userId: json['user_id'] ?? 0,
      emoji: json['emoji'],
    );
  }
}

class ReactionRequest {
  final String? emoji;
  ReactionRequest({this.emoji});
  Map<String, dynamic> toJson() => {'emoji': emoji};
}

/// 4. CONVERSATION MODEL
class Conversation {
  final int coupleId;
  final String yourName;
  final String? yourAvatar;
  final String partnerName;
  final String? partnerAvatar;
  final DateTime startDate;
  final int messageCount;

  // UI Fields
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

  int get id => coupleId;

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
