import 'package:flutter/material.dart';
import '../../core/services/storage_service.dart';
import 'models/auth_models.dart';
import 'repository/auth_repository.dart';

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
      _errorMessage = 'Email and password are required';
      notifyListeners();
      return false;
    }

    if (!_isValidEmail(email)) {
      _errorMessage = 'Please enter a valid email';
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
        _currentUser = response.data!.user;
        await _storageService.saveToken(response.data!.accessToken);
        await _storageService.saveRefreshToken(response.data!.refreshToken);
        await _storageService.saveUser(_currentUser!.toJson());

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
      _errorMessage = 'An error occurred. Please try again.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Register
  Future<bool> register({
    required String name,
    required String email,
    required String password,
    String? avatarUrl,
  }) async {
    // Validation
    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      _errorMessage = 'All fields are required';
      notifyListeners();
      return false;
    }

    if (!_isValidEmail(email)) {
      _errorMessage = 'Please enter a valid email';
      notifyListeners();
      return false;
    }

    if (password.length < 6) {
      _errorMessage = 'Password must be at least 6 characters';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final request = RegisterRequest(
        name: name,
        email: email,
        password: password,
        avatarUrl: avatarUrl,
      );
      final response = await _authRepository.register(request);

      if (response.success && response.data != null) {
        _currentUser = response.data!.user;
        await _storageService.saveToken(response.data!.accessToken);
        await _storageService.saveRefreshToken(response.data!.refreshToken);
        await _storageService.saveUser(_currentUser!.toJson());

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.message ?? 'Registration failed';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'An error occurred. Please try again.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Logout
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    await _storageService.deleteToken();
    await _storageService.deleteRefreshToken();
    await _storageService.deleteUser();
    _currentUser = null;

    _isLoading = false;
    notifyListeners();
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
}
