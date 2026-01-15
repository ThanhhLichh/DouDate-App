import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/utils/responsive_helper.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../controllers/chat_controller.dart';
import '../../models/conversation_settings_models.dart';

class MediaGalleryPage extends StatelessWidget {
  const MediaGalleryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<ChatController>();
    final mediaItems = controller.mediaItems;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: const Text(
          'Shared Media',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: mediaItems.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.photo_library_outlined,
                    size: context.space(AppDimensions.iconXL),
                    color: Colors.white54,
                  ),
                  ResponsiveHelper.verticalSpace(context, AppDimensions.spaceM),
                  Text(
                    'No media shared yet',
                    style: TextStyle(
                      fontSize: context.sp(AppDimensions.fontL),
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            )
          : GridView.builder(
              padding: EdgeInsets.all(context.space(4)),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: context.space(4),
                mainAxisSpacing: context.space(4),
              ),
              itemCount: mediaItems.length,
              itemBuilder: (context, index) {
                final item = mediaItems[index];
                return GestureDetector(
                  onTap: () => _showFullImage(context, item),
                  child: Hero(
                    tag: item.id,
                    child: Container(
                      decoration: BoxDecoration(color: Colors.grey[900]),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.network(
                            item.url,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey[800],
                                child: const Icon(
                                  Icons.broken_image,
                                  color: Colors.white54,
                                ),
                              );
                            },
                          ),
                          if (item.type == MediaType.video)
                            Center(
                              child: Container(
                                padding: EdgeInsets.all(context.space(8)),
                                decoration: BoxDecoration(
                                  color: Colors.black54,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.play_arrow,
                                  color: Colors.white,
                                  size: context.space(24),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }

  void _showFullImage(BuildContext context, MediaItem item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: Center(
            child: Hero(
              tag: item.id,
              child: InteractiveViewer(
                child: Image.network(
                  item.url,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return const Center(
                      child: Icon(
                        Icons.broken_image,
                        color: Colors.white54,
                        size: 64,
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
