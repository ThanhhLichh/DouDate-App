import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'memory_detail_view.dart';
import '../controllers/memory_controller.dart';
import '../../../core/utils/responsive_helper.dart';

class AllPhotosView extends StatelessWidget {
  const AllPhotosView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('All Photos', style: TextStyle(color: Colors.white)),
      ),
      body: Consumer<MemoryController>(
        builder: (context, controller, child) {
          if (controller.memories.isEmpty) {
            return const Center(
              child: Text(
                'No photos yet',
                style: TextStyle(color: Colors.grey),
              ),
            );
          }

          return GridView.builder(
            padding: EdgeInsets.all(context.space(4)),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 4,
              mainAxisSpacing: 4,
            ),
            itemCount: controller.memories.length,
            itemBuilder: (context, index) {
              final memory = controller.memories[index];
              return GestureDetector(
                onTap: () => _navigateToDetail(context, memory),
                child: Image.network(
                  memory.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[200],
                      child: Icon(
                        Icons.image_not_supported,
                        size: 30,
                        color: Colors.grey[400],
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _navigateToDetail(BuildContext context, dynamic memory) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MemoryDetailView(memory: memory)),
    );
  }
}
