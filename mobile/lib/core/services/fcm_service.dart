import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// Background message handler - MUST be top-level function
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('Background message received: ${message.messageId}');
  debugPrint('Data: ${message.data}');
}

class FCMService {
  static final FCMService _instance = FCMService._internal();
  factory FCMService() => _instance;
  FCMService._internal();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  String? _fcmToken;
  String? get fcmToken => _fcmToken;

  // Callback khi tap notification
  Function(Map<String, dynamic>)? onNotificationTap;

  // Track chat page visibility
  bool _isChatPageVisible = false;
  void setChatPageVisibility(bool visible) {
    _isChatPageVisible = visible;
    debugPrint('🔔 FCM: Chat page visible = $visible');
  }

  /// Initialize FCM
  Future<void> initialize() async {
    try {
      debugPrint('🔔 FCM: Initializing...');

      // 1. Request permission
      final settings = await _requestPermission();
      if (settings.authorizationStatus != AuthorizationStatus.authorized) {
        debugPrint('🔔 FCM: Permission denied');
        return;
      }

      // 2. Setup local notifications (for foreground)
      await _setupLocalNotifications();

      // 3. Setup background handler
      FirebaseMessaging.onBackgroundMessage(
        _firebaseMessagingBackgroundHandler,
      );

      // 4. Get FCM token
      await _getToken();

      // 5. Listen to token refresh
      _listenToTokenRefresh();

      // 6. Handle foreground messages
      _handleForegroundMessages();

      // 7. Handle notification tap (app was terminated)
      _handleNotificationTapTerminated();

      // 8. Handle notification tap (app was background)
      _handleNotificationTapBackground();

      debugPrint('🔔 FCM: Initialized successfully');
    } catch (e) {
      debugPrint('🔔 FCM: Initialization error: $e');
    }
  }

  /// Request notification permission
  Future<NotificationSettings> _requestPermission() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
    debugPrint('🔔 FCM: Permission status: ${settings.authorizationStatus}');
    return settings;
  }

  /// Setup local notifications plugin
  Future<void> _setupLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings(
      '@drawable/ic_notification',
    );
    const iosSettings = DarwinInitializationSettings();

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Create Android notification channel
    const channel = AndroidNotificationChannel(
      'chat_channel',
      'Chat Messages',
      description: 'Notifications for new chat messages',
      importance: Importance.high,
      enableVibration: true,
      playSound: true,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);

    debugPrint('🔔 FCM: Local notifications setup complete');
  }

  /// Get FCM token
  Future<void> _getToken() async {
    try {
      _fcmToken = await _messaging.getToken();
      debugPrint('🔔 FCM Token: $_fcmToken');
    } catch (e) {
      debugPrint('🔔 FCM: Error getting token: $e');
    }
  }

  /// Listen to token refresh
  void _listenToTokenRefresh() {
    _messaging.onTokenRefresh.listen((newToken) {
      _fcmToken = newToken;
      debugPrint('🔔 FCM: Token refreshed: $newToken');
      // TODO: Send new token to backend
    });
  }

  /// Handle foreground messages
  void _handleForegroundMessages() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('Foreground message received');
      debugPrint('Title: ${message.notification?.title}');
      debugPrint('Body: ${message.notification?.body}');
      debugPrint('Data: ${message.data}');

      // LOGIC: Chỉ show notification nếu KHÔNG đang ở chat page
      if (!_isChatPageVisible) {
        _showLocalNotification(message);
      } else {
        debugPrint('🔔 User is on chat page, NOT showing notification');
      }
    });
  }

  /// Show local notification (foreground only)
  Future<void> _showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    const androidDetails = AndroidNotificationDetails(
      'chat_channel',
      'Chat Messages',
      channelDescription: 'Notifications for new chat messages',
      importance: Importance.high,
      priority: Priority.high,
      enableVibration: true,
      playSound: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      notification.hashCode,
      notification.title,
      notification.body,
      details,
      payload: message.data.toString(),
    );

    debugPrint('🔔 Local notification shown');
  }

  /// Handle notification tap (app terminated)
  void _handleNotificationTapTerminated() {
    _messaging.getInitialMessage().then((message) {
      if (message != null) {
        debugPrint('🔔 App opened from terminated state via notification');
        _handleNotificationData(message.data);
      }
    });
  }

  /// Handle notification tap (app background)
  void _handleNotificationTapBackground() {
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      debugPrint('🔔 App opened from background via notification');
      _handleNotificationData(message.data);
    });
  }

  /// Handle notification tap (local notification)
  void _onNotificationTapped(NotificationResponse response) {
    debugPrint('🔔 Local notification tapped');
    if (response.payload != null) {
      // Parse payload and navigate
      // For now, just trigger callback
      onNotificationTap?.call({});
    }
  }

  /// Process notification data and navigate
  void _handleNotificationData(Map<String, dynamic> data) {
    debugPrint('🔔 Processing notification data: $data');

    // Check if it's a chat notification
    if (data['type'] == 'chat') {
      // Trigger callback to navigate to chat
      onNotificationTap?.call(data);
    }
  }

  /// Send FCM token to backend
  Future<bool> sendTokenToBackend(
    String token,
    Function(String) apiCall,
  ) async {
    try {
      if (_fcmToken == null) {
        debugPrint('🔔 FCM: No token available');
        return false;
      }

      debugPrint('🔔 FCM: Sending token to backend...');
      await apiCall(_fcmToken!);
      debugPrint('🔔 FCM: Token sent successfully');
      return true;
    } catch (e) {
      debugPrint('🔔 FCM: Error sending token: $e');
      return false;
    }
  }

  /// Delete token (logout)
  Future<void> deleteToken() async {
    try {
      await _messaging.deleteToken();
      _fcmToken = null;
      debugPrint('🔔 FCM: Token deleted');
    } catch (e) {
      debugPrint('🔔 FCM: Error deleting token: $e');
    }
  }
}
