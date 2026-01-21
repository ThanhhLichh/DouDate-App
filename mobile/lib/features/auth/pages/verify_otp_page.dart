import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../controllers/auth_controller.dart';
import '../../../core/theme/app_color.dart';
import '../../../core/utils/responsive_helper.dart';
import '../../../core/constants/app_dimensions.dart';
import '../widgets/auth_logo.dart';
import '../widgets/auth_title.dart';
import '../widgets/auth_button.dart';
import 'dart:async';

class VerifyOtpPage extends StatefulWidget {
  const VerifyOtpPage({super.key});

  @override
  State<VerifyOtpPage> createState() => _VerifyOtpPageState();
}

class _VerifyOtpPageState extends State<VerifyOtpPage> {
  final List<TextEditingController> _controllers = List.generate(
    6,
    (index) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());

  Timer? _timer;
  int _remainingSeconds = 300; // 5 minutes

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        _timer?.cancel();
      }
    });
  }

  String get _timerText {
    int minutes = _remainingSeconds ~/ 60;
    int seconds = _remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  String _getOtpCode() {
    return _controllers.map((c) => c.text).join();
  }

  Future<void> _handleVerifyOtp() async {
    final otp = _getOtpCode();

    if (otp.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter all 6 digits'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final authController = context.read<AuthController>();
    authController.clearError();

    final success = await authController.verifyOtp(otp);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('OTP verified successfully'),
          backgroundColor: Colors.green,
        ),
      );
      context.push('/reset-password');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authController.errorMessage ?? 'Invalid OTP'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _handleResendOtp() async {
    if (_remainingSeconds > 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please wait $_timerText before resending'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final authController = context.read<AuthController>();
    final email = authController.userEmail;

    if (email == null) {
      context.go('/forgot-password');
      return;
    }

    final success = await authController.sendOtpToEmail(email);

    if (!mounted) return;

    if (success) {
      setState(() {
        _remainingSeconds = 300;
        for (var controller in _controllers) {
          controller.clear();
        }
      });
      _startTimer();
      _focusNodes[0].requestFocus();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('New OTP has been sent'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authController.errorMessage ?? 'Failed to resend OTP'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authController = context.watch<AuthController>();

    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF4E7C9F)),
          onPressed: () {
            authController.clearForgotPasswordSession();
            context.pop();
          },
        ),
      ),
      body: SafeArea(
        child: Center(
          child: Container(
            constraints: BoxConstraints(
              maxWidth: ResponsiveHelper.maxContentWidth(context),
            ),
            child: SingleChildScrollView(
              padding: ResponsiveHelper.symmetric(
                context: context,
                horizontal: context.isMobile ? 8 : 12,
              ),
              child: Column(
                children: [
                  ResponsiveHelper.verticalSpace(
                    context,
                    AppDimensions.spaceXL,
                  ),

                  // Logo
                  const AuthLogo(imagePath: 'assets/images/logo_login.png'),

                  ResponsiveHelper.verticalSpace(
                    context,
                    AppDimensions.spaceXL,
                  ),

                  // Title
                  const AuthTitle(
                    title: "Verify OTP",
                    color: Color(0xFF4E7C9F),
                  ),

                  ResponsiveHelper.verticalSpace(context, AppDimensions.spaceM),

                  // Description
                  Text(
                    "Enter the 6-digit code sent to\n${authController.userEmail ?? ''}",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: context.sp(AppDimensions.fontS),
                    ),
                  ),

                  ResponsiveHelper.verticalSpace(
                    context,
                    AppDimensions.spaceXL,
                  ),

                  // OTP Input Fields
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(6, (index) {
                      return SizedBox(
                        width: context.space(50),
                        height: context.space(60),
                        child: TextField(
                          controller: _controllers[index],
                          focusNode: _focusNodes[index],
                          textAlign: TextAlign.center,
                          keyboardType: TextInputType.number,
                          maxLength: 1,
                          style: TextStyle(
                            fontSize: context.sp(20),
                            fontWeight: FontWeight.bold,
                            height: 1.0,
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          decoration: InputDecoration(
                            counterText: '',
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: EdgeInsets.zero,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Color(0xFF6A5AE0),
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Color(0xFF6A5AE0),
                                width: 2,
                              ),
                            ),
                          ),
                          onChanged: (value) {
                            if (value.isNotEmpty && index < 5) {
                              _focusNodes[index + 1].requestFocus();
                            } else if (value.isEmpty && index > 0) {
                              _focusNodes[index - 1].requestFocus();
                            }
                          },
                        ),
                      );
                    }),
                  ),

                  ResponsiveHelper.verticalSpace(context, AppDimensions.spaceL),

                  // Timer
                  Text(
                    'Code expires in: $_timerText',
                    style: TextStyle(
                      color: _remainingSeconds < 60
                          ? Colors.red
                          : Colors.grey[600],
                      fontSize: context.sp(AppDimensions.fontS),
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  ResponsiveHelper.verticalSpace(
                    context,
                    AppDimensions.spaceXL,
                  ),

                  // Verify Button
                  AuthButton(
                    text: "Verify",
                    isLoading: authController.isLoading,
                    onTap: _handleVerifyOtp,
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6A5AE0), Color(0xFFFF598B)],
                    ),
                  ),

                  ResponsiveHelper.verticalSpace(context, AppDimensions.spaceM),

                  // Resend OTP
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Didn't receive the code? ",
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: context.sp(AppDimensions.fontS),
                        ),
                      ),
                      TextButton(
                        onPressed: _handleResendOtp,
                        child: Text(
                          "Resend",
                          style: TextStyle(
                            color: const Color(0xFF6A5AE0),
                            fontSize: context.sp(AppDimensions.fontS),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),

                  ResponsiveHelper.verticalSpace(context, AppDimensions.spaceL),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
