import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_color.dart';
import '../../../core/utils/responsive_helper.dart';
import '../../../core/constants/app_dimensions.dart';
import '../models/memory_models.dart';

class MemoryCard extends StatelessWidget {
  final Memory memory;
  final VoidCallback onMoreTap;

  const MemoryCard({super.key, required this.memory, required this.onMoreTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: context.space(24)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [_buildImage(context), _buildContent(context)],
      ),
    );
  }

  Widget _buildImage(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Image.network(
          memory.imageUrl,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: Colors.grey[200],
              child: Icon(
                Icons.image_not_supported,
                size: context.space(50),
                color: Colors.grey[400],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(context.space(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          SizedBox(height: context.space(12)),
          _buildDescription(context),
          if (memory.tags != null && memory.tags!.isNotEmpty)
            _buildTags(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(context.space(8)),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                memory.title,
                style: TextStyle(
                  fontSize: context.sp(AppDimensions.fontL),
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              Text(
                DateFormat('MMMM dd, yyyy').format(memory.createdAt),
                style: TextStyle(
                  fontSize: context.sp(AppDimensions.fontS),
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: onMoreTap,
          icon: Icon(Icons.more_vert, color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildDescription(BuildContext context) {
    return Text(
      memory.description,
      style: TextStyle(
        fontSize: context.sp(AppDimensions.fontM),
        color: Colors.grey[700],
        height: 1.5,
      ),
    );
  }

  Widget _buildTags(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: context.space(12)),
        Wrap(
          spacing: context.space(8),
          runSpacing: context.space(8),
          children: memory.tags!.map<Widget>((tag) {
            return Container(
              padding: EdgeInsets.symmetric(
                horizontal: context.space(12),
                vertical: context.space(6),
              ),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '#$tag',
                style: TextStyle(
                  fontSize: context.sp(AppDimensions.fontS),
                  color: AppColors.primary,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
