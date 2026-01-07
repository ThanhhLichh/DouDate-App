import '../../../core/config/api_config.dart';
import '../../../core/models/api_response.dart';
import '../../../core/services/api_client.dart';
import '../models/auth_models.dart';

class AuthRepository {
  final ApiClient _apiClient = ApiClient();

  // Login
  Future<ApiResponse<AuthResponse>> login(LoginRequest request) async {
    try {
      final response = await _apiClient.post<AuthResponse>(
        ApiConfig.login,
        data: request.toJson(),
        fromJsonT: (json) => AuthResponse.fromJson(json),
      );
      return response;
    } catch (e) {
      return ApiResponse.error(message: 'Login failed: ${e.toString()}');
    }
  }

  // Check couple status
  Future<ApiResponse<CoupleCheckResponse>> checkCouple(String token) async {
    try {
      final response = await _apiClient.get<CoupleCheckResponse>(
        ApiConfig.checkCouple,
        token: token,
        fromJsonT: (json) => CoupleCheckResponse.fromJson(json),
      );
      return response;
    } catch (e) {
      return ApiResponse.error(
        message: 'Failed to check couple status: ${e.toString()}',
      );
    }
  }

  // Register
  Future<ApiResponse<User>> register(RegisterRequest request) async {
    try {
      final response = await _apiClient.post<User>(
        ApiConfig.register,
        data: request.toJson(),
        fromJsonT: (json) => User.fromJson(json),
      );
      return response;
    } catch (e) {
      return ApiResponse.error(message: 'Registration failed: ${e.toString()}');
    }
  }

  // Refresh Token
  Future<ApiResponse<AuthResponse>> refreshToken(String refreshToken) async {
    try {
      final response = await _apiClient.post<AuthResponse>(
        ApiConfig.refreshToken,
        data: {'refresh_token': refreshToken},
        fromJsonT: (json) => AuthResponse.fromJson(json),
      );
      return response;
    } catch (e) {
      return ApiResponse.error(message: 'Refresh failed: ${e.toString()}');
    }
  }

  // Logout
  Future<ApiResponse<void>> logout(String refreshToken) async {
    try {
      final response = await _apiClient.post<AuthResponse>(
        ApiConfig.logout,
        data: {'refresh_token': refreshToken},
        fromJsonT: null,
      );
      return response;
    } catch (e) {
      return ApiResponse.error(message: 'Logout failed: ${e.toString()}');
    }
  }
}
