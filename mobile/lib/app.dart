import 'package:go_router/go_router.dart';
import '../../features/auth/login_page.dart';
import '../../features/auth/register_page.dart';
// import '../../features/home/home_page.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/login',
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterPage(),
      ),
      // GoRoute(
      //   path: '/home',
      //   builder: (context, state) => const HomePage(),
      // ),
    ],
  );
}
