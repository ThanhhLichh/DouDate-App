import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../core/utils/responsive_helper.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/providers/dashboard_theme_provider.dart';
import 'home_controller.dart';
import 'widgets/single/qr_confirm_dialog.dart';

class QRScannerPage extends StatefulWidget {
  const QRScannerPage({super.key});

  @override
  State<QRScannerPage> createState() => _QRScannerPageState();
}

class _QRScannerPageState extends State<QRScannerPage> {
  late MobileScannerController _controller;
  bool _isProcessing = false;
  bool _isDisposed = false;
  String? _scannedToken;

  @override
  void initState() {
    super.initState();
    _controller = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      facing: CameraFacing.back,
      torchEnabled: false,
    );
  }

  @override
  void dispose() {
    _isDisposed = true;
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleQRCode(String code) async {
    if (_isProcessing || _isDisposed) return;

    setState(() {
      _isProcessing = true;
      _scannedToken = code;
    });

    // Stop camera immediately
    try {
      await _controller.stop();
    } catch (e) {
      debugPrint('Error stopping camera: $e');
    }

    if (!mounted) return;

    // Lưu reference đến controller trước khi await
    final homeController = context.read<HomeController>();
    final success = await homeController.scanQRCode(code);

    if (!mounted || _isDisposed) return;

    if (success) {
      // Lưu data vào biến local
      final qrData = homeController.scannedQRData;

      if (qrData != null && _scannedToken != null) {
        // Show dialog
        final result = await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (context) =>
              QRConfirmDialog(data: qrData, qrToken: _scannedToken!),
        );

        if (!mounted || _isDisposed) return;

        if (result == true) {
          // Delay trước khi pop để đảm bảo state updates hoàn tất
          await Future.delayed(const Duration(milliseconds: 100));

          // Success - close page
          if (mounted && !_isDisposed) {
            Navigator.pop(context, true);
          }
        } else {
          // User cancelled - restart camera
          homeController.clearScannedQRData();
          if (mounted) {
            setState(() {
              _isProcessing = false;
              _scannedToken = null;
            });
          }

          if (!_isDisposed && mounted) {
            try {
              await _controller.start();
            } catch (e) {
              debugPrint('Error restarting camera: $e');
            }
          }
        }
      } else {
        // Data null
        if (mounted && !_isDisposed) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to process QR data'),
              backgroundColor: Colors.red,
            ),
          );
          setState(() {
            _isProcessing = false;
            _scannedToken = null;
          });

          try {
            await _controller.start();
          } catch (e) {
            debugPrint('Error restarting camera: $e');
          }
        }
      }
    } else {
      // Scan failed
      if (mounted && !_isDisposed) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(homeController.errorMessage ?? 'Invalid QR code'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {
          _isProcessing = false;
          _scannedToken = null;
        });

        try {
          await _controller.start();
        } catch (e) {
          debugPrint('Error restarting camera: $e');
        }
      }
    }
  }

  Future<void> _closeScanner() async {
    if (_isDisposed) return;

    try {
      await _controller.stop();
    } catch (e) {
      debugPrint('Error stopping camera on close: $e');
    }

    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<DashboardThemeProvider>();
    final theme = themeProvider.currentTheme;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) async {
        if (!didPop) {
          await _closeScanner();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: Text(
            'Scan QR Code',
            style: TextStyle(
              color: Colors.white,
              fontSize: context.sp(AppDimensions.fontL),
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: _closeScanner,
          ),
          automaticallyImplyLeading: false,
        ),
        body: Stack(
          children: [
            // Camera Scanner
            MobileScanner(
              controller: _controller,
              onDetect: (capture) {
                if (_isDisposed) return;

                final List<Barcode> barcodes = capture.barcodes;
                if (barcodes.isNotEmpty && !_isProcessing) {
                  final code = barcodes.first.rawValue;
                  if (code != null) {
                    _handleQRCode(code);
                  }
                }
              },
            ),

            // Scanning overlay
            _buildScanningOverlay(context, theme),

            // Loading indicator
            if (_isProcessing)
              Container(
                color: Colors.black.withValues(alpha: 0.5),
                child: const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildScanningOverlay(BuildContext context, dynamic theme) {
    return Column(
      children: [
        const Spacer(),
        Center(
          child: Container(
            width: context.wp(70),
            height: context.wp(70),
            decoration: BoxDecoration(
              border: Border.all(color: theme.accentColor, width: 3),
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
        ResponsiveHelper.verticalSpace(context, AppDimensions.spaceXL),
        Text(
          'Position QR code within frame',
          style: TextStyle(
            color: Colors.white,
            fontSize: context.sp(AppDimensions.fontM),
          ),
        ),
        const Spacer(),
      ],
    );
  }
}
