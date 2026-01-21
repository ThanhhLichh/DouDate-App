import '../../../core/config/api_config.dart';
import '../../../core/models/api_response.dart';
import '../../../core/services/api_client.dart';
import '../models/auth_models.dart';
import '../../../core/services/storage_service.dart';

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
      if (response.success && response.data != null) {
        final storageService = StorageService();

        await storageService.saveTokenWithExpiry(response.data!.accessToken);
        await storageService.saveTokenWithExpiry(
          response.data!.refreshToken,
          isRefreshToken: true,
        );

        final userResponse = await _apiClient.get<User>(
          ApiConfig.getUser,
          token: response.data!.accessToken,
          fromJsonT: (json) => User.fromJson(json),
        );

        // Lưu userId vào storage
        if (userResponse.success && userResponse.data != null) {
          await storageService.saveUserId(userResponse.data!.id);
          print("Đã lưu UserId thành công: ${userResponse.data!.id}");
        }
      }

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

      if (response.success &&
          response.data != null &&
          response.data!.hasCouple) {
        final storage = StorageService();
        final userId = await storage.getUserId();

        if (userId != null) {
          final couple = response.data!.couple!;

          if (couple.user1Id != userId && couple.user2Id != userId) {
            throw Exception("User not in this couple");
          }

          final partnerId = couple.user1Id == userId
              ? couple.user2Id
              : couple.user1Id;

          await storage.savePartnerId(partnerId);
          print("PartnerId saved: $partnerId");
        }
      }

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

  // Forgot Password - Send OTP
  Future<ApiResponse<ForgotPasswordResponse>> forgotPassword(
    ForgotPasswordRequest request,
  ) async {
    try {
      final response = await _apiClient.post<ForgotPasswordResponse>(
        ApiConfig.forgotPassword,
        data: request.toJson(),
        fromJsonT: (json) => ForgotPasswordResponse.fromJson(json),
      );
      return response;
    } catch (e) {
      return ApiResponse.error(message: 'Failed to send OTP: ${e.toString()}');
    }
  }

  // Verify OTP
  Future<ApiResponse<VerifyOtpResponse>> verifyOtp(
    VerifyOtpRequest request,
  ) async {
    try {
      final response = await _apiClient.post<VerifyOtpResponse>(
        ApiConfig.verifyOtp,
        data: request.toJson(),
        fromJsonT: (json) => VerifyOtpResponse.fromJson(json),
      );
      return response;
    } catch (e) {
      return ApiResponse.error(
        message: 'Failed to verify OTP: ${e.toString()}',
      );
    }
  }

  // Reset Password
  Future<ApiResponse<ResetPasswordResponse>> resetPassword(
    ResetPasswordRequest request,
  ) async {
    try {
      final response = await _apiClient.post<ResetPasswordResponse>(
        ApiConfig.resetPassword,
        data: request.toJson(),
        fromJsonT: (json) => ResetPasswordResponse.fromJson(json),
      );
      return response;
    } catch (e) {
      return ApiResponse.error(
        message: 'Failed to reset password: ${e.toString()}',
      );
    }
  }
}
