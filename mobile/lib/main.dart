import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Core
import 'core/providers/dashboard_theme_provider.dart';
import 'core/services/theme_storage_service.dart';
import 'core/services/image_storage_service.dart';
import 'core/services/storage_service.dart';

// Features
import 'features/auth/controllers/auth_controller.dart';
import 'features/home/controllers/home_controller.dart';
import 'features/chat/controllers/chat_controller.dart';
import 'features/chat/controllers/conversation_controller.dart';
import 'features/memory/controllers/memory_controller.dart';
import 'features/profile/controllers/settings_controller.dart';

// Router
import 'routes/app_router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Check login token
  final storageService = StorageService();
  final String? token = await storageService.getToken();

  // Init SharedPreferences
  final prefs = await SharedPreferences.getInstance();

  // Init services
  final themeStorageService = ThemeStorageService(prefs);
  final imageStorageService = ImageStorageService();

  runApp(
    MultiProvider(
      providers: [
        // Auth
        ChangeNotifierProvider(create: (_) => AuthController()),

        // Home
        ChangeNotifierProvider(create: (_) => HomeController()),

        // Conversation
        ChangeNotifierProvider(create: (_) => ConversationController()),

        // Chat
        ChangeNotifierProxyProvider2<
          ConversationController,
          HomeController,
          ChatController
        >(
          create: (context) => ChatController(
            conversationController: context.read<ConversationController>(),
            homeController: context.read<HomeController>(),
          ),
          update:
              (
                context,
                conversationController,
                homeController,
                previousChatController,
              ) =>
                  previousChatController ??
                  ChatController(
                    conversationController: conversationController,
                    homeController: homeController,
                  ),
        ),

        // Memory
        ChangeNotifierProvider(create: (_) => MemoryController()),

        // Settings
        ChangeNotifierProvider(create: (_) => SettingsController()),

        // Theme
        ChangeNotifierProvider(
          create: (_) => DashboardThemeProvider(
            storageService: themeStorageService,
            imageService: imageStorageService,
          ),
        ),
      ],
      child: MyApp(isLoggedIn: token != null),
    ),
  );
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;

  const MyApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return Consumer<DashboardThemeProvider>(
      builder: (context, themeProvider, _) {
        final theme = themeProvider.currentTheme;

        return MaterialApp.router(
          debugShowCheckedModeBanner: false,
          title: 'DuoDate',

          // Theme
          theme: ThemeData(
            useMaterial3: true,
            primaryColor: theme.primaryColor,
            colorScheme: ColorScheme.fromSeed(
              seedColor: theme.primaryColor,
              primary: theme.primaryColor,
              secondary: theme.accentColor,
            ),
          ),

          // Router
          routerConfig: AppRouter.router,
        );
      },
    );
  }
}
