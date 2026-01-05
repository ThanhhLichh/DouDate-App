import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/memory_models.dart';
import '../../../core/theme/app_color.dart';
import '../../../core/utils/responsive_helper.dart';
import '../../../core/constants/app_dimensions.dart';

class MemoryDetailView extends StatelessWidget {
  final Memory memory;

  const MemoryDetailView({super.key, required this.memory});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(memory.title, style: const TextStyle(color: Colors.white)),
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: InteractiveViewer(
                minScale: 0.5,
                maxScale: 4.0,
                child: Image.network(
                  memory.imageUrl,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[900],
                      child: Icon(
                        Icons.image_not_supported,
                        size: context.space(80),
                        color: Colors.grey[700],
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          _buildMemoryInfo(context),
        ],
      ),
    );
  }

  Widget _buildMemoryInfo(BuildContext context) {
    return Container(
      color: Colors.black87,
      padding: EdgeInsets.all(context.space(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Title with icon
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(context.space(8)),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.favorite,
                  color: AppColors.primary,
                  size: context.space(20),
                ),
              ),
              SizedBox(width: context.space(12)),
              Expanded(
                child: Text(
                  memory.title,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: context.sp(AppDimensions.fontXL),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: context.space(12)),

          // Date
          Row(
            children: [
              Icon(
                Icons.calendar_today,
                size: context.space(16),
                color: Colors.white54,
              ),
              SizedBox(width: context.space(8)),
              Text(
                DateFormat('MMMM dd, yyyy').format(memory.createdAt),
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: context.sp(AppDimensions.fontM),
                ),
              ),
            ],
          ),

          SizedBox(height: context.space(12)),

          // Description
          Text(
            memory.description,
            style: TextStyle(
              color: Colors.white70,
              fontSize: context.sp(AppDimensions.fontM),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
