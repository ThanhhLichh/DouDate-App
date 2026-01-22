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
import '../widgets/login_footer.dart';
import '../widgets/social_auth_button.dart';

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

    if (!mounted) return;

    if (success) {
      final coupleStatus = await authController.checkCoupleStatus();

      if (!mounted) return;

      if (coupleStatus != null && coupleStatus.hasCouple) {
        context.go('/home-couple');
      } else {
        context.go('/home-single');
      }
    } else {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authController.errorMessage ?? 'Login failed'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _handleGoogleLogin() async {
    final authController = context.read<AuthController>();

    final success = await authController.loginWithGoogle();

    if (!mounted) return;

    if (success) {
      final coupleStatus = await authController.checkCoupleStatus();

      if (!mounted) return;

      if (coupleStatus != null && coupleStatus.hasCouple) {
        context.go('/home-couple');
      } else {
        context.go('/home-single');
      }
    } else {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authController.errorMessage ?? 'Google login failed'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showComingSoon(String platform) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$platform login coming soon!'),
        backgroundColor: Colors.blue,
      ),
    );
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
                horizontal: context.isMobile ? 6 : 8,
              ),
              child: Column(
                children: [
                  ResponsiveHelper.verticalSpace(
                    context,
                    AppDimensions.spaceXXL,
                  ),
                  ResponsiveHelper.verticalSpace(context, AppDimensions.spaceL),

                  // Logo
                  const AuthLogo(imagePath: 'assets/images/logo_login.png'),

                  ResponsiveHelper.verticalSpace(
                    context,
                    AppDimensions.spaceXL,
                  ),

                  // Title
                  const AuthTitle(
                    title: "Welcome to DuoDate",
                    color: Color(0xFF4E7C9F),
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
                  AuthButton(
                    text: "Login",
                    isLoading: authController.isLoading,
                    onTap: _handleLogin,
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6A5AE0), Color(0xFFFF598B)],
                    ),
                  ),

                  ResponsiveHelper.verticalSpace(context, AppDimensions.spaceM),

                  // Navigation Links
                  const LoginFooter(),

                  ResponsiveHelper.verticalSpace(context, AppDimensions.spaceL),

                  Row(
                    children: [
                      Expanded(child: Divider(color: Colors.grey[400])),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: context.space(AppDimensions.paddingM),
                        ),
                        child: Text(
                          'Or sign in using',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: context.sp(AppDimensions.fontS),
                          ),
                        ),
                      ),
                      Expanded(child: Divider(color: Colors.grey[400])),
                    ],
                  ),

                  ResponsiveHelper.verticalSpace(context, AppDimensions.spaceL),

                  // Social Auth Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Google Button
                      SocialAuthButton(
                        iconPath: 'assets/icons/google.png',
                        onTap: _handleGoogleLogin,
                        isEnabled: !authController.isLoading,
                      ),

                      ResponsiveHelper.horizontalSpace(
                        context,
                        AppDimensions.spaceM,
                      ),

                      // Apple Button
                      SocialAuthButton(
                        iconPath: 'assets/icons/apple-logo.png',
                        onTap: () => _showComingSoon('Apple'),
                        isEnabled: !authController.isLoading,
                      ),

                      ResponsiveHelper.horizontalSpace(
                        context,
                        AppDimensions.spaceM,
                      ),

                      // Facebook Button
                      SocialAuthButton(
                        iconPath: 'assets/icons/facebook.png',
                        onTap: () => _showComingSoon('Facebook'),
                        isEnabled: !authController.isLoading,
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
