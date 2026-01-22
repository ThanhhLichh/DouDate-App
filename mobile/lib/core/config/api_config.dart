class ApiConfig {
  // Base URL - Thay đổi theo môi trường
  static const String baseUrl = 'http://192.168.1.4:8000'; // FastAPI default
  // static const String baseUrl = 'http://10.0.2.2:8000'; // Android Emulator
  // static const String baseUrl = 'https://your-domain.com'; // Production

  // WebSocket URL
  static String get wsUrl => baseUrl.replaceFirst('http', 'ws');

  // --------------- API Endpoints ---------------

  // Auth Endpoints
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String logout = '/auth/logout';
  static const String refreshToken = '/auth/refresh';
  static const String forgotPassword = '/auth/forgot-password';
  static const String verifyOtp = '/auth/verify-otp';
  static const String resetPassword = '/auth/reset-password';

  // User Endpoints
  static const String getUser = '/users/me';
  static const String updateUser = '/users/me';

  // Couple Endpoints
  static const String checkCouple = '/couple/me';
  static const String coupleStats = '/couple/stats';
  static const String breakConnection = '/couple/break';

  // QR Code Endpoints
  static const String generateQRCode = '/qr/create';
  static const String scanQRCode = '/qr/scan';
  static const String respondQRCode = '/qr/respond';

  // WebSocket Endpoints
  static const String qrStatusWebSocket = '/ws/qr-status';

  // Chat/Message Endpoints
  static const String getMessages = '/messages';
  static String updateMessage(int messageId) => '/messages/$messageId';
  static String deleteMessage(int messageId) => '/messages/$messageId';
  // static const String reactToMessage = '/messages';
  static String reactToMessage(int messageId) =>
      '/messages/$messageId/reaction';
  static const String chatWebSocket = '/ws/chat';
  static String getChatSettings(int coupleId) =>
      '/couple/$coupleId/chat-settings';
  static String updateChatSettings(int coupleId) =>
      '/couple/$coupleId/chat-settings';
  static String checkReadStatus = '/messages/read';

  // Memory Endpoints
  static const String getMemories = '/memories';
  static const String createMemory = '/memories';
  static String updateMemory(int memoryId) => '/memories/$memoryId';
  static String deleteMemory(int memoryId) => '/memories/$memoryId';
  static const String todayMemories = '/memories/today';

  // Google OAuth Endpoints
  static const String googleLogin = '/auth/google';

  // Timeouts
  static const int connectTimeout = 30000; // 30 seconds
  static const int receiveTimeout = 30000;

  // Headers
  static Map<String, String> get headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  static Map<String, String> authHeaders(String token) => {
    ...headers,
    'Authorization': 'Bearer $token',
  };
}
