import 'package:flutter/material.dart';
import '../../../../../core/utils/responsive_helper.dart';
import '../../../models/chat_models.dart';
import '../message_views/zoomable_image_viewer.dart';

class MessageImageContent extends StatelessWidget {
  final Message message;
  final bool isMe;

  const MessageImageContent({
    super.key,
    required this.message,
    required this.isMe,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showZoomableImage(context),
      child: Hero(
        tag: 'msg_img_${message.id}',
        child: ClipRRect(
          borderRadius: BorderRadius.circular(context.space(12)),
          child: Image.network(
            message.thumbnailUrl ?? message.imgUrl!,
            width: context.space(200),
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(
                width: context.space(200),
                height: context.space(150),
                color: isMe ? Colors.white24 : Colors.grey[300],
                child: const Center(
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) =>
                const Icon(Icons.broken_image, color: Colors.grey),
          ),
        ),
      ),
    );
  }

  void _showZoomableImage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ZoomableImageViewer(
          imageUrl: message.imgUrl!,
          heroTag: 'msg_img_${message.id}',
        ),
      ),
    );
  }
}
