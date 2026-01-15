import 'package:flutter/material.dart';
import '../../../../core/utils/responsive_helper.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/theme/theme_constants.dart';
import '../../controllers/conversation_controller.dart';
import '../../models/conversation_settings_models.dart';

class PartnerHeader extends StatelessWidget {
  final ConversationController controller;
  final dynamic conversation;
  final ConversationSettings? settings;

  const PartnerHeader({
    super.key,
    required this.controller,
    required this.conversation,
    this.settings,
  });

  @override
  Widget build(BuildContext context) {
    final displayName = settings?.partnerNickname ?? conversation.partnerName;

    final avatar = conversation.partnerAvatar;

    return Container(
      color: Colors.white,
      padding: EdgeInsets.all(context.space(20)),
      child: Column(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: context.space(40),
                backgroundImage: avatar?.isNotEmpty == true
                    ? NetworkImage(avatar!)
                    : const AssetImage(ThemeConstants.defaultAvatar)
                          as ImageProvider,
              ),
              if (conversation.isOnline)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: context.space(16),
                    height: context.space(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF31A24C),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white,
                        width: context.space(2),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          ResponsiveHelper.verticalSpace(context, AppDimensions.spaceM),
          Text(
            displayName,
            style: TextStyle(
              fontSize: context.sp(AppDimensions.fontL),
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            conversation.isOnline ? 'Active now' : 'Offline',
            style: TextStyle(
              fontSize: context.sp(AppDimensions.fontS),
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}
