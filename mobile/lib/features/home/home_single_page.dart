import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../core/utils/responsive_helper.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/providers/dashboard_theme_provider.dart';
import '../auth/auth_controller.dart';
import 'widgets/single/qr_code_card.dart';
import 'widgets/single/scan_qr_button.dart';
import 'widgets/single/background_decoration.dart';

class HomeSinglePage extends StatefulWidget {
  const HomeSinglePage({super.key});

  @override
  State<HomeSinglePage> createState() => _HomeSinglePageState();
}

class _HomeSinglePageState extends State<HomeSinglePage> {
  bool _isLoggingOut = false;

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

    return Scaffold(
      backgroundColor: theme.primaryColor,
      body: SafeArea(
        child: Stack(
          children: [
            // Background decorations
            BackgroundDecoration(theme: theme),

            // Main content
            Center(
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
                      ResponsiveHelper.verticalSpace(
                        context,
                        AppDimensions.spaceXL,
                      ),

                      // Title Section
                      _buildTitleSection(context, theme),

                      ResponsiveHelper.verticalSpace(
                        context,
                        AppDimensions.spaceXL,
                      ),

                      // QR Code Card
                      QRCodeCard(theme: theme),

                      ResponsiveHelper.verticalSpace(
                        context,
                        AppDimensions.spaceXL,
                      ),

                      // Scan QR Button
                      ScanQRButton(
                        theme: theme,
                        onTap: () {
                          // TODO: Open QR scanner
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('QR Scanner coming soon!'),
                            ),
                          );
                        },
                      ),

                      ResponsiveHelper.verticalSpace(
                        context,
                        AppDimensions.spaceL,
                      ),

                      // Back to Login Button
                      _buildBackToLoginButton(context, theme),

                      ResponsiveHelper.verticalSpace(
                        context,
                        AppDimensions.spaceL,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Loading overlay
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
