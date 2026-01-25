import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/services/auth_state_manager.dart';
import '../features/auth/pages/login_page.dart';
import '../features/auth/pages/register_page.dart';
import '../features/auth/pages/forgot_password_page.dart';
import '../features/auth/pages/verify_otp_page.dart';
import '../features/auth/pages/reset_password_page.dart';
import '../features/home/pages/home_couple_page.dart';
import '../features/home/pages/home_single_page.dart';

class AppRouter {
  static GoRouter createRouter(AuthStateManager authStateManager) {
    return GoRouter(
      initialLocation: '/login',
      refreshListenable: authStateManager,

      // REDIRECT LOGIC - Tự động điều hướng dựa trên auth state
      redirect: (context, state) {
        final isAuthenticated = authStateManager.isAuthenticated;
        final isLoading = authStateManager.isLoading;
        final routeType = authStateManager.routeType;
        final currentPath = state.uri.path;

        debugPrint('Router redirect check:');
        debugPrint('Current path: $currentPath');
        debugPrint('Is authenticated: $isAuthenticated');
        debugPrint('Is loading: $isLoading');
        debugPrint('Route type: ${routeType.name}');

        // Đang loading - giữ nguyên route hiện tại
        if (isLoading) {
          debugPrint('Loading, stay on current route');
          return null;
        }

        // Danh sách public routes (không cần auth)
        final publicRoutes = [
          '/login',
          '/register',
          '/forgot-password',
          '/verify-otp',
          '/reset-password',
        ];

        final isPublicRoute = publicRoutes.contains(currentPath);

        // CASE 1: User CHƯA authenticated

        if (!isAuthenticated) {
          if (isPublicRoute) {
            debugPrint('Unauthenticated on public route, allow');
            return null; // Cho phép truy cập public routes
          } else {
            debugPrint(
              'Unauthenticated trying protected route, redirect to login',
            );
            return '/login';
          }
        }

        // CASE 2: User ĐÃ authenticated

        if (isAuthenticated) {
          // Nếu đang ở public route → redirect về home tương ứng
          if (isPublicRoute) {
            if (routeType == UserRouteType.couple) {
              debugPrint(
                'Authenticated on public route, redirect to couple home',
              );
              return '/home-couple';
            } else if (routeType == UserRouteType.single) {
              debugPrint(
                'Authenticated on public route, redirect to single home',
              );
              return '/home-single';
            }
          }

          // Nếu đang ở home-couple nhưng không có couple → redirect về single
          if (currentPath == '/home-couple' &&
              routeType == UserRouteType.single) {
            debugPrint('On couple page but no couple, redirect to single');
            return '/home-single';
          }

          // Nếu đang ở home-single nhưng có couple → redirect về couple
          if (currentPath == '/home-single' &&
              routeType == UserRouteType.couple) {
            debugPrint('On single page but has couple, redirect to couple');
            return '/home-couple';
          }
        }

        debugPrint('No redirect needed');
        return null; // Không cần redirect
      },

      // ROUTES DEFINITION
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
          builder: (context, state) {
            // Nhận extra data từ FCM navigation
            final extra = state.extra as Map<String, dynamic>?;
            final openChat = extra?['openChat'] as bool? ?? false;

            return HomeCouplePage(openChat: openChat);
          },
        ),
      ],

      // Error page
      errorBuilder: (context, state) =>
          Scaffold(body: Center(child: Text('Page not found: ${state.uri}'))),
    );
  }
}
