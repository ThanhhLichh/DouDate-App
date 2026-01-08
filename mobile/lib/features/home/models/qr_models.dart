class QRCodeData {
  final String token;
  final DateTime expiresAt;

  QRCodeData({required this.token, required this.expiresAt});

  factory QRCodeData.fromJson(Map<String, dynamic> json) {
    // Parse UTC time from backend và convert sang local time (+7)
    final utcTime = DateTime.parse(json['expires_at']);
    final localTime = utcTime.add(const Duration(hours: 7));

    return QRCodeData(token: json['token'], expiresAt: localTime);
  }

  // Check if QR code is still valid
  bool get isExpired => DateTime.now().isAfter(expiresAt);

  // Get remaining time in seconds
  int get remainingSeconds {
    final now = DateTime.now();
    if (now.isAfter(expiresAt)) return 0;
    return expiresAt.difference(now).inSeconds;
  }

  // Format remaining time as MM:SS
  String get formattedRemainingTime {
    final seconds = remainingSeconds;
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }
}
