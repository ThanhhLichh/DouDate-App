import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'features/auth/auth_controller.dart';
import '../core/services/storage_service.dart';
import 'routes/app_router.dart';

void main() async {
  // Đảm bảo Flutter đã khởi tạo xong các plugin (như secure storage)
  WidgetsFlutterBinding.ensureInitialized();

  // Kiểm tra token xem đã đăng nhập chưa
  final storageService = StorageService();
  final String? token = await storageService.getToken();

  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => AuthController())],
      // Truyền token vào để xử lý router ban đầu
      child: MyApp(isLoggedIn: token != null),
    ),
  );
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  const MyApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'DuoDate',
      // Bạn có thể tùy chỉnh initialLocation trong AppRouter dựa trên isLoggedIn
      routerConfig: AppRouter.router,
    );
  }
}
