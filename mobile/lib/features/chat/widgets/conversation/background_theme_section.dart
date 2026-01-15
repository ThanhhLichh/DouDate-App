import 'package:flutter/material.dart';
import '../../../../core/utils/responsive_helper.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../controllers/conversation_controller.dart';
import '../../models/conversation_settings_models.dart';

class BackgroundThemeSection extends StatelessWidget {
  final ConversationController controller;
  final ConversationSettings? settings;

  const BackgroundThemeSection({
    super.key,
    required this.controller,
    this.settings,
  });

  @override
  Widget build(BuildContext context) {
    final currentTheme =
        settings?.backgroundTheme ?? BackgroundTheme.defaultTheme;

    return Container(
      color: Colors.white,
      padding: EdgeInsets.all(context.space(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Chat Background',
            style: TextStyle(
              fontSize: context.sp(AppDimensions.fontM),
              fontWeight: FontWeight.bold,
            ),
          ),
          ResponsiveHelper.verticalSpace(context, AppDimensions.spaceS),
          Text(
            'Message color will be adjusted automatically',
            style: TextStyle(
              fontSize: context.sp(AppDimensions.fontXS),
              color: Colors.grey[600],
            ),
          ),
          ResponsiveHelper.verticalSpace(context, AppDimensions.spaceM),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: context.space(12),
              mainAxisSpacing: context.space(12),
              childAspectRatio: 1,
            ),
            itemCount: BackgroundTheme.values.length,
            itemBuilder: (context, index) {
              final theme = BackgroundTheme.values[index];
              final isSelected = currentTheme == theme;

              return GestureDetector(
                onTap: () async {
                  final success = await controller.updateBackgroundTheme(theme);
                  if (success && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Background theme updated!'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  }
                },
                child: Container(
                  decoration: BoxDecoration(
                    gradient: theme.previewGradient,
                    borderRadius: BorderRadius.circular(context.space(12)),
                    border: isSelected
                        ? Border.all(color: const Color(0xFF0084FF), width: 3)
                        : Border.all(color: Colors.grey[300]!, width: 1),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        bottom: context.space(8),
                        left: 0,
                        right: 0,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: context.space(4),
                            vertical: context.space(4),
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(
                              context.space(4),
                            ),
                          ),
                          child: Text(
                            theme.displayName,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: context.sp(10),
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      if (isSelected)
                        Center(
                          child: Container(
                            padding: EdgeInsets.all(context.space(8)),
                            decoration: const BoxDecoration(
                              color: Color(0xFF0084FF),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.check,
                              color: Colors.white,
                              size: context.space(20),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
