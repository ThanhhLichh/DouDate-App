import 'package:flutter/material.dart';
import '../../../../core/utils/responsive_helper.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../models/home_models.dart';
import 'stat_item_card.dart';

class StatsGrid extends StatelessWidget {
  final CoupleDashboard data;
  final dynamic theme;

  const StatsGrid({super.key, required this.data, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: StatItemCard(
            title: "Chat",
            value: "${data.messageCount / 1000}k",
            icon: Icons.chat_bubble_outline,
            theme: theme,
          ),
        ),
        ResponsiveHelper.horizontalSpace(context, AppDimensions.spaceM),
        Expanded(
          child: StatItemCard(
            title: "Moments",
            value: "${data.momentCount}",
            icon: Icons.camera_alt_outlined,
            theme: theme,
          ),
        ),
        ResponsiveHelper.horizontalSpace(context, AppDimensions.spaceM),
        Expanded(
          child: StatItemCard(
            title: "Memories",
            value: "${data.memoryCount}",
            icon: Icons.star_outline,
            theme: theme,
          ),
        ),
      ],
    );
  }
}
