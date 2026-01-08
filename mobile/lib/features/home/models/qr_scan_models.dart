// Scan QR Request
class ScanQRRequest {
  final String token;

  ScanQRRequest({required this.token});

  Map<String, dynamic> toJson() => {'token': token};
}

// Scan QR Response
class ScanQRResponse {
  final int fromUserId;
  final String fromUserName;
  final DateTime createdAt;
  final DateTime expiresAt;
  final String status;

  ScanQRResponse({
    required this.fromUserId,
    required this.fromUserName,
    required this.createdAt,
    required this.expiresAt,
    required this.status,
  });

  factory ScanQRResponse.fromJson(Map<String, dynamic> json) {
    return ScanQRResponse(
      fromUserId: json['from_user_id'],
      fromUserName: json['from_user_name'],
      createdAt: DateTime.parse(json['created_at']),
      expiresAt: DateTime.parse(json['expires_at']),
      status: json['status'],
    );
  }
}

// Respond QR Request
class RespondQRRequest {
  final String token;
  final String action; // "accept" or "reject"

  RespondQRRequest({required this.token, required this.action});

  Map<String, dynamic> toJson() => {'token': token, 'action': action};
}

// Couple Response
class CoupleResponse {
  final int id;
  final int user1Id;
  final int user2Id;
  final DateTime startDate;

  CoupleResponse({
    required this.id,
    required this.user1Id,
    required this.user2Id,
    required this.startDate,
  });

  factory CoupleResponse.fromJson(Map<String, dynamic> json) {
    return CoupleResponse(
      id: json['id'],
      user1Id: json['user1_id'],
      user2Id: json['user2_id'],
      startDate: DateTime.parse(json['start_date']),
    );
  }
}

// WebSocket Event
class QRWebSocketEvent {
  final String event;
  final int fromUserId;

  QRWebSocketEvent({required this.event, required this.fromUserId});

  factory QRWebSocketEvent.fromJson(Map<String, dynamic> json) {
    return QRWebSocketEvent(
      event: json['event'],
      fromUserId: json['from_user_id'],
    );
  }
}
