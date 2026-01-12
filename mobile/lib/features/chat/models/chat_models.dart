// Message Model
class Message {
  final int id;
  final int coupleId;
  final int senderId;
  final String content;
  final DateTime createdAt;

  // UI fields
  final String? senderName;
  final String? senderAvatar;
  final bool isRead;
  final List<String>? reactions;

  Message({
    required this.id,
    required this.coupleId,
    required this.senderId,
    required this.content,
    required this.createdAt,
    this.senderName,
    this.senderAvatar,
    this.isRead = true,
    this.reactions,
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
      reactions: json['reactions'] != null
          ? List<String>.from(json['reactions'])
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
    List<String>? reactions,
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
      reactions: reactions ?? this.reactions,
    );
  }
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
