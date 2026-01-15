import 'package:flutter/material.dart';
import '../../../../core/utils/responsive_helper.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../controllers/conversation_controller.dart';
import '../../models/conversation_settings_models.dart';

class BubbleColorSection extends StatelessWidget {
  final ConversationController controller;
  final ConversationSettings? settings;

  const BubbleColorSection({
    super.key,
    required this.controller,
    this.settings,
  });

  @override
  Widget build(BuildContext context) {
    final currentColor = settings?.bubbleColor ?? '#0084FF';

    return Container(
      color: Colors.white,
      padding: EdgeInsets.all(context.space(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Message Color',
            style: TextStyle(
              fontSize: context.sp(AppDimensions.fontM),
              fontWeight: FontWeight.bold,
            ),
          ),
          ResponsiveHelper.verticalSpace(context, AppDimensions.spaceM),
          Wrap(
            spacing: context.space(12),
            runSpacing: context.space(12),
            children: BubbleColorOption.options.map((option) {
              final isSelected = currentColor == option.hexColor;
              return GestureDetector(
                onTap: () async {
                  final success = await controller.updateBubbleColor(
                    option.hexColor,
                  );
                  if (success && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Message color updated!'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  }
                },
                child: Container(
                  width: context.space(50),
                  height: context.space(50),
                  decoration: BoxDecoration(
                    color: Color(
                      int.parse(option.hexColor.substring(1), radix: 16) +
                          0xFF000000,
                    ),
                    shape: BoxShape.circle,
                    border: isSelected
                        ? Border.all(color: Colors.black, width: 3)
                        : null,
                  ),
                  child: isSelected
                      ? const Icon(Icons.check, color: Colors.white)
                      : null,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
