import 'package:flutter/material.dart';
import '../../../models/chat_models.dart';
import '../../../controllers/chat_controller.dart';

void showMessageDeleteDialog(
  BuildContext context,
  Message message,
  ChatController controller,
) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Delete Message'),
      content: const Text('Are you sure you want to delete this message?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () async {
            final success = await controller.deleteMessage(message.id);

            if (context.mounted) {
              Navigator.pop(context);
              if (!success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      controller.errorMessage ?? 'Failed to delete message',
                    ),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            }
          },
          style: TextButton.styleFrom(foregroundColor: Colors.red),
          child: const Text('Delete'),
        ),
      ],
    ),
  );
}
