import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'home_controller.dart';
import 'widgets/home_skeleton.dart';
import 'widgets/home_header.dart';
import 'widgets/couple_card.dart';
import 'widgets/quote_card.dart';
import 'widgets/stats_grid.dart';
import 'widgets/home_error_state.dart';
import '../../core/utils/responsive_helper.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/providers/dashboard_theme_provider.dart';
import '../settings/theme_settings_page.dart';
import './models/home_models.dart';
import '../chat/chat_page.dart';
import '../memory/memories_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HomeController>().fetchDashboardData();
    });
  }

  Future<void> _handleRefresh() async {
    await context.read<HomeController>().refreshDashboard();
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
