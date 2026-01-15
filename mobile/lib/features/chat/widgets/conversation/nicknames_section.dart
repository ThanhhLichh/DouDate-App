import 'package:flutter/material.dart';
import '../../../../core/utils/responsive_helper.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../controllers/conversation_controller.dart';
import '../../models/conversation_settings_models.dart';
import 'setting_item_title.dart';

class NicknamesSection extends StatelessWidget {
  final ConversationController controller;
  final ConversationSettings? settings;

  const NicknamesSection({
    super.key,
    required this.controller,
    required this.settings,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(context.space(16)),
            child: Text(
              'Nicknames',
              style: TextStyle(
                fontSize: context.sp(AppDimensions.fontM),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SettingItemTile(
            icon: Icons.person,
            title: 'Your nickname',
            subtitle: settings?.yourNickname ?? 'Not set',
            onTap: () => _showNicknameDialog(
              context,
              isYours: true,
              currentNickname: settings?.yourNickname,
            ),
          ),
          Divider(height: 1, color: Colors.grey[200]),
          SettingItemTile(
            icon: Icons.person_outline,
            title: 'Partner\'s nickname',
            subtitle: settings?.partnerNickname ?? 'Not set',
            onTap: () => _showNicknameDialog(
              context,
              isYours: false,
              currentNickname: settings?.partnerNickname,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showNicknameDialog(
    BuildContext context, {
    required bool isYours,
    String? currentNickname,
  }) async {
    final textController = TextEditingController(text: currentNickname);

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isYours ? 'Your Nickname' : 'Partner\'s Nickname'),
        content: TextField(
          controller: textController,
          decoration: const InputDecoration(
            hintText: 'Enter nickname',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final nickname = textController.text.trim();
              final success = await controller.updateNicknames(
                yourNickname: isYours ? nickname : null,
                partnerNickname: !isYours ? nickname : null,
              );

              if (context.mounted) {
                Navigator.pop(context);
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Nickname updated!'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
