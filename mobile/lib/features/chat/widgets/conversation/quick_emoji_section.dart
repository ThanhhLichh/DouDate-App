import 'package:flutter/material.dart';
import '../../../../core/utils/responsive_helper.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../controllers/conversation_controller.dart';
import '../../models/conversation_settings_models.dart';

class QuickEmojiSection extends StatelessWidget {
  final ConversationController controller;
  final ConversationSettings? settings;

  const QuickEmojiSection({super.key, required this.controller, this.settings});

  @override
  Widget build(BuildContext context) {
    final emojis = ['❤️', '👍', '😂', '😮', '😢', '😡', '🎉', '🔥'];
    final currentEmoji = settings?.quickEmoji ?? '👍';

    return Container(
      color: Colors.white,
      padding: EdgeInsets.all(context.space(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Reaction',
            style: TextStyle(
              fontSize: context.sp(AppDimensions.fontM),
              fontWeight: FontWeight.bold,
            ),
          ),
          ResponsiveHelper.verticalSpace(context, AppDimensions.spaceM),
          Wrap(
            spacing: context.space(12),
            runSpacing: context.space(12),
            children: emojis.map((emoji) {
              final isSelected = currentEmoji == emoji;
              return GestureDetector(
                onTap: () async {
                  final success = await controller.updateQuickEmoji(emoji);
                  if (success && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Quick reaction updated!'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  }
                },
                child: Container(
                  width: context.space(50),
                  height: context.space(50),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF0084FF).withOpacity(0.1)
                        : Colors.grey[100],
                    shape: BoxShape.circle,
                    border: isSelected
                        ? Border.all(color: const Color(0xFF0084FF), width: 2)
                        : null,
                  ),
                  child: Center(
                    child: Text(
                      emoji,
                      style: TextStyle(fontSize: context.sp(24)),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
