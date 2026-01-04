import 'package:flutter/material.dart';
import '../../../core/utils/responsive_helper.dart';
import '../../../core/constants/app_dimensions.dart';

class MemoryEmptyState extends StatelessWidget {
  const MemoryEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.photo_library_outlined,
            size: context.space(80),
            color: Colors.grey[300],
          ),
          SizedBox(height: context.space(16)),
          Text(
            'No memories yet',
            style: TextStyle(
              fontSize: context.sp(AppDimensions.fontL),
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: context.space(8)),
          Text(
            'Capture your special moments!',
            style: TextStyle(
              fontSize: context.sp(AppDimensions.fontM),
              color: Colors.grey[400],
            ),
          ),
        ],
      ),
    );
  }
}
