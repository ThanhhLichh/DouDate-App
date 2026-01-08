import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../config/api_config.dart';
import '../../features/home/models/qr_scan_models.dart';

class QRWebSocketService {
  WebSocketChannel? _channel;
  StreamController<QRWebSocketEvent>? _eventController;
  bool _isConnected = false;

  Stream<QRWebSocketEvent>? get eventStream => _eventController?.stream;
  bool get isConnected => _isConnected;

  // Connect to WebSocket
  Future<void> connect(String token) async {
    if (_isConnected) {
      print('WebSocket already connected');
      return;
    }

    try {
      final wsUrl =
          '${ApiConfig.wsUrl}${ApiConfig.qrStatusWebSocket}?token=$token';
      print('Connecting to WebSocket: $wsUrl');

      _channel = WebSocketChannel.connect(Uri.parse(wsUrl));
      _eventController = StreamController<QRWebSocketEvent>.broadcast();
      _isConnected = true;

      // Listen to incoming messages
      _channel!.stream.listen(
        (message) {
          try {
            final data = jsonDecode(message);
            final event = QRWebSocketEvent.fromJson(data);
            _eventController?.add(event);
            print('WebSocket event received: ${event.event}');
          } catch (e) {
            print('Error parsing WebSocket message: $e');
          }
        },
        onError: (error) {
          print('WebSocket error: $error');
          _handleDisconnect();
        },
        onDone: () {
          print('WebSocket connection closed');
          _handleDisconnect();
        },
      );

      print('WebSocket connected successfully');
    } catch (e) {
      print('Failed to connect WebSocket: $e');
      _handleDisconnect();
      rethrow;
    }
  }

  // Disconnect
  void disconnect() {
    print('Disconnecting WebSocket');
    _handleDisconnect();
  }

  void _handleDisconnect() {
    _isConnected = false;
    _channel?.sink.close();
    _channel = null;
    _eventController?.close();
    _eventController = null;
  }

  // Send ping to keep connection alive
  void sendPing() {
    if (_isConnected && _channel != null) {
      _channel!.sink.add('ping');
    }
  }
}
