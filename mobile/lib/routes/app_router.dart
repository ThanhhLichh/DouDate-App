import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../features/auth/login_page.dart';
import '../features/auth/register_page.dart';
import '../features/home/home_couple_page.dart';
import '../features/home/home_single_page.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation:
        '/login', // Có thể dùng logic để đổi thành /home nếu đã có token
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
