import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../controllers/auth_controller.dart';
import '../../../core/theme/app_color.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/utils/responsive_helper.dart';
import '../../../core/constants/app_dimensions.dart';
import '../widgets/auth_logo.dart';
import '../widgets/auth_title.dart';
import '../widgets/auth_button.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleSendOtp() async {
    final authController = context.read<AuthController>();
    authController.clearError();

    final success = await authController.sendOtpToEmail(
      _emailController.text.trim(),
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('OTP has been sent to your email'),
          backgroundColor: Colors.green,
        ),
      );
      context.push('/verify-otp');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authController.errorMessage ?? 'Failed to send OTP'),
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
          onPressed: () => context.pop(),
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
                    title: "Forgot Password",
                    color: Color(0xFF4E7C9F),
                  ),

                  ResponsiveHelper.verticalSpace(context, AppDimensions.spaceM),

                  // Description
                  Text(
                    "Enter your email address and we'll send you a code to reset your password",
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

                  // Email Field
                  CustomTextField(
                    controller: _emailController,
                    hintText: "Email",
                  ),

                  ResponsiveHelper.verticalSpace(
                    context,
                    AppDimensions.spaceXL,
                  ),

                  // Send OTP Button
                  AuthButton(
                    text: "Send OTP",
                    isLoading: authController.isLoading,
                    onTap: _handleSendOtp,
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6A5AE0), Color(0xFFFF598B)],
                    ),
                  ),

                  ResponsiveHelper.verticalSpace(context, AppDimensions.spaceM),

                  // Back to Login
                  TextButton(
                    onPressed: () => context.pop(),
                    child: Text(
                      "Back to Login",
                      style: TextStyle(
                        color: const Color(0xFF6A5AE0),
                        fontSize: context.sp(AppDimensions.fontS),
                      ),
                    ),
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
