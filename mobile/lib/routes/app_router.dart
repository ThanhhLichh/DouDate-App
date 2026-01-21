import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../features/auth/pages/login_page.dart';
import '../features/auth/pages/register_page.dart';
import '../features/auth/pages/forgot_password_page.dart';
import '../features/auth/pages/verify_otp_page.dart';
import '../features/auth/pages/reset_password_page.dart';
import '../features/home/pages/home_couple_page.dart';
import '../features/home/pages/home_single_page.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/login',
    routes: [
      // Auth Routes
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: '/forgot-password',
        name: 'forgot-password',
        builder: (context, state) => const ForgotPasswordPage(),
      ),
      GoRoute(
        path: '/verify-otp',
        name: 'verify-otp',
        builder: (context, state) => const VerifyOtpPage(),
      ),
      GoRoute(
        path: '/reset-password',
        name: 'reset-password',
        builder: (context, state) => const ResetPasswordPage(),
      ),

      // Home Single
      GoRoute(
        path: '/home-single',
        name: 'home-single',
        builder: (context, state) => const HomeSinglePage(),
      ),

      // Home Couple
      GoRoute(
        path: '/home-couple',
        name: 'home-couple',
        builder: (context, state) => const HomeCouplePage(),
      ),
    ],
    errorBuilder: (context, state) =>
        Scaffold(body: Center(child: Text('Page not found: ${state.uri}'))),
  );
}
