import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/config/api_config.dart';
import '../../../core/models/api_response.dart';
import '../../../core/services/api_client.dart';
import '../models/home_models.dart';
import '../models/qr_models.dart';
import '../models/qr_scan_models.dart';

class HomeRepository {
  final ApiClient _apiClient = ApiClient();

  // Get Dashboard Data
  Future<ApiResponse<CoupleDashboard>> getDashboardData(String token) async {
    try {
      // Get couple stats from backend
      final response = await _apiClient.get<Map<String, dynamic>>(
        ApiConfig.coupleStats,
        token: token,
      );

      if (response.success && response.data != null) {
        // Get today's quote separately
        final quoteResponse = await getTodayQuote(token);

        // Merge stats data with quote
        final statsData = response.data!;
        final dashboardData = {
          ...statsData,
          'today_quote':
              quoteResponse.data ?? 'Every day with you feels like a gift.',
        };

        return ApiResponse.success(
          message: 'Dashboard loaded successfully',
          data: CoupleDashboard.fromJson(dashboardData),
        );
      } else {
        return ApiResponse.error(
          message: response.message ?? 'Failed to load dashboard',
        );
      }
    } catch (e) {
      return ApiResponse.error(message: 'An error occurred: ${e.toString()}');
    }
  }

  // Get Today's Quote
  Future<ApiResponse<String>> getTodayQuote(String token) async {
    try {
      final response = await http.get(
        Uri.parse('https://zenquotes.io/api/random'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> json = jsonDecode(response.body);
        final quote = json.first['q'] as String;

        // Ensure quote is short (< 20 words)
        final wordCount = quote.split(' ').length;
        if (wordCount > 20) {
          // Return default quote if too long
          return ApiResponse.success(
            data: 'Every day with you feels like a gift.',
          );
        }

        return ApiResponse.success(data: quote);
      } else {
        return ApiResponse.success(
          data: 'Every day with you feels like a gift.',
        );
      }
    } catch (e) {
      // Return default quote on error
      return ApiResponse.success(data: 'Every day with you feels like a gift.');
    }
  }

  // Create QR Code
  Future<ApiResponse<QRCodeData>> createQRCode(String token) async {
    try {
      final response = await _apiClient.post<Map<String, dynamic>>(
        ApiConfig.generateQRCode,
        token: token,
      );

      if (response.success && response.data != null) {
        return ApiResponse.success(data: QRCodeData.fromJson(response.data!));
      } else {
        return ApiResponse.error(
          message: response.message ?? 'Failed to create QR code',
        );
      }
    } catch (e) {
      return ApiResponse.error(message: 'An error occurred: ${e.toString()}');
    }
  }

  // Scan QR Code
  Future<ApiResponse<ScanQRResponse>> scanQRCode(
    String token,
    String qrToken,
  ) async {
    try {
      final request = ScanQRRequest(token: qrToken);
      final response = await _apiClient.post<Map<String, dynamic>>(
        ApiConfig.scanQRCode,
        data: request.toJson(),
        token: token,
      );

      if (response.success && response.data != null) {
        return ApiResponse.success(
          message: 'QR scanned successfully',
          data: ScanQRResponse.fromJson(response.data!),
        );
      } else {
        return ApiResponse.error(
          message: response.message ?? 'Failed to scan QR code',
        );
      }
    } catch (e) {
      return ApiResponse.error(message: 'An error occurred: ${e.toString()}');
    }
  }

  // Respond to QR Code (Accept/Reject)
  Future<ApiResponse<CoupleResponse?>> respondQRCode(
    String token,
    String qrToken,
    String action,
  ) async {
    try {
      final request = RespondQRRequest(token: qrToken, action: action);
      final response = await _apiClient.post<Map<String, dynamic>?>(
        ApiConfig.respondQRCode,
        data: request.toJson(),
        token: token,
      );

      if (response.success) {
        if (response.data != null) {
          return ApiResponse.success(
            message: 'Request accepted successfully',
            data: CoupleResponse.fromJson(response.data!),
          );
        } else {
          // Reject case - no data returned
          return ApiResponse.success(message: 'Request rejected', data: null);
        }
      } else {
        return ApiResponse.error(
          message: response.message ?? 'Failed to respond',
        );
      }
    } catch (e) {
      return ApiResponse.error(message: 'An error occurred: ${e.toString()}');
    }
  }
}
