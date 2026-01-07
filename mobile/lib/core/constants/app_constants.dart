/// App-wide constants
class AppConstants {
  AppConstants._();
}

/// Error Messages
class ErrorMessages {
  static const String allFieldsRequired = 'All fields are required';
  static const String invalidEmail = 'Please enter a valid email';
  static const String weakPassword =
      'Password must contain uppercase, lowercase, number and special character';
  static const String shortPassword = 'Password must be at least 6 characters';
  static const String emailExists = 'Email already exists';
  static const String networkError =
      'Network error. Please check your connection.';
  static const String serverError = 'Server error occurred';
  static const String unknownError = 'An unexpected error occurred';
  static const String connectionTimeout =
      'Connection timeout. Please check your internet.';
  static const String noInternet =
      'No internet connection. Please check your network.';
  static const String notAuthenticated = 'Not authenticated';
  static const String loginFailed = 'Login failed';
  static const String registrationFailed = 'Registration failed';
  static const String invalidCredentials = 'Invalid email or password';
  static const String accountNotFound = 'Account not found';
  static const String accountInactive = 'Account is inactive';
}

/// Success Messages
class SuccessMessages {
  static const String registrationSuccess =
      'Registration successful! Connect with your partner.';
  static const String loginSuccess = 'Login successful';
  static const String logoutSuccess = 'Logged out successfully';
}

/// Validation Rules
class ValidationConstants {
  static const int minPasswordLength = 6;
  static const int maxPasswordLength = 128;
  static const int maxNameLength = 100;
  static const int maxEmailLength = 255;

  static final RegExp emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

  static final RegExp hasUppercase = RegExp(r'[A-Z]');
  static final RegExp hasLowercase = RegExp(r'[a-z]');
  static final RegExp hasDigits = RegExp(r'[0-9]');
  static final RegExp hasSpecialCharacters = RegExp(r'[!@#$%^&*(),.?":{}|<>]');
}

/// API Related
class ApiConstants {
  static const int connectTimeout = 30000;
  static const int receiveTimeout = 30000;
  static const int maxRetries = 3;
}

/// Storage Keys
class StorageKeys {
  static const String accessToken = 'access_token';
  static const String refreshToken = 'refresh_token';
  static const String userData = 'user_data';
  static const String theme = 'theme';
  static const String language = 'language';
}

/// Routes
class AppRoutes {
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String homeSingle = '/home-single';
  static const String chat = '/chat';
  static const String memories = '/memories';
  static const String settings = '/settings';
}
