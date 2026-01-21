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

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isNewPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleResetPassword() async {
    final authController = context.read<AuthController>();
    authController.clearError();

    final success = await authController.resetPassword(
      _newPasswordController.text,
      _confirmPasswordController.text,
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password reset successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      // Clear the forgot password session
      authController.clearForgotPasswordSession();

      // Navigate to login page
      context.go('/login');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            authController.errorMessage ?? 'Failed to reset password',
          ),
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
            context.go('/login');
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
                    title: "Reset Password",
                    color: Color(0xFF4E7C9F),
                  ),

                  ResponsiveHelper.verticalSpace(context, AppDimensions.spaceM),

                  // Description
                  Text(
                    "Please enter your new password",
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

                  // New Password Field
                  CustomTextField(
                    controller: _newPasswordController,
                    hintText: "New Password",
                    isPassword: true,
                    obscureText: !_isNewPasswordVisible,
                    onToggleVisibility: () {
                      setState(() {
                        _isNewPasswordVisible = !_isNewPasswordVisible;
                      });
                    },
                  ),

                  // Confirm Password Field
                  CustomTextField(
                    controller: _confirmPasswordController,
                    hintText: "Confirm Password",
                    isPassword: true,
                    obscureText: !_isConfirmPasswordVisible,
                    onToggleVisibility: () {
                      setState(() {
                        _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                      });
                    },
                  ),

                  ResponsiveHelper.verticalSpace(context, AppDimensions.spaceM),

                  // Password Requirements
                  Container(
                    padding: EdgeInsets.all(context.space(16)),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Password must contain:",
                          style: TextStyle(
                            fontSize: context.sp(AppDimensions.fontXS),
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF4E7C9F),
                          ),
                        ),
                        SizedBox(height: context.space(8)),
                        _buildRequirement("At least 8 characters"),
                        _buildRequirement("One uppercase letter (A-Z)"),
                        _buildRequirement("One lowercase letter (a-z)"),
                        _buildRequirement("One number (0-9)"),
                        _buildRequirement("One special character (!@#\$%^&*)"),
                      ],
                    ),
                  ),

                  ResponsiveHelper.verticalSpace(
                    context,
                    AppDimensions.spaceXL,
                  ),

                  // Reset Password Button
                  AuthButton(
                    text: "Reset Password",
                    isLoading: authController.isLoading,
                    onTap: _handleResetPassword,
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6A5AE0), Color(0xFFFF598B)],
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

  Widget _buildRequirement(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: context.space(4)),
      child: Row(
        children: [
          Icon(
            Icons.check_circle_outline,
            size: context.space(16),
            color: const Color(0xFF6A5AE0),
          ),
          SizedBox(width: context.space(8)),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: context.sp(AppDimensions.fontXS),
                color: Colors.grey[700],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
