import 'package:flutter/material.dart';
import '../../../../core/utils/responsive_helper.dart';
import '../../../../core/constants/app_dimensions.dart';
import 'qr_pattern_painter.dart';

class QRCodeCard extends StatelessWidget {
  final dynamic theme;

  const QRCodeCard({super.key, required this.theme});

  @override
  Widget build(BuildContext context) {
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
                      painter: QRPatternPainter(color: theme.primaryColor),
                    ),
                  ),
                  ResponsiveHelper.verticalSpace(context, AppDimensions.spaceS),
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
}
