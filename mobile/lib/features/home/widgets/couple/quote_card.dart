import 'package:flutter/material.dart';
import '../../../../core/utils/responsive_helper.dart';
import '../../../../core/constants/app_dimensions.dart';

class QuoteCard extends StatelessWidget {
  final String quote;
  final dynamic theme;

  const QuoteCard({super.key, required this.quote, required this.theme});

  @override
  Widget build(BuildContext context) {
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
}
