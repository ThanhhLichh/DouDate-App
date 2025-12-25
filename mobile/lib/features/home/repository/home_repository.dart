import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/config/api_config.dart';
import '../../../core/models/api_response.dart';
import '../../../core/services/api_client.dart';
import '../models/home_models.dart';

class HomeRepository {
  final ApiClient _apiClient = ApiClient();

  // Get Dashboard Data
  Future<ApiResponse<CoupleDashboard>> getDashboardData(String token) async {
    // Mock response khi chưa có API
    await Future.delayed(const Duration(seconds: 1));
    final quoteResponse = await getTodayQuote(token);
    return ApiResponse.success(
      message: 'Dashboard loaded successfully',
      data: CoupleDashboard(
        partnerName: "Emma",
        partnerAvatar: "assets/images/partner.png",
        yourName: "Alex",
        yourAvatar: "assets/images/me.png",
        startDate: DateTime(2024, 11, 20),
        messageCount: 1200,
        momentCount: 234,
        memoryCount: 47,
        todayQuote: quoteResponse.data ?? '',
      ),
    );

    // Khi có API thực, uncomment code dưới và xóa mock code trên
    /*
    return await _apiClient.get<CoupleDashboard>(
      '/dashboard',
      token: token,
      fromJsonT: (json) => CoupleDashboard.fromJson(json),
    );
    */
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

        // OPTIONAL: đảm bảo quote ngắn < 20 chữ
        final wordCount = quote.split(' ').length;
        if (wordCount > 20) {
          return ApiResponse.error(message: 'Quote too long');
        }

        return ApiResponse.success(data: quote);
      } else {
        return ApiResponse.error(message: 'HTTP ${response.statusCode}');
      }
    } catch (e) {
      return ApiResponse.error(message: e.toString());
    }
  }

  // Get Couple Stats
  Future<ApiResponse<CoupleStats>> getCoupleStats(String token) async {
    // Mock response
    await Future.delayed(const Duration(milliseconds: 500));
    return ApiResponse.success(
      data: CoupleStats(messageCount: 1200, momentCount: 234, memoryCount: 47),
    );

    // Khi có API thực
    /*
    return await _apiClient.get<CoupleStats>(
      '/stats',
      token: token,
      fromJsonT: (json) => CoupleStats.fromJson(json),
    );
    */
  }
}
