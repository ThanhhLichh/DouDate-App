import 'package:flutter/foundation.dart';
import '../services/storage_service.dart';
import '../services/api_client.dart';
import '../config/api_config.dart';
import '../../features/auth/models/auth_models.dart';

enum AuthStatus { initial, authenticated, unauthenticated, loading }

enum UserRouteType { couple, single, unknown }

class AuthStateManager extends ChangeNotifier {
  final StorageService _storageService = StorageService();
  final ApiClient _apiClient = ApiClient();

  AuthStatus _status = AuthStatus.initial;
  User? _currentUser;
  UserRouteType _routeType = UserRouteType.unknown;
  String? _errorMessage;

  // Getters
  AuthStatus get status => _status;
  User? get currentUser => _currentUser;
  UserRouteType get routeType => _routeType;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  bool get isLoading => _status == AuthStatus.loading;

  // INITIALIZE AUTH - Gọi khi app start
  Future<void> initializeAuth() async {
    debugPrint('AuthStateManager: Initializing auth...');
    _status = AuthStatus.loading;
    notifyListeners();

    try {
      // 1. Check access token existence
      final accessToken = await _storageService.getToken();

      if (accessToken == null) {
        debugPrint('No access token found');
        await _setUnauthenticated();
        return;
      }

      debugPrint('Access token found');

      // 2. Check access token expiry
      final isAccessExpired = await _storageService.isTokenExpired();

      if (!isAccessExpired) {
        debugPrint('Access token still valid');
        // Token còn hạn, verify với server
        final verified = await _verifyTokenWithServer(accessToken);

        if (verified) {
          await _setAuthenticated();
          return;
        } else {
          debugPrint('Token verification failed');
          await _setUnauthenticated();
          return;
        }
      }

      // 3. Access token hết hạn, thử refresh
      debugPrint('Access token expired, trying refresh...');
      final refreshToken = await _storageService.getRefreshToken();

      if (refreshToken == null) {
        debugPrint('No refresh token found');
        await _setUnauthenticated();
        return;
      }

      // Check refresh token expiry
      final isRefreshExpired = await _storageService.isTokenExpired(
        isRefreshToken: true,
      );

      if (isRefreshExpired) {
        debugPrint('Refresh token expired');
        await _setUnauthenticated();
        return;
      }

      // 4. Refresh token
      debugPrint('Refreshing token...');
      final refreshed = await _refreshToken(refreshToken);

      if (refreshed) {
        debugPrint('Token refreshed successfully');
        await _setAuthenticated();
      } else {
        debugPrint('Token refresh failed');
        await _setUnauthenticated();
      }
    } catch (e) {
      debugPrint('Auth initialization error: $e');
      await _setUnauthenticated();
    }
  }

  // VERIFY TOKEN WITH SERVER
  Future<bool> _verifyTokenWithServer(String token) async {
    try {
      debugPrint('Verifying token with server...');

      final response = await _apiClient.get<User>(
        ApiConfig.getUser,
        token: token,
        fromJsonT: (json) => User.fromJson(json),
      );

      if (response.success && response.data != null) {
        _currentUser = response.data;
        await _storageService.saveUser(_currentUser!.toJson());
        await _storageService.saveUserId(_currentUser!.id);
        debugPrint('Token verified, user: ${_currentUser!.email}');
        return true;
      }

      return false;
    } catch (e) {
      debugPrint('Token verification error: $e');
      return false;
    }
  }

  // REFRESH TOKEN
  Future<bool> _refreshToken(String refreshToken) async {
    try {
      final response = await _apiClient.post<AuthResponse>(
        ApiConfig.refreshToken,
        data: {'refresh_token': refreshToken},
        fromJsonT: (json) => AuthResponse.fromJson(json),
      );

      if (response.success && response.data != null) {
        // Save new tokens
        await _storageService.saveTokenWithExpiry(response.data!.accessToken);
        await _storageService.saveTokenWithExpiry(
          response.data!.refreshToken,
          isRefreshToken: true,
        );

        // Verify new token
        return await _verifyTokenWithServer(response.data!.accessToken);
      }

      return false;
    } catch (e) {
      debugPrint('Refresh token error: $e');
      return false;
    }
  }

  // CHECK COUPLE STATUS
  Future<void> _checkCoupleStatus() async {
    try {
      final token = await _storageService.getToken();
      if (token == null) {
        _routeType = UserRouteType.unknown;
        return;
      }

      debugPrint('Checking couple status...');

      final response = await _apiClient.get<CoupleCheckResponse>(
        ApiConfig.checkCouple,
        token: token,
        fromJsonT: (json) => CoupleCheckResponse.fromJson(json),
      );

      if (response.success && response.data != null) {
        if (response.data!.hasCouple && response.data!.couple != null) {
          _routeType = UserRouteType.couple;

          // Save partner ID
          final userId = await _storageService.getUserId();
          if (userId != null) {
            final couple = response.data!.couple!;
            final partnerId = couple.user1Id == userId
                ? couple.user2Id
                : couple.user1Id;
            await _storageService.savePartnerId(partnerId);
            debugPrint('Has couple, partner ID: $partnerId');
          }
        } else {
          _routeType = UserRouteType.single;
          debugPrint('No couple');
        }
      } else {
        _routeType = UserRouteType.unknown;
      }
    } catch (e) {
      debugPrint('Check couple error: $e');
      _routeType = UserRouteType.unknown;
    }
  }

  // SET AUTHENTICATED
  Future<void> _setAuthenticated() async {
    await _checkCoupleStatus();
    _status = AuthStatus.authenticated;
    _errorMessage = null;
    notifyListeners();
    debugPrint('Auth status: AUTHENTICATED (${_routeType.name})');
  }

  // SET UNAUTHENTICATED
  Future<void> _setUnauthenticated() async {
    await clearAuthState();
    _status = AuthStatus.unauthenticated;
    _routeType = UserRouteType.unknown;
    notifyListeners();
    debugPrint('Auth status: UNAUTHENTICATED');
  }

  // CLEAR AUTH STATE (Logout)
  Future<void> clearAuthState() async {
    debugPrint('Clearing auth state...');
    await _storageService.clearAll();
    _currentUser = null;
    _routeType = UserRouteType.unknown;
    _errorMessage = null;
  }

  // UPDATE AUTH AFTER LOGIN
  Future<void> updateAuthAfterLogin(User user, bool hasCouple) async {
    _currentUser = user;
    _status = AuthStatus.authenticated;
    _routeType = hasCouple ? UserRouteType.couple : UserRouteType.single;
    notifyListeners();
    debugPrint('Auth updated after login: ${_routeType.name}');
  }

  // RE-CHECK COUPLE STATUS (Gọi từ UI khi cần)
  Future<void> recheckCoupleStatus() async {
    debugPrint('Rechecking couple status...');
    await _checkCoupleStatus();
    notifyListeners();
  }

  // LOGOUT
  Future<void> logout() async {
    debugPrint('Logging out...');
    await _setUnauthenticated();
  }
}
