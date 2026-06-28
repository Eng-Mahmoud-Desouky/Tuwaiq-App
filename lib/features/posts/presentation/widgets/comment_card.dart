import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../domain/entities/comment_entity.dart';

class CommentCard extends StatelessWidget {
  final CommentEntity comment;
  final String currentUserId;
  final VoidCallback? onDelete;
  final VoidCallback? onEdit;

  const CommentCard({
    super.key,
    required this.comment,
    required this.currentUserId,
    this.onDelete,
    this.onEdit,
  });

  String _formatRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return 'الآن';
    } else if (difference.inMinutes < 60) {
      final mins = difference.inMinutes;
      if (mins == 1) return 'منذ دقيقة';
      if (mins == 2) return 'منذ دقيقتين';
      if (mins >= 3 && mins <= 10) return 'منذ $mins دقائق';
      return 'منذ $mins دقيقة';
    } else if (difference.inHours < 24) {
      final hours = difference.inHours;
      if (hours == 1) return 'منذ ساعة';
      if (hours == 2) return 'منذ ساعتين';
      if (hours >= 3 && hours <= 10) return 'منذ $hours ساعات';
      return 'منذ $hours ساعة';
    } else if (difference.inDays < 7) {
      final days = difference.inDays;
      if (days == 1) return 'أمس';
      if (days == 2) return 'منذ يومين';
      return 'منذ $days أيام';
    } else {
      return '${dateTime.year}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.day.toString().padLeft(2, '0')}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.secondaryContainer.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with User Profile
          Row(
            children: [
              // Avatar
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: comment.creator.avatarUrl != null &&
                        comment.creator.avatarUrl!.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: comment.creator.avatarUrl!,
                        width: 32,
                        height: 32,
                        fit: BoxFit.cover,
                        memCacheWidth: 80,
                        memCacheHeight: 80,
                        placeholder: (context, url) => Container(
                          width: 32,
                          height: 32,
                          color: AppColors.secondary.withOpacity(0.1),
                        ),
                        errorWidget: (context, url, error) => Container(
                          width: 32,
                          height: 32,
                          color: AppColors.primary.withOpacity(0.1),
                          child: const Icon(
                            Icons.person,
                            color: AppColors.primary,
                            size: 16,
                          ),
                        ),
                      )
                    : Container(
                        width: 32,
                        height: 32,
                        color: AppColors.primary.withOpacity(0.1),
                        child: const Icon(
                          Icons.person,
                          color: AppColors.primary,
                          size: 16,
                        ),
                      ),
              ),
              const SizedBox(width: 10),
              // Name and Username
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      comment.creator.fullName.isNotEmpty
                          ? comment.creator.fullName
                          : comment.creator.username,
                      style: AppTextStyles.labelLg.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: AppColors.onSurface,
                      ),
                    ),
                    Text(
                      '@${comment.creator.username}',
                      style: AppTextStyles.labelSm.copyWith(
                        fontSize: 11,
                        color: AppColors.secondary,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
              // Timestamp and Action Menu
              Row(
                children: [
                  Text(
                    _formatRelativeTime(comment.createdAt),
                    style: AppTextStyles.labelSm.copyWith(
                      fontSize: 11,
                      color: AppColors.secondary,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  if (comment.creatorId == currentUserId) ...[
                    const SizedBox(width: 4),
                    PopupMenuButton<String>(
                      icon: const Icon(
                        Icons.more_vert,
                        size: 16,
                        color: AppColors.secondary,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 100),
                      onSelected: (value) {
                        if (value == 'edit') {
                          onEdit?.call();
                        } else if (value == 'delete') {
                          onDelete?.call();
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit_outlined, size: 16, color: AppColors.onSurface),
                              SizedBox(width: 8),
                              Text('تعديل', style: TextStyle(fontSize: 13)),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete_outline, size: 16, color: AppColors.error),
                              SizedBox(width: 8),
                              Text('حذف', style: TextStyle(fontSize: 13, color: AppColors.error)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Content
          Padding(
            padding: const EdgeInsets.only(right: 42),
            child: Text(
              comment.content,
              style: AppTextStyles.bodyMd.copyWith(
                fontSize: 14,
                color: AppColors.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
