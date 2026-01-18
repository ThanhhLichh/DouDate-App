import 'package:flutter/material.dart';
import '../../../core/services/storage_service.dart';
import '../models/auth_models.dart';
import '../repository/auth_repository.dart';
import '../../../core/constants/app_constants.dart';

class AuthController extends ChangeNotifier {
  final StorageService _storageService = StorageService();
  final AuthRepository _authRepository = AuthRepository();

  bool _isLoading = false;
  bool _isPasswordVisible = false;
  User? _currentUser;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  bool get isPasswordVisible => _isPasswordVisible;
  User? get currentUser => _currentUser;
  String? get errorMessage => _errorMessage;

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

        // Load user data từ storage (đã có từ register hoặc previous login)
        final userJson = await _storageService.getUser();
        if (userJson != null) {
          _currentUser = User.fromJson(userJson);
        }

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.message ?? 'Login failed';
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
    // Validation using extension methods
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
        // Lưu user info nhưng chưa có token
        // User sẽ vào HomeSinglePage để kết nối với partner
        await _storageService.saveUser(_currentUser!.toJson());

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        // Parse error message from backend
        String errorMsg = response.message ?? 'Registration failed';

        // Handle common backend errors
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

      // Check nếu refresh token đã hết hạn
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
        // Lưu tokens mới với expiry time
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
      // Get refresh token for API call
      final refreshToken = await _storageService.getRefreshToken();

      if (refreshToken != null) {
        // Call logout API
        final response = await _authRepository.logout(refreshToken);

        if (!response.success) {
          // Log error but continue with local logout
          debugPrint('Logout API failed: ${response.message}');
        }
      }

      // Clear local storage regardless of API result
      await _storageService.deleteToken();
      await _storageService.deleteRefreshToken();
      await _storageService.deleteUser();
      _currentUser = null;

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      // Even if API fails, still logout locally
      debugPrint('Logout error: $e');

      await _storageService.deleteToken();
      await _storageService.deleteRefreshToken();
      await _storageService.deleteUser();
      _currentUser = null;

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
    // Ít nhất 1 chữ hoa, 1 chữ thường, 1 số, 1 ký tự đặc biệt
    final hasUppercase = password.contains(RegExp(r'[A-Z]'));
    final hasLowercase = password.contains(RegExp(r'[a-z]'));
    final hasDigits = password.contains(RegExp(r'[0-9]'));
    final hasSpecialCharacters = password.contains(
      RegExp(r'[!@#$%^&*(),.?":{}|<>]'),
    );

    return hasUppercase && hasLowercase && hasDigits && hasSpecialCharacters;
  }
}
