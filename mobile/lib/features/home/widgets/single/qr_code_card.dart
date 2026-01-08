import 'dart:async';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../../core/utils/responsive_helper.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../models/qr_models.dart';

class QRCodeCard extends StatefulWidget {
  final dynamic theme;
  final QRCodeData? qrData;
  final VoidCallback? onRefresh;

  const QRCodeCard({
    super.key,
    required this.theme,
    this.qrData,
    this.onRefresh,
  });

  @override
  State<QRCodeCard> createState() => _QRCodeCardState();
}

class _QRCodeCardState extends State<QRCodeCard> {
  Timer? _countdownTimer;
  int _remainingSeconds = 0;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  @override
  void didUpdateWidget(QRCodeCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Restart countdown nếu QR data thay đổi
    if (oldWidget.qrData?.token != widget.qrData?.token) {
      _startCountdown();
    }
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _startCountdown() {
    _countdownTimer?.cancel();

    if (widget.qrData == null) {
      setState(() {
        _remainingSeconds = 0;
      });
      return;
    }

    setState(() {
      _remainingSeconds = widget.qrData!.remainingSeconds;
    });

    // Update mỗi giây
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (widget.qrData == null || widget.qrData!.isExpired) {
        timer.cancel();
        setState(() {
          _remainingSeconds = 0;
        });
        return;
      }

      setState(() {
        _remainingSeconds = widget.qrData!.remainingSeconds;
      });

      // Stop timer khi hết giờ
      if (_remainingSeconds <= 0) {
        timer.cancel();
      }
    });
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

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
          // QR Code
          Container(
            width: context.space(200),
            height: context.space(200),
            decoration: BoxDecoration(
              color: widget.theme.primaryColor.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: widget.theme.primaryColor.withOpacity(0.2),
                width: 2,
              ),
            ),
            child: widget.qrData != null
                ? Center(
                    child: QrImageView(
                      data: widget.qrData!.token,
                      version: QrVersions.auto,
                      size: context.space(180),
                      backgroundColor: Colors.white,
                      errorStateBuilder: (ctx, err) {
                        return Center(
                          child: Text(
                            'QR Error',
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: context.sp(AppDimensions.fontXS),
                            ),
                          ),
                        );
                      },
                    ),
                  )
                : Center(
                    child: Text(
                      "No QR Code",
                      style: TextStyle(
                        fontSize: context.sp(AppDimensions.fontXS),
                        color: widget.theme.textSecondaryColor,
                      ),
                    ),
                  ),
          ),

          ResponsiveHelper.verticalSpace(context, AppDimensions.spaceM),

          // Expiry info
          if (widget.qrData != null) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.timer_outlined,
                  size: context.space(AppDimensions.iconS),
                  color: _remainingSeconds < 60
                      ? Colors.red
                      : widget.theme.textSecondaryColor,
                ),
                SizedBox(width: context.space(8)),
                Text(
                  'Expires in: ${_formatTime(_remainingSeconds)}',
                  style: TextStyle(
                    fontSize: context.sp(AppDimensions.fontXS),
                    color: _remainingSeconds < 60
                        ? Colors.red
                        : widget.theme.textSecondaryColor,
                    fontWeight: _remainingSeconds < 60
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              ],
            ),
            ResponsiveHelper.verticalSpace(context, AppDimensions.spaceS),

            // Refresh button
            TextButton.icon(
              onPressed: widget.onRefresh,
              icon: Icon(
                Icons.refresh,
                size: context.space(AppDimensions.iconS),
              ),
              label: Text(
                'Refresh QR',
                style: TextStyle(fontSize: context.sp(AppDimensions.fontXS)),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
