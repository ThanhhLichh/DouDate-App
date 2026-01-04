import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../memory_controller.dart';
import '../../../core/utils/responsive_helper.dart';
import '../../../core/constants/app_dimensions.dart';

class AllPhotosView extends StatelessWidget {
  const AllPhotosView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
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
                style: TextStyle(color: Colors.white),
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
                onTap: () => _showFullImage(context, memory),
                child: Image.network(memory.imageUrl, fit: BoxFit.cover),
              );
            },
          );
        },
      ),
    );
  }

  void _showFullImage(BuildContext context, dynamic memory) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          body: Column(
            children: [
              Expanded(
                child: Center(
                  child: InteractiveViewer(
                    child: Image.network(memory.imageUrl),
                  ),
                ),
              ),
              Container(
                color: Colors.black87,
                padding: EdgeInsets.all(context.space(16)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      memory.title,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: context.sp(AppDimensions.fontL),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: context.space(8)),
                    Text(
                      memory.description,
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: context.sp(AppDimensions.fontM),
                      ),
                    ),
                    SizedBox(height: context.space(4)),
                    Text(
                      DateFormat('MMMM dd, yyyy').format(memory.createdAt),
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: context.sp(AppDimensions.fontS),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
