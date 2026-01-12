import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/utils/responsive_helper.dart';
import '../../../core/constants/app_dimensions.dart';

class ProfileAvatar extends StatelessWidget {
  final String? avatarUrl;
  final VoidCallback onEdit;
  final dynamic theme;

  const ProfileAvatar({
    super.key,
    this.avatarUrl,
    required this.onEdit,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Background circle
        Container(
          width: context.space(140),
          height: context.space(140),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: theme.primaryColor.withOpacity(0.2),
          ),
        ),

        // Avatar Container
        Container(
          width: context.space(100),
          height: context.space(100),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: ClipOval(
            child: avatarUrl != null && avatarUrl!.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: avatarUrl!,
                    fit: BoxFit.cover,
                    width: context.space(100),
                    height: context.space(100),
                    placeholder: (context, url) => Container(
                      color: theme.primaryColor.withOpacity(0.2),
                      child: Center(
                        child: CircularProgressIndicator(
                          color: theme.accentColor,
                          strokeWidth: 2,
                        ),
                      ),
                    ),
                    errorWidget: (context, url, error) =>
                        _buildDefaultAvatar(context),
                    memCacheWidth: 200,
                    memCacheHeight: 200,
                    maxWidthDiskCache: 400,
                    maxHeightDiskCache: 400,
                  )
                : _buildDefaultAvatar(context),
          ),
        ),

        // Edit button
        Positioned(
          bottom: context.space(10),
          right: context.space(10),
          child: GestureDetector(
            onTap: onEdit,
            child: Container(
              padding: EdgeInsets.all(context.space(8)),
              decoration: BoxDecoration(
                color: theme.accentColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                Icons.edit,
                color: Colors.white,
                size: context.space(AppDimensions.iconS),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDefaultAvatar(BuildContext context) {
    return Container(
      width: context.space(100),
      height: context.space(100),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: theme.primaryColor.withOpacity(0.3),
      ),
      child: Icon(
        Icons.person,
        size: context.space(50),
        color: theme.accentColor,
      ),
    );
  }
}
