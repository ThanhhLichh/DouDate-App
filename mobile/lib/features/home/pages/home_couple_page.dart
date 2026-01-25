import 'package:flutter/material.dart';
import '../../auth/controllers/auth_controller.dart';
import 'package:provider/provider.dart';
import '../controllers/home_controller.dart';
import '../widgets/couple/home_couple_skeleton.dart';
import '../widgets/couple/home_header.dart';
import '../widgets/couple/couple_card.dart';
import '../widgets/couple/quote_card.dart';
import '../widgets/couple/stats_grid.dart';
import '../widgets/couple/home_error_state.dart';
import '../../../core/utils/responsive_helper.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/providers/dashboard_theme_provider.dart';
import '../../../core/services/auth_state_manager.dart';
import '../../settings/theme_settings_page.dart';
import '../models/home_models.dart';
import '../../chat/pages/chat_page.dart';
import '../../memory/pages/memories_page.dart';
import '../../profile/pages/settings_page.dart';

class HomeCouplePage extends StatefulWidget {
  final bool openChat;

  const HomeCouplePage({super.key, this.openChat = false});

  @override
  State<HomeCouplePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomeCouplePage> {
  int _selectedIndex = 0;
  bool _hasNavigatedToChat = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializePage();

      // Auto navigate to chat nếu từ notification
      if (widget.openChat && !_hasNavigatedToChat) {
        _hasNavigatedToChat = true;
        _navigateToChat();
      }
    });
  }

  Future<void> _initializePage() async {
    final stillHasCouple = await _verifyCoupleConnection();

    if (!stillHasCouple) return;

    if (mounted) {
      context.read<HomeController>().fetchDashboardData();
    }
  }

  Future<void> _handleRefresh() async {
    final stillHasCouple = await _verifyCoupleConnection();

    if (!stillHasCouple) return;

    if (mounted) {
      await context.read<HomeController>().refreshDashboard();
    }
  }

  Future<bool> _verifyCoupleConnection() async {
    try {
      final authController = context.read<AuthController>();
      final homeController = context.read<HomeController>();
      final authStateManager = context.read<AuthStateManager>();
      final messenger = ScaffoldMessenger.of(context);

      final coupleStatus = await authController.checkCoupleStatus();

      if (!mounted) return false;

      if (coupleStatus == null || !coupleStatus.hasCouple) {
        debugPrint(
          'HomeCouplePage: Couple connection broken - navigating to single page',
        );

        await homeController.cleanupCoupleData();
        await authStateManager.recheckCoupleStatus();

        if (!mounted) return false;

        messenger.showSnackBar(
          const SnackBar(
            content: Text('Your connection has been ended'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 3),
          ),
        );

        return false;
      }

      return true;
    } catch (e) {
      debugPrint('HomeCouplePage: Error verifying couple connection - $e');
      return true;
    } finally {
      if (mounted) {
        setState(() {});
      }
    }
  }

  // Navigate to Chat Page
  void _navigateToChat() {
    debugPrint('Auto-navigating to chat from notification');
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ChatPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<HomeController>();
    final themeProvider = context.watch<DashboardThemeProvider>();
    final theme = themeProvider.currentTheme;
    final data = controller.dashboardData;

    return Scaffold(
      backgroundColor: theme.primaryColor,
      body: SafeArea(child: _buildBody(context, controller, data, theme)),
      bottomNavigationBar: _buildBottomNav(context, theme),
      floatingActionButton: _selectedIndex != 3
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ThemeSettingsPage()),
                );
              },
              tooltip: 'Customize Theme',
              child: Icon(Icons.palette),
            )
          : null,
    );
  }

  Widget _buildBody(
    BuildContext context,
    HomeController controller,
    CoupleDashboard? data,
    theme,
  ) {
    if (_selectedIndex == 3) {
      return const MemoriesPage();
    } else if (_selectedIndex == 4) {
      return const SettingsPage();
    }

    // Loading state with skeleton
    if (controller.isLoading || data == null) {
      return const HomePageSkeleton();
    }

    // Error state
    if (controller.errorMessage != null) {
      return HomeErrorState(
        errorMessage: controller.errorMessage!,
        onRetry: () => controller.fetchDashboardData(),
        theme: theme,
      );
    }

    // Success state with data
    return RefreshIndicator(
      onRefresh: _handleRefresh,
      color: theme.primaryColor,
      child: Center(
        child: Container(
          constraints: BoxConstraints(
            maxWidth: ResponsiveHelper.maxContentWidth(context),
          ),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: ResponsiveHelper.symmetric(
              context: context,
              horizontal: context.isMobile ? 5 : 8,
              vertical: 3,
            ),
            child: Column(
              children: [
                ResponsiveHelper.verticalSpace(context, AppDimensions.spaceM),

                // Header
                HomeHeader(theme: theme),

                ResponsiveHelper.verticalSpace(context, AppDimensions.spaceXL),

                // Couple Card
                CoupleCard(data: data, theme: theme),

                ResponsiveHelper.verticalSpace(context, AppDimensions.spaceL),

                // Daily Quote
                QuoteCard(quote: data.todayQuote, theme: theme),

                ResponsiveHelper.verticalSpace(context, AppDimensions.spaceL),

                // Stats Grid
                StatsGrid(data: data, theme: theme),

                ResponsiveHelper.verticalSpace(context, AppDimensions.spaceL),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context, theme) {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: (index) {
        if (index == 0) {
          context.read<HomeController>().fetchDashboardData();
          setState(() {
            _selectedIndex = 0;
          });
        } else if (index == 1) {
          // Navigate to Chat (direct to chat room, no list)
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ChatPage()),
          );
          return; // Don't update selected index
        } else if (index == 3) {
          // Memories - switch tab (giữ bottom nav)
          setState(() {
            _selectedIndex = 3;
          });
        } else if (index == 4) {
          // Settings - switch tab (giữ bottom nav)
          setState(() {
            _selectedIndex = 4;
          });
        } else {
          // Other tabs
          setState(() {
            _selectedIndex = index;
          });
        }
      },
      type: BottomNavigationBarType.fixed,
      selectedItemColor: theme.primaryColor,
      unselectedItemColor: theme.textSecondaryColor,
      selectedFontSize: context.sp(AppDimensions.fontXS),
      unselectedFontSize: context.sp(AppDimensions.fontXXS),
      iconSize: context.space(AppDimensions.iconM),
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
        BottomNavigationBarItem(icon: Icon(Icons.chat), label: "Chat"),
        BottomNavigationBarItem(
          icon: Icon(Icons.photo_library),
          label: "Moments",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_today),
          label: "Memories",
        ),
        BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Settings"),
      ],
    );
  }
}
