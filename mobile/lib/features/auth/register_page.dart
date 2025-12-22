import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'auth_controller.dart';
import '../../core/widgets/custom_text_field.dart';
import '../../core/utils/responsive_helper.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/theme/app_color.dart';

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
            content: Text('Registration successful!'),
            backgroundColor: Colors.green,
          ),
        );
        context.go('/home');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authController.errorMessage ?? 'Registration failed'),
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
                  ResponsiveHelper.verticalSpace(context, AppDimensions.spaceM),
                  ResponsiveHelper.verticalSpace(context, AppDimensions.spaceM),

                  // Logo
                  Image.asset(
                    'assets/images/logo_register.png',
                    height: context.hp(context.isMobile ? 18 : 16),
                  ),

                  ResponsiveHelper.verticalSpace(context, AppDimensions.spaceL),

                  // Title
                  Text(
                    "Create Account",
                    style: TextStyle(
                      fontSize: context.sp(AppDimensions.fontXXL),
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF4E4E7C),
                    ),
                  ),

                  ResponsiveHelper.verticalSpace(context, AppDimensions.spaceM),

                  // Avatar Picker
                  GestureDetector(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Avatar picker coming soon!'),
                        ),
                      );
                    },
                    child: CircleAvatar(
                      radius: context.space(AppDimensions.avatarL / 2),
                      backgroundColor: Colors.white,
                      child: Icon(
                        Icons.camera_alt_outlined,
                        size: context.space(AppDimensions.iconXL),
                        color: Colors.grey[400],
                      ),
                    ),
                  ),

                  ResponsiveHelper.verticalSpace(
                    context,
                    AppDimensions.spaceXL,
                  ),

                  // Name Field
                  CustomTextField(
                    controller: _nameController,
                    hintText: "Name",
                  ),

                  // Email Field
                  CustomTextField(
                    controller: _emailController,
                    hintText: "Email or Phone",
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

                  // Register Button
                  GestureDetector(
                    onTap: authController.isLoading ? null : _handleRegister,
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
                        gradient: AppColors.buttonGradient,
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
                                "Create Account",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: context.sp(AppDimensions.fontL),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ),

                  ResponsiveHelper.verticalSpace(context, AppDimensions.spaceL),

                  // Back to Login
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Already have an account?",
                        style: TextStyle(
                          fontSize: context.sp(AppDimensions.fontS),
                        ),
                      ),
                      TextButton(
                        onPressed: () => context.go('/login'),
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                            horizontal: context.space(4),
                          ),
                        ),
                        child: Text(
                          "Login",
                          style: TextStyle(
                            color: const Color(0xFF6A5AE0),
                            fontSize: context.sp(AppDimensions.fontS),
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
