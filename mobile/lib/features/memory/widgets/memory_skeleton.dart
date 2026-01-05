import 'package:flutter/material.dart';
import '../../../core/widgets/skeleton.dart';
import '../../../core/utils/responsive_helper.dart';
import '../../../core/constants/app_dimensions.dart';

class MemorySkeleton extends StatelessWidget {
  const MemorySkeleton({super.key});

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
        children: [
          // Image skeleton
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: Skeleton.rectangular(
                width: double.infinity,
                height: double.infinity,
                borderRadius: BorderRadius.zero,
              ),
            ),
          ),

          // Content skeleton
          Padding(
            padding: EdgeInsets.all(context.space(16)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    SkeletonAvatar(size: context.space(36)),
                    SizedBox(width: context.space(12)),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SkeletonLine(
                            width: context.width * 0.4,
                            height: context.space(18),
                          ),
                          SizedBox(height: context.space(4)),
                          SkeletonLine(
                            width: context.width * 0.25,
                            height: context.space(14),
                          ),
                        ],
                      ),
                    ),
                    Skeleton.circle(size: context.space(24)),
                  ],
                ),

                SizedBox(height: context.space(12)),

                // Description lines
                SkeletonLine(width: double.infinity, height: context.space(16)),
                SizedBox(height: context.space(8)),
                SkeletonLine(
                  width: context.width * 0.8,
                  height: context.space(16),
                ),

                SizedBox(height: context.space(12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class MemoryListSkeleton extends StatelessWidget {
  final int itemCount;

  const MemoryListSkeleton({super.key, this.itemCount = 3});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.all(context.space(16)),
      itemCount: itemCount,
      itemBuilder: (context, index) => const MemorySkeleton(),
    );
  }
}
