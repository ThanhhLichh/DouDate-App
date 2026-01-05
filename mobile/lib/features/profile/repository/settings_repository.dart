import 'dart:io';
import '../../../core/services/api_client.dart';
import '../../../core/models/api_response.dart';
import '../models/user_profile.dart';

class SettingsRepository {
  final ApiClient _apiClient = ApiClient();

  // Get User Profile
  Future<ApiResponse<UserProfile>> getUserProfile(String token) async {
    // Mock response for now
    await Future.delayed(const Duration(seconds: 1));

    return ApiResponse.success(
      message: 'Profile loaded successfully',
      data: UserProfile(
        id: '1',
        name: 'Emma Johnson',
        birthday: 'March 15, 1998',
        gender: 'Female',
        avatarUrl: null,
        isConnected: true,
        partnerName: 'Alex Chen',
        email: 'emma.johnson@example.com',
      ),
    );

    // When API is ready, use this:
    /*
    return await _apiClient.get<UserProfile>(
      '/users/profile',
      token: token,
      fromJsonT: (json) => UserProfile.fromJson(json),
    );
    */
  }

  // Update User Profile
  Future<ApiResponse<UserProfile>> updateProfile(
    String token,
    Map<String, dynamic> data,
  ) async {
    // Mock response
    await Future.delayed(const Duration(milliseconds: 500));
    return ApiResponse.success(message: 'Profile updated successfully');

    // When API is ready:
    /*
    return await _apiClient.put<UserProfile>(
      '/users/profile',
      token: token,
      data: data,
      fromJsonT: (json) => UserProfile.fromJson(json),
    );
    */
  }

  // Update Avatar
  Future<ApiResponse<String>> updateAvatar(String token, File imageFile) async {
    // Mock response
    await Future.delayed(const Duration(seconds: 1));
    return ApiResponse.success(
      message: 'Avatar updated successfully',
      data: 'https://example.com/avatar.jpg',
    );

    // When API is ready, implement multipart upload:
    /*
    final formData = FormData.fromMap({
      'avatar': await MultipartFile.fromFile(
        imageFile.path,
        filename: 'avatar.jpg',
      ),
    });

    return await _apiClient.post<String>(
      '/users/avatar',
      token: token,
      data: formData,
      fromJsonT: (json) => json['avatar_url'] as String,
    );
    */
  }

  // Update Notification Settings
  Future<ApiResponse<void>> updateNotificationSettings(
    String token,
    bool enabled,
  ) async {
    // Mock response
    await Future.delayed(const Duration(milliseconds: 300));
    return ApiResponse.success(message: 'Notification settings updated');

    // When API is ready:
    /*
    return await _apiClient.put<void>(
      '/users/notifications',
      token: token,
      data: {'enabled': enabled},
    );
    */
  }

  // Break Connection
  Future<ApiResponse<void>> breakConnection(String token) async {
    // Mock response
    await Future.delayed(const Duration(seconds: 1));
    return ApiResponse.success(message: 'Connection broken successfully');

    // When API is ready:
    /*
    return await _apiClient.delete<void>(
      '/users/connection',
      token: token,
    );
    */
  }

  // Delete Account
  Future<ApiResponse<void>> deleteAccount(String token) async {
    // Mock response
    await Future.delayed(const Duration(seconds: 1));
    return ApiResponse.success(message: 'Account deleted successfully');

    // When API is ready:
    /*
    return await _apiClient.delete<void>(
      '/users/account',
      token: token,
    );
    */
  }
}
