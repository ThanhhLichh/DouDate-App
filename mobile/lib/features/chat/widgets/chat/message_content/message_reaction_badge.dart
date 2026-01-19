import 'package:flutter/material.dart';
import '../../../../../core/utils/responsive_helper.dart';

class MessageReactionBadge extends StatelessWidget {
  final Map<int, String> reactions;

  const MessageReactionBadge({super.key, required this.reactions});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: -context.space(10),
      right: 0,
      child: Transform.translate(
        offset: Offset(-context.space(6), 0),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: context.space(6),
            vertical: context.space(1),
          ),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(context.space(8)),
            border: Border.all(color: Colors.grey[300]!, width: 0.5),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: _buildReactionItems(context),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildReactionItems(BuildContext context) {
    final reactionCounts = <String, int>{};
    for (var emoji in reactions.values) {
      reactionCounts[emoji] = (reactionCounts[emoji] ?? 0) + 1;
    }

    return reactionCounts.entries.map((entry) {
      final emoji = entry.key;
      final count = entry.value;

      return Padding(
        padding: EdgeInsets.symmetric(horizontal: context.space(1)),
        child: Row(
          children: [
            Text(emoji, style: TextStyle(fontSize: context.sp(9), height: 1.2)),
            if (count > 1)
              Padding(
                padding: EdgeInsets.only(left: context.space(2)),
                child: Text(
                  '$count',
                  style: TextStyle(
                    fontSize: context.sp(9),
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                  ),
                ),
              ),
          ],
        ),
      );
    }).toList();
  }
}
