import 'dart:io';
import 'package:dio/dio.dart';

import '../../../core/services/api_client.dart';
import '../../../core/models/api_response.dart';
import '../models/user_profile.dart';
import '../../../core/config/api_config.dart';

class SettingsRepository {
  final ApiClient _apiClient = ApiClient();

  // Get User Profile
  Future<ApiResponse<UserProfile>> getUserProfile(String token) async {
    try {
      final response = await _apiClient.get<UserProfile>(
        ApiConfig.getUser,
        token: token,
        fromJsonT: (json) => UserProfile.fromJson(json),
      );
      return response;
    } catch (e) {
      return ApiResponse.error(
        message: 'Get user profile failed: ${e.toString()}',
      );
    }
  }

  // Update User Profile
  Future<ApiResponse<UserProfile>> updateProfile(
    String token,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _apiClient.put<UserProfile>(
        ApiConfig.updateUser,
        token: token,
        data: data,
        fromJsonT: (json) => UserProfile.fromJson(json),
      );
      return response;
    } catch (e) {
      return ApiResponse.error(
        message: 'Update profile failed: ${e.toString()}',
      );
    }
  }

  // Update Avatar
  Future<ApiResponse<String>> updateAvatar(String token, File imageFile) async {
    try {
      final formData = FormData.fromMap({
        'avatar': await MultipartFile.fromFile(
          imageFile.path,
          filename: imageFile.path.split('/').last,
        ),
      });

      final response = await _apiClient.put<String>(
        ApiConfig.updateUser,
        token: token,
        data: formData,
        fromJsonT: (json) => json['avatar_url'] as String,
      );

      return response;
    } catch (e) {
      return ApiResponse.error(
        message: 'Update avatar failed: ${e.toString()}',
      );
    }
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
    try {
      final response = await _apiClient.post<void>(
        ApiConfig.breakConnection,
        token: token,
      );
      return response;
    } catch (e) {
      return ApiResponse.error(
        message: 'Break connection failed: ${e.toString()}',
      );
    }
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
