// import 'dart:async';
// import 'dart:convert';
// import 'package:web_socket_channel/web_socket_channel.dart';
// import '../../../core/config/api_config.dart';
// import '../../features/chat/models/chat_models.dart';

// class WebSocketService {
//   WebSocketChannel? _channel;
//   final _messageController = StreamController<Message>.broadcast();
//   bool _isConnected = false;

//   Stream<Message> get messageStream => _messageController.stream;
//   bool get isConnected => _isConnected;

//   Future<void> connect(int coupleId, String token) async {
//     try {
//       final wsUrl = '${ApiConfig.wsUrl}/ws/chat/$coupleId?token=$token';
//       _channel = WebSocketChannel.connect(Uri.parse(wsUrl));
//       _isConnected = true;

//       _channel!.stream.listen(
//         (data) {
//           try {
//             final json = jsonDecode(data);
//             final message = Message.fromJson(json);
//             _messageController.add(message);
//           } catch (e) {
//             print('Error parsing message: $e');
//           }
//         },
//         onError: (error) {
//           print('WebSocket error: $error');
//           _isConnected = false;
//         },
//         onDone: () {
//           print('WebSocket closed');
//           _isConnected = false;
//         },
//       );
//     } catch (e) {
//       print('Failed to connect WebSocket: $e');
//       _isConnected = false;
//     }
//   }

//   void sendMessage(String content) {
//     if (_channel != null && _isConnected) {
//       _channel!.sink.add(jsonEncode({'content': content}));
//     }
//   }

//   void disconnect() {
//     _channel?.sink.close();
//     _isConnected = false;
//   }

//   void dispose() {
//     disconnect();
//     _messageController.close();
//   }
// }
