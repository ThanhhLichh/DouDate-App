import 'package:flutter/material.dart';

// Conversation Settings Model
class ConversationSettings {
  final int conversationId;
  final String bubbleColor;
  final String quickEmoji;
  final String? yourNickname;
  final String? partnerNickname;
  final BackgroundTheme backgroundTheme;

  ConversationSettings({
    required this.conversationId,
    this.bubbleColor = '#0084FF',
    this.quickEmoji = '👍',
    this.yourNickname,
    this.partnerNickname,
    this.backgroundTheme = BackgroundTheme.defaultTheme,
  });

  factory ConversationSettings.fromJson(Map<String, dynamic> json) {
    return ConversationSettings(
      conversationId: json['couple_id'] ?? 0,
      bubbleColor: json['bubble_color'] ?? '#0084FF',
      quickEmoji: json['quick_emoji'] ?? '👍',
      yourNickname: json['your_nickname'],
      partnerNickname: json['partner_nickname'],
      backgroundTheme: BackgroundTheme.values.firstWhere(
        (e) => e.name == json['background_theme'],
        orElse: () => BackgroundTheme.defaultTheme,
      ),
    );
  }

  Map<String, dynamic> toJson() => {
    'couple_id': conversationId,
    'bubble_color': bubbleColor,
    'quick_emoji': quickEmoji,
    'your_nickname': yourNickname,
    'partner_nickname': partnerNickname,
    'background_theme': backgroundTheme.name,
  };

  ConversationSettings copyWith({
    int? conversationId,
    String? bubbleColor,
    String? quickEmoji,
    String? yourNickname,
    String? partnerNickname,
    BackgroundTheme? backgroundTheme,
  }) {
    return ConversationSettings(
      conversationId: conversationId ?? this.conversationId,
      bubbleColor: bubbleColor ?? this.bubbleColor,
      quickEmoji: quickEmoji ?? this.quickEmoji,
      yourNickname: yourNickname ?? this.yourNickname,
      partnerNickname: partnerNickname ?? this.partnerNickname,
      backgroundTheme: backgroundTheme ?? this.backgroundTheme,
    );
  }
}

// Background Theme Options
enum BackgroundTheme {
  defaultTheme,
  gradient1,
  gradient2,
  gradient3,
  pattern1,
  pattern2,
  dark,
}

extension BackgroundThemeExtension on BackgroundTheme {
  String get name {
    switch (this) {
      case BackgroundTheme.defaultTheme:
        return 'default';
      case BackgroundTheme.gradient1:
        return 'gradient1';
      case BackgroundTheme.gradient2:
        return 'gradient2';
      case BackgroundTheme.gradient3:
        return 'gradient3';
      case BackgroundTheme.pattern1:
        return 'pattern1';
      case BackgroundTheme.pattern2:
        return 'pattern2';
      case BackgroundTheme.dark:
        return 'dark';
    }
  }

  String get displayName {
    switch (this) {
      case BackgroundTheme.defaultTheme:
        return 'Default';
      case BackgroundTheme.gradient1:
        return 'Purple Dream';
      case BackgroundTheme.gradient2:
        return 'Ocean Blue';
      case BackgroundTheme.gradient3:
        return 'Sunset';
      case BackgroundTheme.pattern1:
        return 'Hearts';
      case BackgroundTheme.pattern2:
        return 'Bubbles';
      case BackgroundTheme.dark:
        return 'Dark Mode';
    }
  }

  // Background decoration for chat page
  BoxDecoration get decoration {
    switch (this) {
      case BackgroundTheme.defaultTheme:
        return const BoxDecoration(color: Colors.white);
      case BackgroundTheme.gradient1:
        return const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFE0C3FC), Color(0xFF8EC5FC)],
          ),
        );
      case BackgroundTheme.gradient2:
        return const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF89F7FE), Color(0xFF66A6FF)],
          ),
        );
      case BackgroundTheme.gradient3:
        return const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFFA751), Color(0xFFFFE259)],
          ),
        );
      case BackgroundTheme.pattern1:
        return BoxDecoration(
          color: const Color(0xFFFFF0F5),
          image: DecorationImage(
            image: const AssetImage('assets/images/pattern_hearts.jpg'),
            repeat: ImageRepeat.repeat,
            opacity: 0.1,
            fit: BoxFit.none,
          ),
        );
      case BackgroundTheme.pattern2:
        return BoxDecoration(
          color: const Color(0xFFF0F8FF),
          image: DecorationImage(
            image: const AssetImage('assets/images/pattern_bubbles.jpg'),
            repeat: ImageRepeat.repeat,
            opacity: 0.1,
            fit: BoxFit.none,
          ),
        );
      case BackgroundTheme.dark:
        return const BoxDecoration(color: Color(0xFF1C1C1E));
    }
  }

  // Recommended bubble color for this background
  String get recommendedBubbleColor {
    switch (this) {
      case BackgroundTheme.defaultTheme:
        return '#0084FF';
      case BackgroundTheme.gradient1:
        return '#6B4CE8';
      case BackgroundTheme.gradient2:
        return '#0084FF';
      case BackgroundTheme.gradient3:
        return '#FF6B35';
      case BackgroundTheme.pattern1:
        return '#FF1493';
      case BackgroundTheme.pattern2:
        return '#00CED1';
      case BackgroundTheme.dark:
        return '#0A84FF';
    }
  }

  // Preview gradient for selection UI
  Gradient get previewGradient {
    switch (this) {
      case BackgroundTheme.defaultTheme:
        return const LinearGradient(colors: [Colors.white, Colors.white]);
      case BackgroundTheme.gradient1:
        return const LinearGradient(
          colors: [Color(0xFFE0C3FC), Color(0xFF8EC5FC)],
        );
      case BackgroundTheme.gradient2:
        return const LinearGradient(
          colors: [Color(0xFF89F7FE), Color(0xFF66A6FF)],
        );
      case BackgroundTheme.gradient3:
        return const LinearGradient(
          colors: [Color(0xFFFFA751), Color(0xFFFFE259)],
        );
      case BackgroundTheme.pattern1:
        return const LinearGradient(
          colors: [Color(0xFFFFF0F5), Color(0xFFFFF0F5)],
        );
      case BackgroundTheme.pattern2:
        return const LinearGradient(
          colors: [Color(0xFFF0F8FF), Color(0xFFF0F8FF)],
        );
      case BackgroundTheme.dark:
        return const LinearGradient(
          colors: [Color(0xFF1C1C1E), Color(0xFF1C1C1E)],
        );
    }
  }
}

// Available bubble colors
class BubbleColorOption {
  final String name;
  final String hexColor;

  const BubbleColorOption({required this.name, required this.hexColor});

  static const List<BubbleColorOption> options = [
    BubbleColorOption(name: 'Blue', hexColor: '#0084FF'),
    BubbleColorOption(name: 'Purple', hexColor: '#A033FF'),
    BubbleColorOption(name: 'Pink', hexColor: '#FF5CA1'),
    BubbleColorOption(name: 'Red', hexColor: '#FA3C4C'),
    BubbleColorOption(name: 'Orange', hexColor: '#FF7A00'),
    BubbleColorOption(name: 'Green', hexColor: '#00C851'),
    BubbleColorOption(name: 'Teal', hexColor: '#00D9D9'),
  ];
}

// Media item for gallery view
class MediaItem {
  final String id;
  final String url;
  final MediaType type;
  final DateTime timestamp;
  final String? thumbnailUrl;

  MediaItem({
    required this.id,
    required this.url,
    required this.type,
    required this.timestamp,
    this.thumbnailUrl,
  });

  factory MediaItem.fromJson(Map<String, dynamic> json) {
    return MediaItem(
      id: json['id'] ?? '',
      url: json['url'] ?? '',
      type: MediaType.values.firstWhere(
        (e) => e.toString() == 'MediaType.${json['type']}',
        orElse: () => MediaType.image,
      ),
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'])
          : DateTime.now(),
      thumbnailUrl: json['thumbnail_url'],
    );
  }
}

enum MediaType { image, video }
