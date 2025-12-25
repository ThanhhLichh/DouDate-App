import 'package:flutter/material.dart';
import '../../core/services/storage_service.dart';
import 'models/home_models.dart';
import 'repository/home_repository.dart';

class HomeController extends ChangeNotifier {
  final StorageService _storageService = StorageService();
  final HomeRepository _homeRepository = HomeRepository();

  bool _isLoading = false;
  CoupleDashboard? _dashboardData;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  CoupleDashboard? get dashboardData => _dashboardData;
  String? get errorMessage => _errorMessage;

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Fetch Dashboard Data
  Future<bool> fetchDashboardData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final token = await _storageService.getToken();
      if (token == null) {
        _errorMessage = 'Not authenticated';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final response = await _homeRepository.getDashboardData(token);

      if (response.success && response.data != null) {
        _dashboardData = response.data;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.message ?? 'Failed to load dashboard';
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

  // Refresh Dashboard Data
  Future<void> refreshDashboard() async {
    await fetchDashboardData();
  }

  // Get Today's Quote
  Future<void> refreshQuote() async {
    try {
      final token = await _storageService.getToken();
      if (token == null) return;

      final response = await _homeRepository.getTodayQuote(token);
      if (response.success && response.data != null) {
        if (_dashboardData != null) {
          _dashboardData = CoupleDashboard(
            partnerName: _dashboardData!.partnerName,
            partnerAvatar: _dashboardData!.partnerAvatar,
            yourName: _dashboardData!.yourName,
            yourAvatar: _dashboardData!.yourAvatar,
            startDate: _dashboardData!.startDate,
            messageCount: _dashboardData!.messageCount,
            momentCount: _dashboardData!.momentCount,
            memoryCount: _dashboardData!.memoryCount,
            todayQuote: response.data!,
          );
          notifyListeners();
        }
      }
    } catch (e) {
      // Silent fail for quote refresh
    }
  }
}
