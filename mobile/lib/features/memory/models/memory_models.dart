class Memory {
  final String id;
  final String userId;
  final String title;
  final String description;
  final String imageUrl;
  final DateTime createdAt;
  final List<String>? tags;

  Memory({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.createdAt,
    this.tags,
  });

  factory Memory.fromJson(Map<String, dynamic> json) {
    return Memory(
      id: json['id'] ?? json['_id'] ?? '',
      userId: json['user_id'] ?? json['userId'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      imageUrl: json['image_url'] ?? json['imageUrl'] ?? '',
      createdAt: DateTime.parse(json['created_at'] ?? json['createdAt']),
      tags: json['tags'] != null ? List<String>.from(json['tags']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'title': title,
    'description': description,
    'image_url': imageUrl,
    'created_at': createdAt.toIso8601String(),
    if (tags != null) 'tags': tags,
  };
}

class CreateMemoryRequest {
  final String title;
  final String description;
  final String imageBase64;
  final List<String>? tags;

  CreateMemoryRequest({
    required this.title,
    required this.description,
    required this.imageBase64,
    this.tags,
  });

  Map<String, dynamic> toJson() => {
    'title': title,
    'description': description,
    'image_base64': imageBase64,
    if (tags != null) 'tags': tags,
  };
}

class MemoryReminder {
  final String memoryId;
  final String title;
  final DateTime originalDate;
  final DateTime reminderDate;

  MemoryReminder({
    required this.memoryId,
    required this.title,
    required this.originalDate,
    required this.reminderDate,
  });

  factory MemoryReminder.fromJson(Map<String, dynamic> json) {
    return MemoryReminder(
      memoryId: json['memory_id'] ?? '',
      title: json['title'] ?? '',
      originalDate: DateTime.parse(json['original_date']),
      reminderDate: DateTime.parse(json['reminder_date']),
    );
  }

  Map<String, dynamic> toJson() => {
    'memory_id': memoryId,
    'title': title,
    'original_date': originalDate.toIso8601String(),
    'reminder_date': reminderDate.toIso8601String(),
  };
}
