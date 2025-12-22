import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'auth_controller.dart';
import '../../core/theme/app_color.dart';
import '../../core/widgets/custom_text_field.dart';
import '../../core/utils/responsive_helper.dart';
import '../../core/constants/app_dimensions.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final authController = context.read<AuthController>();
    authController.clearError();

    final success = await authController.login(
      _emailController.text.trim(),
      _passwordController.text,
    );

    if (mounted) {
      if (success) {
        context.go('/home');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authController.errorMessage ?? 'Login failed'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authController = context.watch<AuthController>();

    return Scaffold(
      backgroundColor: AppColors.primary,
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
                    AppDimensions.spaceXXL,
                  ),
                  ResponsiveHelper.verticalSpace(context, AppDimensions.spaceL),

                  // Logo
                  Image.asset(
                    'assets/images/logo_login.png',
                    height: context.hp(context.isMobile ? 20 : 18),
                  ),

                  ResponsiveHelper.verticalSpace(
                    context,
                    AppDimensions.spaceXL,
                  ),

                  // Title
                  Text(
                    "Welcome to DuoDate",
                    style: TextStyle(
                      fontSize: context.sp(AppDimensions.fontXXL),
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF4E7C9F),
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

                  // Password Field
                  CustomTextField(
                    controller: _passwordController,
                    hintText: "Password",
                    isPassword: true,
                    obscureText: !authController.isPasswordVisible,
                    onToggleVisibility: authController.togglePasswordVisibility,
                  ),

                  ResponsiveHelper.verticalSpace(
                    context,
                    AppDimensions.spaceXL,
                  ),

                  // Login Button
                  GestureDetector(
                    onTap: authController.isLoading ? null : _handleLogin,
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                        vertical: context.space(15),
                      ),
                      decoration: BoxDecoration(
                        borderRadius: ResponsiveHelper.radius(
                          context,
                          AppDimensions.radiusXL,
                        ),
                        gradient: const LinearGradient(
                          colors: [Color(0xFF6A5AE0), Color(0xFFFF598B)],
                        ),
                      ),
                      child: Center(
                        child: authController.isLoading
                            ? SizedBox(
                                height: context.space(24),
                                width: context.space(24),
                                child: const CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                "Login",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: context.sp(AppDimensions.fontL),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ),

                  ResponsiveHelper.verticalSpace(context, AppDimensions.spaceM),

                  // Navigation Links
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                        onPressed: () => context.go('/register'),
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(0, 0),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          "Create account",
                          style: TextStyle(
                            color: const Color(0xFF6A5AE0),
                            fontSize: context.sp(AppDimensions.fontXS),
                          ),
                        ),
                      ),
                      SizedBox(width: context.space(8)),
                      Text(
                        "|",
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: context.sp(AppDimensions.fontXS),
                        ),
                      ),
                      SizedBox(width: context.space(8)),
                      TextButton(
                        onPressed: () {
                          // TODO: Navigate to forgot password page
                        },
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(0, 0),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          "Forgot password?",
                          style: TextStyle(
                            color: const Color(0xFF6A5AE0),
                            fontSize: context.sp(AppDimensions.fontXS),
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
