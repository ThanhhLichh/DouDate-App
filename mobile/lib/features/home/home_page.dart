import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'home_controller.dart';
import 'widgets/home_skeleton.dart';
import '../../core/theme/app_color.dart';
import '../../core/utils/responsive_helper.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/providers/dashboard_theme_provider.dart';
import '../../core/theme/theme_constants.dart';
import '../settings/theme_settings_page.dart';
import './models/home_models.dart';

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

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ThemeSettingsPage()),
          );
        },
        child: Icon(Icons.palette),
        tooltip: 'Customize Theme',
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    HomeController controller,
    CoupleDashboard? data,
    theme,
  ) {
    // Loading state with skeleton
    if (controller.isLoading || data == null) {
      return const HomePageSkeleton();
    }

    // Error state
    if (controller.errorMessage != null) {
      return _buildErrorState(context, controller, theme);
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
                _buildHeader(context, theme),

                ResponsiveHelper.verticalSpace(context, AppDimensions.spaceXL),

                // Couple Card
                _buildCoupleCard(context, data, theme),

                ResponsiveHelper.verticalSpace(context, AppDimensions.spaceL),

                // Daily Quote
                _buildQuoteCard(context, data.todayQuote, theme),

                ResponsiveHelper.verticalSpace(context, AppDimensions.spaceL),

                // Stats Grid
                _buildStatsGrid(context, data, theme),

                ResponsiveHelper.verticalSpace(context, AppDimensions.spaceL),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(
    BuildContext context,
    HomeController controller,
    theme,
  ) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: context.space(AppDimensions.iconXL),
            color: Colors.red,
          ),
          ResponsiveHelper.verticalSpace(context, AppDimensions.spaceM),
          Text(
            controller.errorMessage!,
            style: TextStyle(
              fontSize: context.sp(AppDimensions.fontM),
              color: theme.textSecondaryColor,
            ),
          ),
          ResponsiveHelper.verticalSpace(context, AppDimensions.spaceL),
          ElevatedButton(
            onPressed: () => controller.fetchDashboardData(),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.primaryColor,
              padding: EdgeInsets.symmetric(
                horizontal: context.space(30),
                vertical: context.space(15),
              ),
            ),
            child: Text(
              'Retry',
              style: TextStyle(fontSize: context.sp(AppDimensions.fontM)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, theme) {
    return Column(
      children: [
        Text(
          "DuoDate",
          style: TextStyle(
            fontSize: context.sp(AppDimensions.fontXXL),
            fontWeight: FontWeight.bold,
            color: theme.accentColor,
          ),
        ),
        Text(
          "Your love journey together",
          style: TextStyle(
            color: theme.textSecondaryColor,
            fontSize: context.sp(AppDimensions.fontS),
          ),
        ),
      ],
    );
  }

  Widget _buildCoupleCard(BuildContext context, CoupleDashboard data, theme) {
    return FutureBuilder<File?>(
      future: context.read<DashboardThemeProvider>().getCoupleBackgroundImage(),
      builder: (context, snapshot) {
        final hasCustomBackground = snapshot.hasData && snapshot.data != null;

        return Container(
          padding: EdgeInsets.symmetric(
            vertical: context.space(30),
            horizontal: context.space(20),
          ),
          decoration: BoxDecoration(
            image: hasCustomBackground
                ? DecorationImage(
                    image: FileImage(snapshot.data!),
                    fit: BoxFit.cover,
                    opacity: 0.95,
                  )
                : const DecorationImage(
                    image: AssetImage(ThemeConstants.defaultCoupleBackground),
                    fit: BoxFit.cover,
                    opacity: 0.95,
                  ),
            borderRadius: ResponsiveHelper.radius(
              context,
              AppDimensions.radiusXL,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 20,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildAvatar(
                    context,
                    data.partnerAvatar,
                    theme.partnerBorderColor,
                  ),
                  Icon(
                    Icons.favorite,
                    color: theme.heartIconColor,
                    size: context.space(AppDimensions.iconXL),
                  ),
                  _buildAvatar(context, data.yourAvatar, theme.yourBorderColor),
                ],
              ),
              ResponsiveHelper.verticalSpace(context, AppDimensions.spaceM),
              Text(
                "${data.partnerName}      &      ${data.yourName}",
                style: TextStyle(
                  color: theme.textPrimaryColor,
                  fontSize: context.sp(AppDimensions.fontL),
                  fontWeight: FontWeight.w600,
                ),
              ),
              ResponsiveHelper.verticalSpace(context, AppDimensions.spaceL),
              Text(
                "Together for",
                style: TextStyle(
                  color: theme.textPrimaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: context.sp(AppDimensions.fontS),
                ),
              ),
              ResponsiveHelper.verticalSpace(context, AppDimensions.spaceXS),
              Text(
                "${data.daysTogether}",
                style: TextStyle(
                  fontSize: context.sp(48),
                  fontWeight: FontWeight.bold,
                  color: theme.textPrimaryColor,
                ),
              ),
              Text(
                "beautiful days",
                style: TextStyle(
                  color: theme.textPrimaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: context.sp(AppDimensions.fontS),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAvatar(BuildContext context, String path, Color color) {
    return Container(
      padding: EdgeInsets.all(context.space(3)),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: color, width: context.space(2)),
      ),
      child: CircleAvatar(
        radius: context.space(40),
        backgroundImage: const AssetImage(ThemeConstants.defaultAvatar),
      ),
    );
  }

  Widget _buildStatsGrid(BuildContext context, CoupleDashboard data, theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: _buildStatCard(
            context,
            "Chat",
            "${data.messageCount / 1000}k",
            Icons.chat_bubble_outline,
            theme,
          ),
        ),
        ResponsiveHelper.horizontalSpace(context, AppDimensions.spaceM),
        Expanded(
          child: _buildStatCard(
            context,
            "Moments",
            "${data.momentCount}",
            Icons.camera_alt_outlined,
            theme,
          ),
        ),
        ResponsiveHelper.horizontalSpace(context, AppDimensions.spaceM),
        Expanded(
          child: _buildStatCard(
            context,
            "Memories",
            "${data.memoryCount}",
            Icons.star_outline,
            theme,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    theme,
  ) {
    return Container(
      padding: EdgeInsets.all(context.space(15)),
      decoration: BoxDecoration(
        color: theme.cardBackground,
        borderRadius: ResponsiveHelper.radius(context, AppDimensions.radiusL),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: theme.textSecondaryColor,
            size: context.space(AppDimensions.iconL),
          ),
          ResponsiveHelper.verticalSpace(context, AppDimensions.spaceS),
          Text(
            value,
            style: TextStyle(
              fontSize: context.sp(AppDimensions.fontL),
              fontWeight: FontWeight.bold,
              color: theme.textPrimaryColor,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: context.sp(AppDimensions.fontXXS),
              color: theme.textSecondaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuoteCard(BuildContext context, String quote, theme) {
    return Container(
      padding: EdgeInsets.all(context.space(20)),
      decoration: BoxDecoration(
        color: theme.cardBackground,
        borderRadius: ResponsiveHelper.radius(context, AppDimensions.radiusL),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            Icons.auto_awesome,
            color: theme.heartIconColor,
            size: context.space(AppDimensions.iconL),
          ),
          ResponsiveHelper.horizontalSpace(context, AppDimensions.spaceM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Today's Quote",
                  style: TextStyle(
                    color: theme.textSecondaryColor,
                    fontSize: context.sp(AppDimensions.fontXS),
                  ),
                ),
                ResponsiveHelper.verticalSpace(context, AppDimensions.spaceXS),
                Text(
                  "\"$quote\"",
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                    fontSize: context.sp(AppDimensions.fontS),
                    color: theme.textPrimaryColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context, theme) {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: (index) {
        if (index == 0) {
          context.read<HomeController>().fetchDashboardData();
        }

        setState(() {
          _selectedIndex = index;
        });
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
