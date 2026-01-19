import 'package:flutter/material.dart';
import '../../../../../core/utils/responsive_helper.dart';

class MessageActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const MessageActionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(context.space(12)),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: context.space(16),
          vertical: context.space(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(context.space(10)),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: context.space(24)),
            ),
            ResponsiveHelper.verticalSpace(context, 6),
            Text(
              label,
              style: TextStyle(
                fontSize: context.sp(12),
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
