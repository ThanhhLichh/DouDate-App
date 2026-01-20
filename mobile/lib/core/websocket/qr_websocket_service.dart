import 'dart:convert';
import 'dart:async';
import '../config/api_config.dart';
import '../../features/home/models/qr_scan_models.dart';
import 'base_websocket_manager.dart';

class QRWebSocketService extends BaseWebSocketManager {
  // Stream controllers cho các events
  final _scannedController = StreamController<QRScannedEvent>.broadcast();
  final _acceptedController = StreamController<QRAcceptedEvent>.broadcast();
  final _rejectedController = StreamController<QRRejectedEvent>.broadcast();

  bool _isDisposed = false;

  // Public streams
  Stream<QRScannedEvent> get scannedStream => _scannedController.stream;
  Stream<QRAcceptedEvent> get acceptedStream => _acceptedController.stream;
  Stream<QRRejectedEvent> get rejectedStream => _rejectedController.stream;

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
      final event = data['event'] as String?;

      if (event == null) {
        print('QR WebSocket: Received message without event type');
        return;
      }

      print('QR WebSocket event received: $event');

      switch (event) {
        case 'QR_SCANNED':
          final scannedEvent = QRScannedEvent.fromJson(data);
          _scannedController.add(scannedEvent);
          break;

        case 'CONNECTION_ACCEPTED':
          final acceptedEvent = QRAcceptedEvent.fromJson(data);
          _acceptedController.add(acceptedEvent);
          break;

        case 'CONNECTION_REJECTED':
          final rejectedEvent = QRRejectedEvent.fromJson(data);
          _rejectedController.add(rejectedEvent);
          break;

        default:
          print('QR WebSocket: Unknown event type: $event');
      }
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
    _scannedController.close();
    _acceptedController.close();
    _rejectedController.close();
    super.dispose();
  }
}
