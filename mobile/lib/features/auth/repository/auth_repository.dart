import '../../../core/config/api_config.dart';
import '../../../core/models/api_response.dart';
import '../../../core/services/api_client.dart';
import '../models/auth_models.dart';

class AuthRepository {
  final ApiClient _apiClient = ApiClient();

  // Login
  Future<ApiResponse<AuthResponse>> login(LoginRequest request) async {
    // Mock response khi chưa có API
    await Future.delayed(const Duration(seconds: 2));
    return ApiResponse.success(
      message: 'Login successful',
      data: AuthResponse(
        accessToken:
            'mock_access_token_${DateTime.now().millisecondsSinceEpoch}',
        refreshToken: 'mock_refresh_token',
        user: User(
          id: '1',
          name: 'Test User',
          email: request.email,
          avatarUrl: null,
        ),
      ),
    );

    // Khi có API thực, uncomment code dưới và xóa mock code trên
    /*
    return await _apiClient.post<AuthResponse>(
      ApiConfig.login,
      data: request.toJson(),
      fromJsonT: (json) => AuthResponse.fromJson(json),
    );
    */
  }

  // Register
  Future<ApiResponse<AuthResponse>> register(RegisterRequest request) async {
    // Mock response khi chưa có API
    await Future.delayed(const Duration(seconds: 2));
    return ApiResponse.success(
      message: 'Registration successful',
      data: AuthResponse(
        accessToken:
            'mock_access_token_${DateTime.now().millisecondsSinceEpoch}',
        refreshToken: 'mock_refresh_token',
        user: User(
          id: '2',
          name: request.name,
          email: request.email,
          avatarUrl: request.avatarUrl,
        ),
      ),
    );

    // Khi có API thực, uncomment code dưới và xóa mock code trên
    /*
    return await _apiClient.post<AuthResponse>(
      ApiConfig.register,
      data: request.toJson(),
      fromJsonT: (json) => AuthResponse.fromJson(json),
    );
    */
  }

  // Refresh Token
  Future<ApiResponse<AuthResponse>> refreshToken(String refreshToken) async {
    return await _apiClient.post<AuthResponse>(
      ApiConfig.refreshToken,
      data: {'refresh_token': refreshToken},
      fromJsonT: (json) => AuthResponse.fromJson(json),
    );
  }
}
