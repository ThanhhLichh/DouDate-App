class Memory {
  final int id;
  final int coupleId;
  final int createdBy;
  final String title;
  final String description;
  final String imageUrl;
  final DateTime memoryDate;
  final DateTime createdAt;

  Memory({
    required this.id,
    required this.coupleId,
    required this.createdBy,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.memoryDate,
    required this.createdAt,
  });

  factory Memory.fromJson(Map<String, dynamic> json) {
    return Memory(
      id: json['id'] ?? 0,
      coupleId: json['couple_id'] ?? 0,
      createdBy: json['created_by'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      imageUrl: json['image_url'] ?? '',
      memoryDate: DateTime.parse(json['memory_date'] ?? json['created_at']),
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'couple_id': coupleId,
    'created_by': createdBy,
    'title': title,
    'description': description,
    'image_url': imageUrl,
    'memory_date': memoryDate.toIso8601String().split('T')[0],
    'created_at': createdAt.toIso8601String(),
  };
}

class CreateMemoryRequest {
  final String title;
  final String description;
  final String imageUrl;
  final DateTime memoryDate;

  CreateMemoryRequest({
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.memoryDate,
  });

  Map<String, dynamic> toJson() => {
    'title': title,
    'description': description,
    'image_url': imageUrl,
    'memory_date': memoryDate.toIso8601String().split('T')[0],
  };
}

class UpdateMemoryRequest {
  final String title;
  final String description;
  final String? imageUrl;
  final DateTime memoryDate;

  UpdateMemoryRequest({
    required this.title,
    required this.description,
    this.imageUrl,
    required this.memoryDate,
  });

  Map<String, dynamic> toJson() {
    final data = {
      'title': title,
      'description': description,
      'memory_date': memoryDate.toIso8601String().split('T')[0],
    };

    if (imageUrl != null) {
      data['image_url'] = imageUrl!;
    }

    return data;
  }
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
