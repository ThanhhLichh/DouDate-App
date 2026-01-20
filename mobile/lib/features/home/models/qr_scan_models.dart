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

// ========== WebSocket Events ==========

// QR Scanned Event (when someone scans your QR)
class QRScannedEvent {
  final String event;
  final int fromUserId;

  QRScannedEvent({required this.event, required this.fromUserId});

  factory QRScannedEvent.fromJson(Map<String, dynamic> json) {
    return QRScannedEvent(
      event: json['event'],
      fromUserId: json['from_user_id'],
    );
  }
}

// QR Accepted Event
class QRAcceptedEvent {
  final String event;
  final QRAcceptedData data;

  QRAcceptedEvent({required this.event, required this.data});

  factory QRAcceptedEvent.fromJson(Map<String, dynamic> json) {
    return QRAcceptedEvent(
      event: json['event'],
      data: QRAcceptedData.fromJson(json['data']),
    );
  }
}

class QRAcceptedData {
  final int partnerId;
  final String? partnerName;
  final int coupleId;
  final DateTime startDate;

  QRAcceptedData({
    required this.partnerId,
    required this.partnerName,
    required this.coupleId,
    required this.startDate,
  });

  factory QRAcceptedData.fromJson(Map<String, dynamic> json) {
    return QRAcceptedData(
      partnerId: json['partner_id'],
      partnerName: json['partner_name'],
      coupleId: json['couple_id'],
      startDate: DateTime.parse(json['start_date']),
    );
  }
}

// QR Rejected Event
class QRRejectedEvent {
  final String event;
  final QRRejectedData data;

  QRRejectedEvent({required this.event, required this.data});

  factory QRRejectedEvent.fromJson(Map<String, dynamic> json) {
    return QRRejectedEvent(
      event: json['event'],
      data: QRRejectedData.fromJson(json['data']),
    );
  }
}

class QRRejectedData {
  final String message;
  final int byUserId;

  QRRejectedData({required this.message, required this.byUserId});

  factory QRRejectedData.fromJson(Map<String, dynamic> json) {
    return QRRejectedData(
      message: json['message'],
      byUserId: json['by_user_id'],
    );
  }
}
