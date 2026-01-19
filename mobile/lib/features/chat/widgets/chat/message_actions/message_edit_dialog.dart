import 'package:flutter/material.dart';
import '../../../models/chat_models.dart';
import '../../../controllers/chat_controller.dart';

void showMessageEditDialog(
  BuildContext context,
  Message message,
  ChatController controller,
) {
  final textController = TextEditingController(text: message.content);

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Edit Message'),
      content: TextField(
        controller: textController,
        maxLines: 3,
        autofocus: true,
        decoration: const InputDecoration(
          hintText: 'Enter new message',
          border: OutlineInputBorder(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () async {
            final newContent = textController.text.trim();
            if (newContent.isEmpty || newContent == message.content) {
              Navigator.pop(context);
              return;
            }

            final success = await controller.updateMessage(
              message.id,
              newContent,
            );

            if (context.mounted) {
              Navigator.pop(context);
              if (!success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      controller.errorMessage ?? 'Failed to edit message',
                    ),
                    backgroundColor: Colors.red,
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
