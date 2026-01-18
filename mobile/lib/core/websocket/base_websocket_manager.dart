import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

abstract class BaseWebSocketManager {
  WebSocketChannel? _channel;
  Timer? _reconnectTimer;
  Timer? _pingTimer;
  bool _isConnected = false;
  bool _isManualDisconnect = false;
  bool _isDisposed = false;
  int _reconnectAttempts = 0;
  dynamic _lastParams;

  static const int _maxReconnectAttempts = 5;
  static const Duration _reconnectDelay = Duration(seconds: 3);
  static const Duration _pingInterval = Duration(seconds: 30);

  bool get isConnected => _isConnected;

  String getWebSocketUrl(dynamic params);
  void onMessage(dynamic message);
  void onConnectionStateChanged(bool isConnected);

  Future<void> connect(dynamic params) async {
    if (_isConnected || _isDisposed) {
      print('${runtimeType}: WebSocket already connected or disposed');
      return;
    }

    _isManualDisconnect = false;
    _lastParams = params;

    try {
      final wsUrl = getWebSocketUrl(params);
      print('${runtimeType}: Connecting to $wsUrl');

      _channel = WebSocketChannel.connect(Uri.parse(wsUrl));
      _isConnected = true;
      _reconnectAttempts = 0;

      if (!_isDisposed) {
        onConnectionStateChanged(true);
      }

      _startPingTimer();

      _channel!.stream.listen(
        (data) {
          if (_isDisposed) return;
          try {
            onMessage(data);
          } catch (e) {
            print('${runtimeType}: Error handling message: $e');
          }
        },
        onError: (error) {
          if (_isDisposed) return;
          print('${runtimeType}: WebSocket error: $error');
          _handleDisconnect();
          _attemptReconnect(); //KHÔNG CẦN pass params nữa
        },
        onDone: () {
          if (_isDisposed) return;
          print('${runtimeType}: WebSocket connection closed');
          _handleDisconnect();
          if (!_isManualDisconnect) {
            _attemptReconnect(); //KHÔNG CẦN pass params nữa
          }
        },
      );

      print('${runtimeType}: Connected successfully');
    } catch (e) {
      if (_isDisposed) return;
      print('${runtimeType}: Failed to connect: $e');
      _handleDisconnect();
      if (_reconnectAttempts == 0) {
        _attemptReconnect(); //KHÔNG CẦN pass params nữa
      }
    }
  }

  void _attemptReconnect() {
    //BỎ params parameter
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
      if (_isDisposed) return;
      try {
        await connect(_lastParams); //DÙNG _lastParams đã lưu
      } catch (e) {
        print('${runtimeType}: Reconnect failed: $e');
      }
    });
  }

  void _startPingTimer() {
    _pingTimer?.cancel();
    _pingTimer = Timer.periodic(_pingInterval, (_) {
      if (_isDisposed) return;
      sendPing();
    });
  }

  @protected
  void sendData(dynamic data) {
    if (_isConnected && _channel != null && !_isDisposed) {
      try {
        _channel!.sink.add(data);
      } catch (e) {
        print('${runtimeType}: Error sending data: $e');
      }
    }
  }

  void sendPing() {
    if (_isConnected && _channel != null && !_isDisposed) {
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

    if (!_isDisposed) {
      onConnectionStateChanged(false);
    }
  }

  void dispose() {
    _isDisposed = true;
    disconnect();
    _reconnectTimer?.cancel();
    _pingTimer?.cancel();
    _lastParams = null; // ← CLEAR params khi dispose
  }
}
