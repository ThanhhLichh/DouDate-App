import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../controllers/auth_controller.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/utils/responsive_helper.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/theme/app_color.dart';
import '../widgets/auth_logo.dart';
import '../widgets/auth_title.dart';
import '../widgets/auth_button.dart';
import '../widgets/register_footer.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    final authController = context.read<AuthController>();
    authController.clearError();

    final success = await authController.register(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Registration successful! Connect with your partner.',
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
        // Navigate to HomeSinglePage để user kết nối với partner
        context.go('/home-single');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authController.errorMessage ?? 'Registration failed'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
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
                  ResponsiveHelper.verticalSpace(context, AppDimensions.spaceM),
                  ResponsiveHelper.verticalSpace(context, AppDimensions.spaceM),

                  // Logo
                  const AuthLogo(imagePath: 'assets/images/logo_register.png'),

                  ResponsiveHelper.verticalSpace(context, AppDimensions.spaceL),

                  // Title
                  const AuthTitle(
                    title: "Create Account",
                    color: Color(0xFF4E4E7C),
                  ),

                  ResponsiveHelper.verticalSpace(
                    context,
                    AppDimensions.spaceXL,
                  ),

                  // Name Field
                  CustomTextField(
                    controller: _nameController,
                    hintText: "Full Name",
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

                  ResponsiveHelper.verticalSpace(context, AppDimensions.spaceL),

                  // Register Button
                  AuthButton(
                    text: "Create Account",
                    isLoading: authController.isLoading,
                    onTap: _handleRegister,
                    gradient: authController.isLoading
                        ? LinearGradient(
                            colors: [Colors.grey[300]!, Colors.grey[400]!],
                          )
                        : AppColors.buttonGradient,
                  ),

                  ResponsiveHelper.verticalSpace(context, AppDimensions.spaceL),

                  // Back to Login
                  RegisterFooter(isLoading: authController.isLoading),

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
