import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:go_router/go_router.dart';

// Core
import 'core/providers/dashboard_theme_provider.dart';
import 'core/services/theme_storage_service.dart';
import 'core/services/image_storage_service.dart';
import 'core/services/auth_state_manager.dart';
import 'core/services/fcm_service.dart';

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

  // Initialize Firebase
  await Firebase.initializeApp();

  // Initialize FCM
  final fcmService = FCMService();
  await fcmService.initialize();

  final authStateManager = AuthStateManager();

  debugPrint('App starting - Initializing auth...');
  await authStateManager.initializeAuth();
  debugPrint('Auth initialized');

  // Init SharedPreferences
  final prefs = await SharedPreferences.getInstance();

  // Init services
  final themeStorageService = ThemeStorageService(prefs);
  final imageStorageService = ImageStorageService();

  runApp(
    MultiProvider(
      providers: [
        // Provide FCMService
        Provider.value(value: fcmService),

        ChangeNotifierProvider.value(value: authStateManager),

        // Auth
        ChangeNotifierProvider(
          create: (context) {
            final controller = AuthController();
            controller.setAuthStateManager(authStateManager);
            return controller;
          },
        ),

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
      child: MyApp(authStateManager: authStateManager),
    ),
  );
}

class MyApp extends StatefulWidget {
  final AuthStateManager authStateManager;

  const MyApp({super.key, required this.authStateManager});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();

    // Create router
    _router = AppRouter.createRouter(widget.authStateManager);

    // Setup FCM navigation callback
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final fcmService = context.read<FCMService>();
      fcmService.onNotificationTap = (data) {
        debugPrint('FCM notification tapped: $data');

        if (data['type'] == 'chat') {
          // Navigate to chat via home-couple
          _router.go('/home-couple', extra: {'openChat': true});
        }
      };
    });
  }

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

          routerConfig: _router,
        );
      },
    );
  }
}
