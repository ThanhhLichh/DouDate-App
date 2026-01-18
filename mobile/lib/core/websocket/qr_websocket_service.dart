import 'dart:convert';
import '../config/api_config.dart';
import '../../features/home/models/qr_scan_models.dart';
import 'base_websocket_manager.dart';
import 'dart:async';

class QRWebSocketService extends BaseWebSocketManager {
  StreamController<QRWebSocketEvent>? _eventController;
  bool _isDisposed = false;

  Stream<QRWebSocketEvent>? get eventStream => _eventController?.stream;

  QRWebSocketService() {
    _eventController = StreamController<QRWebSocketEvent>.broadcast();
  }

  @override
  String getWebSocketUrl(dynamic params) {
    final token = params as String;
    final wsUrl = ApiConfig.wsUrl
        .replaceFirst('http://', 'ws://')
        .replaceFirst('https://', 'wss://');
    return '$wsUrl${ApiConfig.qrStatusWebSocket}?token=$token';
  }

  @override
  void onMessage(dynamic message) {
    if (_isDisposed) return;
    try {
      final data = jsonDecode(message);
      final event = QRWebSocketEvent.fromJson(data);
      _eventController?.add(event);
      print('QR WebSocket event received: ${event.event}');
    } catch (e) {
      print('Error parsing QR WebSocket message: $e');
    }
  }

  @override
  void onConnectionStateChanged(bool isConnected) {
    print('QR WebSocket connection state: $isConnected');
  }

  @override
  void dispose() {
    _isDisposed = true;
    _eventController?.close();
    _eventController = null;
    super.dispose();
  }
}
