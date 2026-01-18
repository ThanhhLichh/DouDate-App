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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
