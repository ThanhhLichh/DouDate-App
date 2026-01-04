// import 'package:flutter/material.dart';
// import 'package:timeago/timeago.dart' as timeago;
// import '../../../core/utils/responsive_helper.dart';
// import '../../../core/constants/app_dimensions.dart';
// import '../../../core/theme/theme_constants.dart';
// import '../models/chat_models.dart';

// class ConversationItem extends StatelessWidget {
//   final Conversation conversation;
//   final VoidCallback onTap;

//   const ConversationItem({
//     super.key,
//     required this.conversation,
//     required this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final hasUnread = conversation.unreadCount > 0;

//     return InkWell(
//       onTap: onTap,
//       child: Container(
//         padding: EdgeInsets.symmetric(
//           horizontal: context.space(16),
//           vertical: context.space(12),
//         ),
//         decoration: BoxDecoration(
//           color: hasUnread ? const Color(0xFFF0F2F5) : Colors.white,
//         ),
//         child: Row(
//           children: [
//             // Avatar with online status
//             Stack(
//               children: [
//                 CircleAvatar(
//                   radius: context.space(28),
//                   backgroundImage: const AssetImage(
//                     ThemeConstants.defaultAvatar,
//                   ),
//                 ),
//                 if (conversation.isOnline)
//                   Positioned(
//                     bottom: 0,
//                     right: 0,
//                     child: Container(
//                       width: context.space(14),
//                       height: context.space(14),
//                       decoration: BoxDecoration(
//                         color: const Color(0xFF31A24C),
//                         shape: BoxShape.circle,
//                         border: Border.all(
//                           color: Colors.white,
//                           width: context.space(2),
//                         ),
//                       ),
//                     ),
//                   ),
//               ],
//             ),

//             ResponsiveHelper.horizontalSpace(context, AppDimensions.spaceM),

//             // Content
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // Name and timestamp
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Text(
//                         conversation.partnerName,
//                         style: TextStyle(
//                           fontSize: context.sp(AppDimensions.fontM),
//                           fontWeight: hasUnread
//                               ? FontWeight.bold
//                               : FontWeight.w600,
//                         ),
//                       ),
//                       if (conversation.lastMessage != null)
//                         Text(
//                           _formatTime(conversation.lastMessage!.timestamp),
//                           style: TextStyle(
//                             fontSize: context.sp(AppDimensions.fontXXS),
//                             color: hasUnread
//                                 ? const Color(0xFF0084FF)
//                                 : Colors.grey[600],
//                             fontWeight: hasUnread
//                                 ? FontWeight.w600
//                                 : FontWeight.normal,
//                           ),
//                         ),
//                     ],
//                   ),

//                   ResponsiveHelper.verticalSpace(
//                     context,
//                     AppDimensions.spaceXS,
//                   ),

//                   // Last message and unread badge
//                   Row(
//                     children: [
//                       Expanded(
//                         child: Text(
//                           conversation.lastMessage?.content ??
//                               'No messages yet',
//                           maxLines: 1,
//                           overflow: TextOverflow.ellipsis,
//                           style: TextStyle(
//                             fontSize: context.sp(AppDimensions.fontS),
//                             color: hasUnread
//                                 ? Colors.black87
//                                 : Colors.grey[600],
//                             fontWeight: hasUnread
//                                 ? FontWeight.w600
//                                 : FontWeight.normal,
//                           ),
//                         ),
//                       ),
//                       if (hasUnread) ...[
//                         ResponsiveHelper.horizontalSpace(
//                           context,
//                           AppDimensions.spaceS,
//                         ),
//                         Container(
//                           padding: EdgeInsets.symmetric(
//                             horizontal: context.space(8),
//                             vertical: context.space(4),
//                           ),
//                           decoration: const BoxDecoration(
//                             color: Color(0xFF0084FF),
//                             shape: BoxShape.circle,
//                           ),
//                           child: Text(
//                             '${conversation.unreadCount}',
//                             style: TextStyle(
//                               color: Colors.white,
//                               fontSize: context.sp(AppDimensions.fontXXS),
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   String _formatTime(DateTime timestamp) {
//     final now = DateTime.now();
//     final difference = now.difference(timestamp);

//     if (difference.inMinutes < 1) {
//       return 'Just now';
//     } else if (difference.inHours < 1) {
//       return '${difference.inMinutes}m';
//     } else if (difference.inHours < 24) {
//       return '${difference.inHours}h';
//     } else if (difference.inDays < 7) {
//       return '${difference.inDays}d';
//     } else {
//       return timeago.format(timestamp, locale: 'en_short');
//     }
//   }
// }
