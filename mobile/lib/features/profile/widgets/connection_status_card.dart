import 'package:flutter/material.dart';
import '../../../core/utils/responsive_helper.dart';
import '../../../core/constants/app_dimensions.dart';

class ConnectionStatusCard extends StatelessWidget {
  final String? partnerName;
  final VoidCallback onBreakConnection;
  final dynamic theme;

  const ConnectionStatusCard({
    super.key,
    this.partnerName,
    required this.onBreakConnection,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Container(
        padding: EdgeInsets.all(context.space(20)),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: ResponsiveHelper.radius(context, AppDimensions.radiusL),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Connection Status',
              style: TextStyle(
                fontSize: context.sp(AppDimensions.fontXS),
                color: theme.textSecondaryColor,
              ),
            ),
            ResponsiveHelper.verticalSpace(context, AppDimensions.spaceS),
            Text(
              partnerName != null
                  ? 'Connected with $partnerName'
                  : 'Not connected',
              style: TextStyle(
                fontSize: context.sp(AppDimensions.fontM),
                color: theme.textPrimaryColor,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (partnerName != null) ...[
              ResponsiveHelper.verticalSpace(context, AppDimensions.spaceM),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onBreakConnection,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 243, 7, 7),
                    padding: EdgeInsets.symmetric(vertical: context.space(12)),
                    shape: RoundedRectangleBorder(
                      borderRadius: ResponsiveHelper.radius(
                        context,
                        AppDimensions.radiusM,
                      ),
                    ),
                  ),
                  child: Text(
                    'BREAK CONNECTION',
                    style: TextStyle(
                      fontSize: context.sp(AppDimensions.fontS),
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
