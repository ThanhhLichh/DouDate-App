import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../core/utils/responsive_helper.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/providers/dashboard_theme_provider.dart';
import '../auth/auth_controller.dart';
import 'home_controller.dart';
import 'widgets/single/qr_code_card.dart';
import 'widgets/single/scan_qr_button.dart';
import 'widgets/single/background_decoration.dart';
import 'widgets/single/single_page_skeleton.dart';
import 'qr_scanner_page.dart';

class HomeSinglePage extends StatefulWidget {
  const HomeSinglePage({super.key});

  @override
  State<HomeSinglePage> createState() => _HomeSinglePageState();
}

class _HomeSinglePageState extends State<HomeSinglePage> {
  bool _isLoggingOut = false;

  @override
  void initState() {
    super.initState();
    // Generate QR code khi page load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final homeController = context.read<HomeController>();

      // Generate QR code
      homeController.generateQRCode();

      // Connect to WebSocket để nhận thông báo khi có người scan
      homeController.connectQRWebSocket();

      // Listen to WebSocket events
      homeController.qrEventStream?.listen((event) {
        if (event.event == 'QR_SCANNED' && mounted) {
          // Show notification that someone scanned the QR
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Someone scanned your QR code! 🎉'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
              action: SnackBarAction(
                label: 'OK',
                textColor: Colors.white,
                onPressed: () {},
              ),
            ),
          );
        }
      });
    });
  }

  @override
  void dispose() {
    // Disconnect WebSocket and clear QR data
    context.read<HomeController>().disconnectQRWebSocket();
    context.read<HomeController>().clearQRData();
    super.dispose();
  }

  Future<void> _handleLogout() async {
    setState(() {
      _isLoggingOut = true;
    });

    try {
      final authController = context.read<AuthController>();
      await authController.logout();

      if (mounted) {
        context.go('/login');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoggingOut = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Logout failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<DashboardThemeProvider>();
    final theme = themeProvider.currentTheme;
    final homeController = context.watch<HomeController>();

    return Scaffold(
      backgroundColor: theme.primaryColor,
      body: SafeArea(
        child: Stack(
          children: [
            BackgroundDecoration(theme: theme),
            homeController.isLoadingQR
                ? const SinglePageSkeleton()
                : _buildMainContent(context, theme, homeController),
            if (_isLoggingOut)
              Container(
                color: Colors.black.withOpacity(0.3),
                child: const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainContent(
    BuildContext context,
    dynamic theme,
    HomeController homeController,
  ) {
    return Center(
      child: Container(
        constraints: BoxConstraints(
          maxWidth: ResponsiveHelper.maxContentWidth(context),
        ),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: ResponsiveHelper.symmetric(
            context: context,
            horizontal: context.isMobile ? 5 : 8,
            vertical: 3,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ResponsiveHelper.verticalSpace(context, AppDimensions.spaceXL),
              _buildTitleSection(context, theme),
              ResponsiveHelper.verticalSpace(context, AppDimensions.spaceXL),
              QRCodeCard(
                theme: theme,
                qrData: homeController.qrCodeData,
                onRefresh: () => homeController.refreshQRCode(),
              ),
              ResponsiveHelper.verticalSpace(context, AppDimensions.spaceXL),

              // Updated Scan QR Button with navigation
              ScanQRButton(
                theme: theme,
                onTap: () async {
                  // Navigate to QR Scanner
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const QRScannerPage(),
                    ),
                  );

                  // If successfully connected, result will be true
                  if (result == true && mounted) {
                    // Refresh dashboard or navigate
                    await homeController.fetchDashboardData();
                  }
                },
              ),

              ResponsiveHelper.verticalSpace(context, AppDimensions.spaceL),
              _buildBackToLoginButton(context, theme),
              ResponsiveHelper.verticalSpace(context, AppDimensions.spaceL),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTitleSection(BuildContext context, dynamic theme) {
    return Column(
      children: [
        Text(
          "Share this QR to connect",
          style: TextStyle(
            fontSize: context.sp(AppDimensions.fontXL),
            fontWeight: FontWeight.bold,
            color: theme.textPrimaryColor,
          ),
          textAlign: TextAlign.center,
        ),
        ResponsiveHelper.verticalSpace(context, AppDimensions.spaceM),
        Text(
          "Let your partner scan this code\nto start your journey together",
          style: TextStyle(
            fontSize: context.sp(AppDimensions.fontS),
            color: theme.textSecondaryColor,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildBackToLoginButton(BuildContext context, dynamic theme) {
    return TextButton(
      onPressed: _isLoggingOut ? null : _handleLogout,
      child: Text(
        _isLoggingOut ? "Logging out..." : "Back to Login",
        style: TextStyle(
          fontSize: context.sp(AppDimensions.fontS),
          color: _isLoggingOut
              ? theme.textSecondaryColor.withOpacity(0.5)
              : theme.textSecondaryColor,
        ),
      ),
    );
  }
}
