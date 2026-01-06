import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/utils/responsive_helper.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/providers/dashboard_theme_provider.dart';

class HomeSinglePage extends StatefulWidget {
  const HomeSinglePage({super.key});

  @override
  State<HomeSinglePage> createState() => _HomeSinglePageState();
}

class _HomeSinglePageState extends State<HomeSinglePage> {
  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<DashboardThemeProvider>();
    final theme = themeProvider.currentTheme;

    return Scaffold(
      backgroundColor: theme.primaryColor,
      body: SafeArea(
        child: _buildBody(context, theme),
      ),
    );
  }

  Widget _buildBody(BuildContext context, dynamic theme) {
    return Stack(
      children: [
        // Background decorative circles
        Positioned(
          top: -context.space(40),
          left: -context.space(40),
          child: Container(
            width: context.space(120),
            height: context.space(120),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: theme.accentColor.withOpacity(0.08),
            ),
          ),
        ),
        Positioned(
          bottom: -context.space(60),
          right: -context.space(60),
          child: Container(
            width: context.space(200),
            height: context.space(200),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: theme.primaryColor.withOpacity(0.05),
            ),
          ),
        ),
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
                  ResponsiveHelper.verticalSpace(context, AppDimensions.spaceXL),

                  // Title
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

                  // Subtitle
                  Text(
                    "Let your partner scan this code\nto start your journey together",
                    style: TextStyle(
                      fontSize: context.sp(AppDimensions.fontS),
                      color: theme.textSecondaryColor,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  ResponsiveHelper.verticalSpace(context, AppDimensions.spaceXL),

                  // QR Code Card
                  _buildQRCodeCard(context, theme),

                  ResponsiveHelper.verticalSpace(context, AppDimensions.spaceXL),

                  // Scan QR Button
                  _buildScanButton(context, theme),

                  ResponsiveHelper.verticalSpace(context, AppDimensions.spaceL),

                  // Back to Login Link
                  TextButton(
                    onPressed: () {
                      // TODO: Handle logout or back
                    },
                    child: Text(
                      "Back to Login",
                      style: TextStyle(
                        fontSize: context.sp(AppDimensions.fontS),
                        color: theme.textSecondaryColor,
                      ),
                    ),
                  ),

                  ResponsiveHelper.verticalSpace(context, AppDimensions.spaceL),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQRCodeCard(BuildContext context, dynamic theme) {
    return Container(
      padding: EdgeInsets.all(context.space(20)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: ResponsiveHelper.radius(context, AppDimensions.radiusXL),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // QR Code Placeholder
          Container(
            width: context.space(200),
            height: context.space(200),
            decoration: BoxDecoration(
              color: theme.primaryColor.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.primaryColor.withOpacity(0.2),
                width: 2,
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // QR pattern placeholder
                  SizedBox(
                    width: context.space(120),
                    height: context.space(120),
                    child: CustomPaint(
                      painter: QRPatternPainter(
                        color: theme.primaryColor,
                      ),
                    ),
                  ),
                  ResponsiveHelper.verticalSpace(
                    context,
                    AppDimensions.spaceS,
                  ),
                  Text(
                    "QR Code",
                    style: TextStyle(
                      fontSize: context.sp(AppDimensions.fontXS),
                      color: theme.textSecondaryColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScanButton(BuildContext context, dynamic theme) {
    return Container(
      width: context.wp(80),
      height: context.space(50),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.primaryColor,
            theme.accentColor,
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(context.space(30)),
        boxShadow: [
          BoxShadow(
            color: theme.primaryColor.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // TODO: Open QR scanner
          },
          borderRadius: BorderRadius.circular(context.space(30)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.qr_code_scanner,
                color: Colors.white,
                size: context.space(AppDimensions.iconM),
              ),
              ResponsiveHelper.horizontalSpace(context, AppDimensions.spaceS),
              Text(
                "Scan QR Code",
                style: TextStyle(
                  fontSize: context.sp(AppDimensions.fontM),
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Custom painter for QR pattern
class QRPatternPainter extends CustomPainter {
  final Color color;

  QRPatternPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2;

    final cellSize = size.width / 7;

    // Draw position markers (corners)
    _drawPositionMarker(canvas, Offset(0, 0), cellSize, paint);
    _drawPositionMarker(
        canvas, Offset(size.width - cellSize * 2.5, 0), cellSize, paint);
    _drawPositionMarker(
        canvas, Offset(0, size.height - cellSize * 2.5), cellSize, paint);

    // Draw center pattern
    for (int i = 0; i < 7; i++) {
      for (int j = 0; j < 7; j++) {
        if ((i + j) % 2 == 0) {
          canvas.drawRect(
            Rect.fromLTWH(
              i * cellSize,
              j * cellSize,
              cellSize,
              cellSize,
            ),
            paint,
          );
        }
      }
    }

    // Draw timing patterns
    for (int i = 0; i < 7; i++) {
      if (i % 2 == 0) {
        canvas.drawRect(
          Rect.fromLTWH(
            4.5 * cellSize,
            i * cellSize,
            cellSize,
            cellSize,
          ),
          paint,
        );
        canvas.drawRect(
          Rect.fromLTWH(
            i * cellSize,
            4.5 * cellSize,
            cellSize,
            cellSize,
          ),
          paint,
        );
      }
    }
  }

  void _drawPositionMarker(
    Canvas canvas,
    Offset position,
    double cellSize,
    Paint paint,
  ) {
    // Outer square
    canvas.drawRect(
      Rect.fromLTWH(
        position.dx,
        position.dy,
        cellSize * 2.5,
        cellSize * 2.5,
      ),
      paint,
    );

    // Inner square
    canvas.drawRect(
      Rect.fromLTWH(
        position.dx + cellSize * 0.5,
        position.dy + cellSize * 0.5,
        cellSize * 1.5,
        cellSize * 1.5,
      ),
      Paint()
        ..color = Colors.white
        ..strokeWidth = 2,
    );

    // Center square
    canvas.drawRect(
      Rect.fromLTWH(
        position.dx + cellSize,
        position.dy + cellSize,
        cellSize * 0.5,
        cellSize * 0.5,
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(QRPatternPainter oldDelegate) => false;
}
