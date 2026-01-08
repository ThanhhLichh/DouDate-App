import 'package:flutter/material.dart';
import '../../core/services/storage_service.dart';
import 'models/home_models.dart';
import 'repository/home_repository.dart';
import 'dart:async';
import 'models/qr_models.dart';
import '../../core/constants/app_constants.dart';
import 'models/qr_scan_models.dart';
import '../../core/services/qr_webscoket_service.dart';

class HomeController extends ChangeNotifier {
  final StorageService _storageService = StorageService();
  final HomeRepository _homeRepository = HomeRepository();
  final QRWebSocketService _qrWebSocketService = QRWebSocketService();

  // Dashboard Data
  bool _isLoading = false;
  CoupleDashboard? _dashboardData;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  CoupleDashboard? get dashboardData => _dashboardData;
  String? get errorMessage => _errorMessage;

  // QR Code Data
  QRCodeData? _qrCodeData;
  Timer? _qrTimer;
  bool _isLoadingQR = false;

  QRCodeData? get qrCodeData => _qrCodeData;
  bool get isLoadingQR => _isLoadingQR;

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Scan QR WebSocket Service
  ScanQRResponse? _scannedQRData;
  bool _isScanning = false;
  bool _isResponding = false;

  ScanQRResponse? get scannedQRData => _scannedQRData;
  bool get isScanning => _isScanning;
  bool get isResponding => _isResponding;
  Stream<QRWebSocketEvent>? get qrEventStream =>
      _qrWebSocketService.eventStream;

  // Dispose timer khi controller bị dispose
  @override
  void dispose() {
    _qrWebSocketService.disconnect();
    super.dispose();
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

  // Generate QR Code
  Future<bool> generateQRCode() async {
    _isLoadingQR = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final token = await _storageService.getToken();
      if (token == null) {
        _errorMessage = ErrorMessages.notAuthenticated;
        _isLoadingQR = false;
        notifyListeners();
        return false;
      }

      final response = await _homeRepository.createQRCode(token);

      if (response.success && response.data != null) {
        _qrCodeData = response.data;
        _isLoadingQR = false;
        notifyListeners();

        // Start timer để tự động refresh QR khi hết hạn
        _startQRTimer();
        return true;
      } else {
        _errorMessage = response.message ?? 'Failed to generate QR code';
        _isLoadingQR = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = ErrorMessages.unknownError;
      _isLoadingQR = false;
      notifyListeners();
      return false;
    }
  }

  // Start timer to auto-refresh QR when expired
  void _startQRTimer() {
    // Cancel existing timer
    _qrTimer?.cancel();

    if (_qrCodeData == null) return;

    // Set timer để refresh QR trước khi hết hạn 10 giây
    final remainingTime = _qrCodeData!.remainingSeconds;
    if (remainingTime > 10) {
      _qrTimer = Timer(Duration(seconds: remainingTime - 10), () {
        // Chỉ refresh nếu user đang active (controller vẫn có listeners)
        if (hasListeners) {
          generateQRCode();
        }
      });
    } else if (remainingTime > 0) {
      // Nếu còn ít hơn 10 giây, refresh ngay
      _qrTimer = Timer(Duration(seconds: remainingTime), () {
        if (hasListeners) {
          generateQRCode();
        }
      });
    }
  }

  // Manual refresh QR code
  Future<void> refreshQRCode() async {
    _qrTimer?.cancel();
    await generateQRCode();
  }

  // Connect to QR WebSocket
  Future<void> connectQRWebSocket() async {
    try {
      final token = await _storageService.getToken();
      if (token == null) return;

      await _qrWebSocketService.connect(token);
      print('QR WebSocket connected');
    } catch (e) {
      print('Failed to connect QR WebSocket: $e');
    }
  }

  // Disconnect QR WebSocket
  void disconnectQRWebSocket() {
    _qrWebSocketService.disconnect();
  }

  // Scan QR Code
  Future<bool> scanQRCode(String qrToken) async {
    _isScanning = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final token = await _storageService.getToken();
      if (token == null) {
        _errorMessage = 'Not authenticated';
        _isScanning = false;
        notifyListeners();
        return false;
      }

      final response = await _homeRepository.scanQRCode(token, qrToken);

      if (response.success && response.data != null) {
        _scannedQRData = response.data;
        _isScanning = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.message ?? 'Failed to scan QR code';
        _isScanning = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'An error occurred: ${e.toString()}';
      _isScanning = false;
      notifyListeners();
      return false;
    }
  }

  // Respond to QR Code (Accept/Reject)
  Future<CoupleResponse?> respondQRCode(String qrToken, String action) async {
    _isResponding = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final token = await _storageService.getToken();
      if (token == null) {
        _errorMessage = ErrorMessages.notAuthenticated;
        _isResponding = false;
        notifyListeners();
        return null;
      }

      final response = await _homeRepository.respondQRCode(
        token,
        qrToken,
        action,
      );

      if (response.success) {
        _isResponding = false;
        _scannedQRData = null; // Clear scanned data
        notifyListeners();
        return response.data;
      } else {
        _errorMessage = response.message ?? 'Failed to respond';
        _isResponding = false;
        notifyListeners();
        return null;
      }
    } catch (e) {
      _errorMessage = 'An error occurred: ${e.toString()}';
      _isResponding = false;
      notifyListeners();
      return null;
    }
  }

  // Clear scanned QR data
  void clearScannedQRData() {
    _scannedQRData = null;
    notifyListeners();
  }

  // Clear QR data when user leaves
  void clearQRData() {
    _qrTimer?.cancel();
    _qrCodeData = null;
    notifyListeners();
  }
}
