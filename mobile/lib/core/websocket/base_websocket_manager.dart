import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

abstract class BaseWebSocketManager {
  WebSocketChannel? _channel;
  Timer? _reconnectTimer;
  Timer? _pingTimer;
  bool _isConnected = false;
  bool _isManualDisconnect = false;
  int _reconnectAttempts = 0;
  dynamic _lastParams; // ← THÊM field này để lưu params

  static const int _maxReconnectAttempts = 5;
  static const Duration _reconnectDelay = Duration(seconds: 3);
  static const Duration _pingInterval = Duration(seconds: 30);

  bool get isConnected => _isConnected;

  String getWebSocketUrl(dynamic params);
  void onMessage(dynamic message);
  void onConnectionStateChanged(bool isConnected);

  Future<void> connect(dynamic params) async {
    if (_isConnected) {
      print('${runtimeType}: WebSocket already connected');
      return;
    }

    _isManualDisconnect = false;
    _lastParams = params; // ← LƯU params

    try {
      final wsUrl = getWebSocketUrl(params);
      print('${runtimeType}: Connecting to $wsUrl');

      _channel = WebSocketChannel.connect(Uri.parse(wsUrl));
      _isConnected = true;
      _reconnectAttempts = 0;
      onConnectionStateChanged(true);

      _startPingTimer();

      _channel!.stream.listen(
        (data) {
          try {
            onMessage(data);
          } catch (e) {
            print('${runtimeType}: Error handling message: $e');
          }
        },
        onError: (error) {
          print('${runtimeType}: WebSocket error: $error');
          _handleDisconnect();
          _attemptReconnect(); // ← KHÔNG CẦN pass params nữa
        },
        onDone: () {
          print('${runtimeType}: WebSocket connection closed');
          _handleDisconnect();
          if (!_isManualDisconnect) {
            _attemptReconnect(); // ← KHÔNG CẦN pass params nữa
          }
        },
      );

      print('${runtimeType}: Connected successfully');
    } catch (e) {
      print('${runtimeType}: Failed to connect: $e');
      _handleDisconnect();
      if (_reconnectAttempts == 0) {
        _attemptReconnect(); // ← KHÔNG CẦN pass params nữa
      }
    }
  }

  void _attemptReconnect() {
    // ← BỎ params parameter
    if (_isManualDisconnect || _reconnectAttempts >= _maxReconnectAttempts) {
      print(
        '${runtimeType}: Max reconnect attempts reached or manual disconnect',
      );
      return;
    }

    _reconnectAttempts++;
    print(
      '${runtimeType}: Reconnecting (attempt $_reconnectAttempts/$_maxReconnectAttempts)...',
    );

    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(_reconnectDelay, () async {
      try {
        await connect(_lastParams); // ← DÙNG _lastParams đã lưu
      } catch (e) {
        print('${runtimeType}: Reconnect failed: $e');
      }
    });
  }

  void _startPingTimer() {
    _pingTimer?.cancel();
    _pingTimer = Timer.periodic(_pingInterval, (_) {
      sendPing();
    });
  }

  @protected
  void sendData(dynamic data) {
    if (_isConnected && _channel != null) {
      try {
        _channel!.sink.add(data);
      } catch (e) {
        print('${runtimeType}: Error sending data: $e');
      }
    }
  }

  void sendPing() {
    if (_isConnected && _channel != null) {
      try {
        _channel!.sink.add('ping');
      } catch (e) {
        print('${runtimeType}: Error sending ping: $e');
      }
    }
  }

  void disconnect() {
    print('${runtimeType}: Manual disconnect');
    _isManualDisconnect = true;
    _handleDisconnect();
  }

  void _handleDisconnect() {
    _isConnected = false;
    _reconnectTimer?.cancel();
    _pingTimer?.cancel();
    _channel?.sink.close();
    _channel = null;
    onConnectionStateChanged(false);
  }

  void dispose() {
    disconnect();
    _reconnectTimer?.cancel();
    _pingTimer?.cancel();
    _lastParams = null; // ← CLEAR params khi dispose
  }
}
