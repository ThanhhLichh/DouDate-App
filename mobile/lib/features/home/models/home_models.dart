class CoupleDashboard {
  final int coupleId;
  final String partnerName;
  final String? partnerAvatar;
  final String yourName;
  final String? yourAvatar;
  final DateTime startDate;
  final int messageCount;
  final int momentCount;
  final int memoryCount;
  final String todayQuote;

  CoupleDashboard({
    required this.coupleId,
    required this.partnerName,
    this.partnerAvatar,
    required this.yourName,
    this.yourAvatar,
    required this.startDate,
    this.messageCount = 0,
    this.momentCount = 0,
    this.memoryCount = 0,
    this.todayQuote = "Every day with you feels like a gift.",
  });

  // Tính số ngày yêu nhau
  int get daysTogether => DateTime.now().difference(startDate).inDays;

  factory CoupleDashboard.fromJson(Map<String, dynamic> json) {
    return CoupleDashboard(
      coupleId: json['couple_id'] ?? 0,
      partnerName: json['partner_name'] ?? '',
      partnerAvatar: json['partner_avatar'],
      yourName: json['your_name'] ?? '',
      yourAvatar: json['your_avatar'],
      startDate: DateTime.parse(json['start_date']),
      messageCount: json['message_count'] ?? 0,
      momentCount: json['moment_count'] ?? 0,
      memoryCount: json['memory_count'] ?? 0,
      todayQuote:
          json['today_quote'] ?? "Every day with you feels like a gift.",
    );
  }

  Map<String, dynamic> toJson() => {
    'couple_id': coupleId,
    'partner_name': partnerName,
    'partner_avatar': partnerAvatar,
    'your_name': yourName,
    'your_avatar': yourAvatar,
    'start_date': startDate.toIso8601String(),
    'message_count': messageCount,
    'moment_count': momentCount,
    'memory_count': memoryCount,
    'today_quote': todayQuote,
  };
}
