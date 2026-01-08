import 'package:flutter/material.dart';
import '../../../../core/utils/responsive_helper.dart';
import '../../../../core/constants/app_dimensions.dart';

class ScanQRButton extends StatelessWidget {
  final dynamic theme;
  final VoidCallback onTap;

  const ScanQRButton({super.key, required this.theme, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: context.wp(80),
      height: context.space(50),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [theme.primaryColor, theme.accentColor],
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
          onTap: onTap,
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
