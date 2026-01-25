import 'package:flutter/material.dart';
import 'package:mobile/core/services/fcm_service.dart';
import '../../../core/services/storage_service.dart';
import '../models/auth_models.dart';
import '../repository/auth_repository.dart';
import '../services/google_auth_service.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/auth_state_manager.dart';

class AuthController extends ChangeNotifier {
  final StorageService _storageService = StorageService();
  final AuthRepository _authRepository = AuthRepository();
  final GoogleAuthService _googleAuthService = GoogleAuthService();

  AuthStateManager? _authStateManager;
  bool _isLoading = false;
  bool _isPasswordVisible = false;
  User? _currentUser;
  String? _errorMessage;

  // Forgot Password state
  String? _otpToken;
  String? _resetToken;
  String? _userEmail;

  bool get isLoading => _isLoading;
  bool get isPasswordVisible => _isPasswordVisible;
  User? get currentUser => _currentUser;
  String? get errorMessage => _errorMessage;
  String? get otpToken => _otpToken;
  String? get resetToken => _resetToken;
  String? get userEmail => _userEmail;

  void setAuthStateManager(AuthStateManager manager) {
    _authStateManager = manager;
  }

  void togglePasswordVisibility() {
    _isPasswordVisible = !_isPasswordVisible;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Login
  Future<bool> login(String email, String password) async {
    // Validation
    if (email.isEmpty || password.isEmpty) {
      _errorMessage = ErrorMessages.allFieldsRequired;
      notifyListeners();
      return false;
    }

    if (!_isValidEmail(email)) {
      _errorMessage = ErrorMessages.invalidEmail;
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final request = LoginRequest(email: email, password: password);
      final response = await _authRepository.login(request);

      if (response.success && response.data != null) {
        // Save tokens
        await _storageService.saveTokenWithExpiry(response.data!.accessToken);
        await _storageService.saveTokenWithExpiry(
          response.data!.refreshToken,
          isRefreshToken: true,
        );
        await _storageService.saveRefreshToken(response.data!.refreshToken);

        // Load user data from storage
        final userJson = await _storageService.getUser();
        if (userJson != null) {
          _currentUser = User.fromJson(userJson);
        }

        // Check couple status and update AuthStateManager
        final coupleStatus = await checkCoupleStatus();
        final hasCouple = coupleStatus?.hasCouple ?? false;

        if (_authStateManager != null && _currentUser != null) {
          await _authStateManager!.updateAuthAfterLogin(
            _currentUser!,
            hasCouple,
          );
        }

        await _sendFCMTokenToBackend();

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = ErrorMessages.networkError;
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = ErrorMessages.networkError;
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Login with Google
  Future<bool> loginWithGoogle() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Sign in with Google and get Firebase ID Token
      final String? idToken = await _googleAuthService.signInWithGoogle();

      if (idToken == null) {
        _errorMessage = 'Google sign in cancelled';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Send ID Token to backend
      final request = GoogleLoginRequest(idToken: idToken);
      final response = await _authRepository.googleLogin(request);

      if (response.success && response.data != null) {
        // Save tokens
        await _storageService.saveTokenWithExpiry(response.data!.accessToken);
        await _storageService.saveTokenWithExpiry(
          response.data!.refreshToken,
          isRefreshToken: true,
        );
        await _storageService.saveRefreshToken(response.data!.refreshToken);

        // Load user data
        final userJson = await _storageService.getUser();
        if (userJson != null) {
          _currentUser = User.fromJson(userJson);
        }

        final coupleStatus = await checkCoupleStatus();
        final hasCouple = coupleStatus?.hasCouple ?? false;

        if (_authStateManager != null && _currentUser != null) {
          await _authStateManager!.updateAuthAfterLogin(
            _currentUser!,
            hasCouple,
          );
        }

        await _sendFCMTokenToBackend();

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.message ?? 'Google login failed';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Google login error: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Check Couple Status
  Future<CoupleCheckResponse?> checkCoupleStatus() async {
    try {
      final token = await _storageService.getToken();
      if (token == null) return null;

      final response = await _authRepository.checkCouple(token);
      if (response.success && response.data != null) {
        return response.data;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Register
  Future<bool> register({
    required String name,
    required String email,
    required String password,
  }) async {
    // Validation
    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      _errorMessage = ErrorMessages.allFieldsRequired;
      notifyListeners();
      return false;
    }

    if (!_isValidEmail(email)) {
      _errorMessage = ErrorMessages.invalidEmail;
      notifyListeners();
      return false;
    }

    if (password.length < ValidationConstants.minPasswordLength) {
      _errorMessage = ErrorMessages.shortPassword;
      notifyListeners();
      return false;
    }

    if (!_isStrongPassword(password)) {
      _errorMessage = ErrorMessages.weakPassword;
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final request = RegisterRequest(
        email: email,
        password: password,
        fullName: name,
      );

      final response = await _authRepository.register(request);

      if (response.success && response.data != null) {
        _currentUser = response.data;
        await _storageService.saveUser(_currentUser!.toJson());

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        String errorMsg = response.message ?? 'Registration failed';

        if (response.errors != null) {
          final errors = response.errors!;
          if (errors.containsKey('email')) {
            errorMsg = ErrorMessages.emailExists;
          } else if (errors.containsKey('detail')) {
            errorMsg = errors['detail'].toString();
          }
        }

        _errorMessage = errorMsg;
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = ErrorMessages.networkError;
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Forgot Password - Send OTP
  Future<bool> sendOtpToEmail(String email) async {
    if (email.isEmpty) {
      _errorMessage = ErrorMessages.emailRequired;
      notifyListeners();
      return false;
    }

    if (!_isValidEmail(email)) {
      _errorMessage = ErrorMessages.invalidEmail;
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    _userEmail = email;
    notifyListeners();

    try {
      final request = ForgotPasswordRequest(email: email);
      final response = await _authRepository.forgotPassword(request);

      if (response.success && response.data != null) {
        _otpToken = response.data!.otpToken;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.message ?? ErrorMessages.failedToSendOtp;
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = ErrorMessages.networkError;
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Verify OTP
  Future<bool> verifyOtp(String otp) async {
    if (_userEmail == null || _otpToken == null) {
      _errorMessage = ErrorMessages.sessionInvalid;
      notifyListeners();
      return false;
    }

    if (otp.isEmpty || otp.length != 6) {
      _errorMessage = ErrorMessages.invalidOtp;
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final request = VerifyOtpRequest(
        email: _userEmail!,
        otp: otp,
        token: _otpToken!,
      );

      final response = await _authRepository.verifyOtp(request);

      if (response.success && response.data != null) {
        _resetToken = response.data!.resetToken;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.message ?? 'Invalid OTP';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = ErrorMessages.networkError;
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Reset Password
  Future<bool> resetPassword(String newPassword, String confirmPassword) async {
    if (_resetToken == null) {
      _errorMessage = ErrorMessages.sessionInvalid;
      notifyListeners();
      return false;
    }

    if (newPassword.isEmpty || confirmPassword.isEmpty) {
      _errorMessage = ErrorMessages.allFieldsRequired;
      notifyListeners();
      return false;
    }

    if (newPassword != confirmPassword) {
      _errorMessage = ErrorMessages.passwordMismatch;
      notifyListeners();
      return false;
    }

    if (newPassword.length < ValidationConstants.minPasswordLength) {
      _errorMessage = ErrorMessages.shortPassword;
      notifyListeners();
      return false;
    }

    if (!_isStrongPassword(newPassword)) {
      _errorMessage = ErrorMessages.weakPassword;
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final request = ResetPasswordRequest(
        resetToken: _resetToken!,
        newPassword: newPassword,
      );

      final response = await _authRepository.resetPassword(request);

      if (response.success) {
        // Clear forgot password session data
        _otpToken = null;
        _resetToken = null;
        _userEmail = null;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.message ?? 'Failed to reset password';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = ErrorMessages.networkError;
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Clear forgot password session
  void clearForgotPasswordSession() {
    _otpToken = null;
    _resetToken = null;
    _userEmail = null;
    _errorMessage = null;
    notifyListeners();
  }

  // Refresh Token
  Future<bool> refreshToken() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final refreshToken = await _storageService.getRefreshToken();
      if (refreshToken == null) {
        _errorMessage = ErrorMessages.refreshTokenNotFound;
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final isExpired = await _storageService.isTokenExpired(
        isRefreshToken: true,
      );
      if (isExpired) {
        _errorMessage = ErrorMessages.sessionExpired;
        await logout();
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final response = await _authRepository.refreshToken(refreshToken);

      if (response.success && response.data != null) {
        await _storageService.saveTokenWithExpiry(response.data!.accessToken);
        await _storageService.saveTokenWithExpiry(
          response.data!.refreshToken,
          isRefreshToken: true,
        );

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.message ?? 'Refresh token failed';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = ErrorMessages.networkError;
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Logout
  Future<bool> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      final refreshToken = await _storageService.getRefreshToken();

      if (refreshToken != null) {
        final response = await _authRepository.logout(refreshToken);
        if (!response.success) {
          debugPrint('Logout API failed: ${response.message}');
        }
      }

      await FCMService().deleteToken();
      debugPrint('FCM token deleted on logout');

      await _storageService.deleteToken();
      await _storageService.deleteRefreshToken();
      await _storageService.deleteUser();
      _currentUser = null;

      if (_authStateManager != null) {
        await _authStateManager!.logout();
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Logout error: $e');

      await FCMService().deleteToken();
      debugPrint('FCM token deleted on logout (error case)');

      await _storageService.deleteToken();
      await _storageService.deleteRefreshToken();
      await _storageService.deleteUser();
      _currentUser = null;

      if (_authStateManager != null) {
        await _authStateManager!.logout();
      }

      _isLoading = false;
      notifyListeners();
      return true;
    }
  }

  // Check if user is logged in
  Future<bool> checkAuthStatus() async {
    final token = await _storageService.getToken();
    if (token != null) {
      final userJson = await _storageService.getUser();
      if (userJson != null) {
        _currentUser = User.fromJson(userJson);
        notifyListeners();
        return true;
      }
    }
    return false;
  }

  // Email validation
  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  // Password strength validation
  bool _isStrongPassword(String password) {
    final hasUppercase = password.contains(RegExp(r'[A-Z]'));
    final hasLowercase = password.contains(RegExp(r'[a-z]'));
    final hasDigits = password.contains(RegExp(r'[0-9]'));
    final hasSpecialCharacters = password.contains(
      RegExp(r'[!@#$%^&*(),.?":{}|<>]'),
    );

    return hasUppercase && hasLowercase && hasDigits && hasSpecialCharacters;
  }

  // Send FCM token to backend
  Future<void> _sendFCMTokenToBackend() async {
    try {
      final fcmService = FCMService();
      final fcmToken = fcmService.fcmToken;

      if (fcmToken != null) {
        debugPrint('Sending FCM token to backend...');
        final response = await _authRepository.saveFCMToken(fcmToken);

        if (response.success) {
          debugPrint('FCM token saved successfully');
        } else {
          debugPrint('Failed to save FCM token: ${response.message}');
        }
      } else {
        debugPrint('No FCM token available');
      }
    } catch (e) {
      debugPrint('Error sending FCM token: $e');
    }
  }
}
