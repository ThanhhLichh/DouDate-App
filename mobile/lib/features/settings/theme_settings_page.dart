import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../../core/providers/dashboard_theme_provider.dart';
import '../../core/theme/theme_presets.dart';
import '../../core/theme/dashboard_theme.dart';
// import '../../core/utils/color_validator.dart';

class ThemeSettingsPage extends StatefulWidget {
  const ThemeSettingsPage({super.key});

  @override
  State<ThemeSettingsPage> createState() => _ThemeSettingsPageState();
}

class _ThemeSettingsPageState extends State<ThemeSettingsPage> {
  final ImagePicker _picker = ImagePicker();
  bool _showAdvancedOptions = false;

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<DashboardThemeProvider>();
    final theme = themeProvider.currentTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Theme Customization'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _showResetDialog(context),
            tooltip: 'Reset Theme',
          ),
        ],
      ),
      body: themeProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Error message
                  if (themeProvider.errorMessage != null)
                    _buildErrorBanner(context, themeProvider),

                  // Current theme info
                  _buildCurrentThemeInfo(theme),

                  const SizedBox(height: 24),

                  // PHASE 1: Theme Presets
                  _buildSectionTitle('Theme Presets'),
                  const SizedBox(height: 12),
                  _buildThemePresets(context, themeProvider),

                  const SizedBox(height: 32),

                  // PHASE 2: Custom Background
                  _buildSectionTitle('Custom Background'),
                  const SizedBox(height: 12),
                  _buildBackgroundSection(context, themeProvider),

                  const SizedBox(height: 32),

                  // PHASE 2: Custom Colors
                  _buildSectionTitle('Custom Colors'),
                  const SizedBox(height: 12),
                  _buildQuickColorSection(context, themeProvider, theme),

                  const SizedBox(height: 16),

                  // Advanced color options (collapsible)
                  _buildAdvancedColorToggle(),

                  if (_showAdvancedOptions) ...[
                    const SizedBox(height: 16),
                    _buildAdvancedColorSection(context, themeProvider, theme),
                  ],

                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }

  Widget _buildErrorBanner(
    BuildContext context,
    DashboardThemeProvider provider,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red.shade700),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              provider.errorMessage!,
              style: TextStyle(color: Colors.red.shade700),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: provider.clearError,
            iconSize: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentThemeInfo(DashboardTheme theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: theme.primaryColor,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    theme.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    theme.isCustom ? 'Custom Theme' : 'Preset Theme',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
    );
  }

  // PHASE 1: Theme Presets Grid
  Widget _buildThemePresets(
    BuildContext context,
    DashboardThemeProvider provider,
  ) {
    final presets = ThemePresets.all;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.5,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: presets.length,
      itemBuilder: (context, index) {
        final preset = presets[index];
        final isSelected = provider.isPresetTheme(preset.id);

        return _buildPresetCard(context, preset, isSelected, () {
          provider.applyPreset(preset);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${preset.name} theme applied')),
          );
        });
      },
    );
  }

  Widget _buildPresetCard(
    BuildContext context,
    DashboardTheme preset,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? preset.primaryColor : Colors.grey.shade300,
            width: isSelected ? 3 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Color preview
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildColorCircle(preset.primaryColor, 24),
                const SizedBox(width: 8),
                _buildColorCircle(preset.accentColor, 24),
                const SizedBox(width: 8),
                _buildColorCircle(preset.heartIconColor, 24),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              preset.name,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 16,
              ),
            ),
            if (isSelected) ...[
              const SizedBox(height: 4),
              Icon(Icons.check_circle, color: preset.primaryColor, size: 20),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildColorCircle(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.grey.shade300),
      ),
    );
  }

  // PHASE 2: Background Image Section
  Widget _buildBackgroundSection(
    BuildContext context,
    DashboardThemeProvider provider,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Couple Background Image',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            FutureBuilder<bool>(
              future: provider.hasCustomBackground(),
              builder: (context, snapshot) {
                final hasCustom = snapshot.data ?? false;

                return Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _pickAndUploadBackground(provider),
                        icon: const Icon(Icons.upload),
                        label: Text(
                          hasCustom ? 'Change Image' : 'Upload Image',
                        ),
                      ),
                    ),
                    if (hasCustom) ...[
                      const SizedBox(width: 12),
                      IconButton(
                        onPressed: () => _removeBackground(context, provider),
                        icon: const Icon(Icons.delete),
                        color: Colors.red,
                        tooltip: 'Remove custom background',
                      ),
                    ],
                  ],
                );
              },
            ),
            const SizedBox(height: 8),
            Text(
              'Upload a custom background for your couple card',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }

  // PHASE 2: Quick Color Customization
  Widget _buildQuickColorSection(
    BuildContext context,
    DashboardThemeProvider provider,
    DashboardTheme theme,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Primary Colors',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            _buildColorOption(
              context,
              'Primary Color',
              theme.primaryColor,
              () => _pickColor(
                context,
                provider,
                'primaryColor',
                theme.primaryColor,
              ),
            ),
            const SizedBox(height: 12),
            _buildColorOption(
              context,
              'Accent Color',
              theme.accentColor,
              () => _pickColor(
                context,
                provider,
                'accentColor',
                theme.accentColor,
              ),
            ),
            const SizedBox(height: 12),
            _buildColorOption(
              context,
              'Heart Icon',
              theme.heartIconColor,
              () => _pickColor(
                context,
                provider,
                'heartIconColor',
                theme.heartIconColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdvancedColorToggle() {
    return InkWell(
      onTap: () {
        setState(() {
          _showAdvancedOptions = !_showAdvancedOptions;
        });
      },
      child: Row(
        children: [
          Icon(
            _showAdvancedOptions
                ? Icons.keyboard_arrow_up
                : Icons.keyboard_arrow_down,
          ),
          const SizedBox(width: 8),
          Text(
            _showAdvancedOptions
                ? 'Hide Advanced Options'
                : 'Show Advanced Options',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.blue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdvancedColorSection(
    BuildContext context,
    DashboardThemeProvider provider,
    DashboardTheme theme,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Advanced Color Settings',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            _buildColorOption(
              context,
              'Partner Border',
              theme.partnerBorderColor,
              () => _pickColor(
                context,
                provider,
                'partnerBorderColor',
                theme.partnerBorderColor,
              ),
            ),
            const SizedBox(height: 12),
            _buildColorOption(
              context,
              'Your Border',
              theme.yourBorderColor,
              () => _pickColor(
                context,
                provider,
                'yourBorderColor',
                theme.yourBorderColor,
              ),
            ),
            const SizedBox(height: 12),
            _buildColorOption(
              context,
              'Card Background',
              theme.cardBackground,
              () => _pickColor(
                context,
                provider,
                'cardBackground',
                theme.cardBackground,
              ),
            ),
            const SizedBox(height: 12),
            _buildColorOption(
              context,
              'Text Primary',
              theme.textPrimaryColor,
              () => _pickColor(
                context,
                provider,
                'textPrimaryColor',
                theme.textPrimaryColor,
              ),
            ),
            const SizedBox(height: 12),
            _buildColorOption(
              context,
              'Text Secondary',
              theme.textSecondaryColor,
              () => _pickColor(
                context,
                provider,
                'textSecondaryColor',
                theme.textSecondaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorOption(
    BuildContext context,
    String label,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(child: Text(label, style: const TextStyle(fontSize: 16))),
            const Icon(Icons.edit, size: 20),
          ],
        ),
      ),
    );
  }

  // Color Picker Dialog
  Future<void> _pickColor(
    BuildContext context,
    DashboardThemeProvider provider,
    String property,
    Color currentColor,
  ) async {
    Color pickedColor = currentColor;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Choose ${property.replaceAll('Color', '')}'),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: currentColor,
            onColorChanged: (color) {
              pickedColor = color;
            },
            pickerAreaHeightPercent: 0.8,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              provider.updateColor(property, pickedColor);
              Navigator.pop(context);
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Color updated')));
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  // Background Image Picker
  Future<void> _pickAndUploadBackground(DashboardThemeProvider provider) async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1920,
      maxHeight: 1920,
      imageQuality: 85,
    );

    if (image != null) {
      await provider.updateCoupleBackground(File(image.path));
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Background updated')));
      }
    }
  }

  Future<void> _removeBackground(
    BuildContext context,
    DashboardThemeProvider provider,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Background'),
        content: const Text(
          'Are you sure you want to remove the custom background?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await provider.removeCoupleBackground();
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Background removed')));
      }
    }
  }

  Future<void> _showResetDialog(BuildContext context) async {
    final provider = context.read<DashboardThemeProvider>();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Theme'),
        content: const Text('Choose what you want to reset:'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await provider.resetColors();
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('Colors reset')));
              }
            },
            child: const Text('Reset Colors Only'),
          ),
          ElevatedButton(
            onPressed: () async {
              await provider.resetToDefault();
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Theme reset to default')),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Reset Everything'),
          ),
        ],
      ),
    );
  }
}
