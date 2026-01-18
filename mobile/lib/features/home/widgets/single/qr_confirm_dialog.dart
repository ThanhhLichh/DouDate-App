import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/utils/responsive_helper.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/providers/dashboard_theme_provider.dart';
import '../../models/qr_scan_models.dart';
import '../../controllers/home_controller.dart';

class QRConfirmDialog extends StatefulWidget {
  final ScanQRResponse data;
  final String qrToken;

  const QRConfirmDialog({super.key, required this.data, required this.qrToken});

  @override
  State<QRConfirmDialog> createState() => _QRConfirmDialogState();
}

class _QRConfirmDialogState extends State<QRConfirmDialog> {
  bool _isProcessing = false;

  Future<void> _handleAccept() async {
    setState(() {
      _isProcessing = true;
    });

    final homeController = context.read<HomeController>();

    // Gọi API respond với token và action="accept"
    final result = await homeController.respondQRCode(widget.qrToken, 'accept');

    if (!mounted) return;

    if (result != null) {
      // Success
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Successfully connected! 🎉'),
          backgroundColor: Colors.green,
        ),
      );

      context.go('/home-couple');

      await homeController.fetchDashboardData();
      if (!mounted) return;

      Navigator.pop(context, true);
    } else {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(homeController.errorMessage ?? 'Failed to accept'),
          backgroundColor: Colors.red,
        ),
      );

      setState(() {
        _isProcessing = false;
      });
    }
  }

  Future<void> _handleReject() async {
    setState(() {
      _isProcessing = true;
    });

    final homeController = context.read<HomeController>();

    // Gọi API respond với token và action="reject"
    await homeController.respondQRCode(widget.qrToken, 'reject');

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Request rejected'),
        backgroundColor: Colors.orange,
      ),
    );
    Navigator.pop(context, false);
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<DashboardThemeProvider>();
    final theme = themeProvider.currentTheme;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: ResponsiveHelper.all(context, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.favorite,
              color: theme.heartIconColor,
              size: context.space(60),
            ),
            ResponsiveHelper.verticalSpace(context, AppDimensions.spaceM),
            Text(
              'Connection Request',
              style: TextStyle(
                fontSize: context.sp(AppDimensions.fontL),
                fontWeight: FontWeight.bold,
                color: theme.textPrimaryColor,
              ),
            ),
            ResponsiveHelper.verticalSpace(context, AppDimensions.spaceM),
            Text(
              widget.data.fromUserName,
              style: TextStyle(
                fontSize: context.sp(AppDimensions.fontL),
                fontWeight: FontWeight.w600,
                color: theme.accentColor,
              ),
            ),
            ResponsiveHelper.verticalSpace(context, AppDimensions.spaceS),
            Text(
              'wants to start a journey with you',
              style: TextStyle(
                fontSize: context.sp(AppDimensions.fontS),
                color: theme.textSecondaryColor,
              ),
              textAlign: TextAlign.center,
            ),
            ResponsiveHelper.verticalSpace(context, AppDimensions.spaceXL),
            if (_isProcessing)
              const CircularProgressIndicator()
            else
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _handleReject,
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          vertical: context.space(15),
                        ),
                        side: BorderSide(color: theme.textSecondaryColor),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Reject',
                        style: TextStyle(
                          fontSize: context.sp(AppDimensions.fontM),
                          color: theme.textSecondaryColor,
                        ),
                      ),
                    ),
                  ),
                  ResponsiveHelper.horizontalSpace(
                    context,
                    AppDimensions.spaceM,
                  ),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _handleAccept,
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          vertical: context.space(15),
                        ),
                        backgroundColor: theme.accentColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Accept',
                        style: TextStyle(
                          fontSize: context.sp(AppDimensions.fontM),
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
