import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/utils/responsive_helper.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/providers/dashboard_theme_provider.dart';
import 'widgets/settings_header.dart';
import 'widgets/profile_avatar.dart';
import 'widgets/profile_info_field.dart';
import 'widgets/connection_status_card.dart';
import 'widgets/settings_section.dart';
import 'widgets/settings_item.dart';
import 'widgets/logout_button.dart';
import 'widgets/settings_skeleton.dart';
import 'settings_controller.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SettingsController>().loadUserProfile();
    });
  }

  Future<void> _handleRefresh() async {
    await context.read<SettingsController>().loadUserProfile();
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<SettingsController>();
    final themeProvider = context.watch<DashboardThemeProvider>();
    final theme = themeProvider.currentTheme;

    return Scaffold(
      backgroundColor: theme.primaryColor.withOpacity(0.1),
      body: SafeArea(child: _buildBody(controller, theme)),
    );
  }

  Widget _buildBody(SettingsController controller, dynamic theme) {
    // Loading state
    if (controller.isLoading) {
      return const SettingsPageSkeleton();
    }

    // Main content with refresh indicator
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
                SettingsHeader(theme: theme),

                ResponsiveHelper.verticalSpace(context, AppDimensions.spaceXL),

                // Profile Avatar
                ProfileAvatar(
                  avatarUrl: controller.userProfile?.avatarUrl,
                  onEdit: controller.updateAvatar,
                  theme: theme,
                ),

                ResponsiveHelper.verticalSpace(context, AppDimensions.spaceL),

                // Profile Section
                SettingsSection(title: 'Profile', theme: theme),

                ResponsiveHelper.verticalSpace(context, AppDimensions.spaceM),

                // Profile Info
                ProfileInfoField(
                  label: 'Name',
                  value: controller.userProfile?.name ?? 'Loading...',
                  onEdit: () => _showEditDialog(
                    context,
                    'Edit Name',
                    controller.userProfile?.name ?? '',
                    (value) => controller.updateName(value),
                  ),
                  theme: theme,
                ),

                ResponsiveHelper.verticalSpace(context, AppDimensions.spaceM),

                ProfileInfoField(
                  label: 'Birthday',
                  value: controller.userProfile?.birthday ?? 'Not set',
                  onEdit: () => _showDatePicker(context, controller),
                  theme: theme,
                ),

                ResponsiveHelper.verticalSpace(context, AppDimensions.spaceM),

                ProfileInfoField(
                  label: 'Gender',
                  value: controller.userProfile?.gender ?? 'Not set',
                  onEdit: () => _showGenderPicker(context, controller),
                  theme: theme,
                ),

                ResponsiveHelper.verticalSpace(context, AppDimensions.spaceM),

                // Connection Status
                ConnectionStatusCard(
                  partnerName: controller.userProfile?.partnerName,
                  isConnected: controller.userProfile?.isConnected ?? false,
                  onBreakConnection: () =>
                      _showBreakConnectionDialog(context, controller),
                  theme: theme,
                ),

                ResponsiveHelper.verticalSpace(context, AppDimensions.spaceXL),

                // Settings Section
                SettingsSection(title: 'Settings', theme: theme),

                ResponsiveHelper.verticalSpace(context, AppDimensions.spaceM),

                // Settings Items
                SettingsItem(
                  icon: Icons.notifications_outlined,
                  title: 'Notifications',
                  hasSwitch: true,
                  switchValue: controller.notificationsEnabled,
                  onSwitchChanged: controller.toggleNotifications,
                  theme: theme,
                ),

                ResponsiveHelper.verticalSpace(context, AppDimensions.spaceS),

                SettingsItem(
                  icon: Icons.lock_outline,
                  title: 'Privacy',
                  onTap: () {
                    // Navigate to Privacy page
                  },
                  theme: theme,
                ),

                ResponsiveHelper.verticalSpace(context, AppDimensions.spaceS),

                SettingsItem(
                  icon: Icons.help_outline,
                  title: 'Help & Support',
                  onTap: () {
                    // Navigate to Help page
                  },
                  theme: theme,
                ),

                ResponsiveHelper.verticalSpace(context, AppDimensions.spaceXL),

                // Logout Button
                LogoutButton(
                  onLogout: () => _showLogoutDialog(context, controller),
                  theme: theme,
                ),

                ResponsiveHelper.verticalSpace(context, AppDimensions.spaceL),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showEditDialog(
    BuildContext context,
    String title,
    String currentValue,
    Function(String) onSave,
  ) {
    final controller = TextEditingController(text: currentValue);
    final theme = context.read<DashboardThemeProvider>().currentTheme;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(hintText: 'Enter $title'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: theme.textSecondaryColor),
            ),
          ),
          TextButton(
            onPressed: () {
              onSave(controller.text);
              Navigator.pop(context);
            },
            child: Text('Save', style: TextStyle(color: theme.primaryColor)),
          ),
        ],
      ),
    );
  }

  void _showDatePicker(BuildContext context, SettingsController controller) {
    showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    ).then((date) {
      if (date != null) {
        controller.updateBirthday(date);
      }
    });
  }

  void _showGenderPicker(BuildContext context, SettingsController controller) {
    final theme = context.read<DashboardThemeProvider>().currentTheme;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Gender'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Male'),
              onTap: () {
                controller.updateGender('Male');
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Female'),
              onTap: () {
                controller.updateGender('Female');
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Other'),
              onTap: () {
                controller.updateGender('Other');
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showBreakConnectionDialog(
    BuildContext context,
    SettingsController controller,
  ) {
    final theme = context.read<DashboardThemeProvider>().currentTheme;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Break Connection'),
        content: const Text(
          'Are you sure you want to break the connection? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: theme.textSecondaryColor),
            ),
          ),
          TextButton(
            onPressed: () {
              controller.breakConnection();
              Navigator.pop(context);
            },
            child: Text(
              'Break Connection',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, SettingsController controller) {
    final theme = context.read<DashboardThemeProvider>().currentTheme;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Log Out'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: theme.textSecondaryColor),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context); // Close dialog first

              // Show loading indicator
              if (!mounted) return;
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) =>
                    const Center(child: CircularProgressIndicator()),
              );

              // Perform logout
              final success = await controller.logout();

              // Close loading dialog
              if (!context.mounted) return;
              Navigator.pop(context);

              if (success) {
                if (!context.mounted) return;
                context.go('/login');
              } else {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Logout failed. Please try again.'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Log Out', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
