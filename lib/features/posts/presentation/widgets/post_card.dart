import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import '../../domain/entities/post_entity.dart';
import '../cubits/post_feed/post_feed_cubit.dart';

class PostCard extends StatelessWidget {
  final PostEntity post;

  const PostCard({super.key, required this.post});

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

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'حذف المنشور',
            style: AppTextStyles.titleSm,
            textAlign: TextAlign.right,
          ),
          content: const Text(
            'هل أنت متأكد من رغبتك في حذف هذا المنشور؟ لا يمكن التراجع عن هذا الإجراء.',
            style: AppTextStyles.labelLg,
            textAlign: TextAlign.right,
          ),
          actionsAlignment: MainAxisAlignment.spaceBetween,
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text(
                'إلغاء',
                style: TextStyle(color: AppColors.secondary),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                context.read<PostFeedCubit>().deletePost(post.id);
                Navigator.of(dialogContext).pop();
              },
              child: const Text(
                'حذف',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthCubit>().state;
    final currentUserId = (authState is AuthSuccess) ? authState.user.id : '';
    final isOwner = post.creatorId == currentUserId;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F000000), // Level 2 Ambient Shadow (approx 0.06 opacity)
            blurRadius: 24,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Info Header
            Row(
              children: [
                // Avatar
                GestureDetector(
                  onTap: () {
                    context.push(AppRoutes.profile, extra: post.creatorId);
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: post.creator.avatarUrl != null &&
                            post.creator.avatarUrl!.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: post.creator.avatarUrl!,
                            width: 44,
                            height: 44,
                            fit: BoxFit.cover,
                            memCacheWidth: 100,
                            memCacheHeight: 100, // Small dimensions cache
                            placeholder: (context, url) => Container(
                              width: 44,
                              height: 44,
                              color: AppColors.secondary.withOpacity(0.1),
                              child: const Center(
                                child: SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                            ),
                            errorWidget: (context, url, error) => Container(
                              width: 44,
                              height: 44,
                              color: AppColors.primary.withOpacity(0.1),
                              child: const Icon(
                                Icons.person,
                                color: AppColors.primary,
                              ),
                            ),
                          )
                        : Container(
                            width: 44,
                            height: 44,
                            color: AppColors.primary.withOpacity(0.1),
                            child: const Icon(
                              Icons.person,
                              color: AppColors.primary,
                            ),
                          ),
                  ),
                ),
                const SizedBox(width: 12),
                // Name & Username
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () {
                          context.push(AppRoutes.profile, extra: post.creatorId);
                        },
                        child: Text(
                          post.creator.fullName.isNotEmpty
                              ? post.creator.fullName
                              : post.creator.username,
                          style: AppTextStyles.labelLg.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.onSurface,
                          ),
                        ),
                      ),
                      Text(
                        '@${post.creator.username}',
                        style: AppTextStyles.labelSm.copyWith(
                          color: AppColors.secondary,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
                // Timestamp and Delete Action
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _formatRelativeTime(post.createdAt),
                      style: AppTextStyles.labelSm.copyWith(
                        color: AppColors.secondary,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                    if (isOwner)
                      IconButton(
                        constraints: const BoxConstraints(),
                        padding: const EdgeInsets.only(top: 4),
                        icon: const Icon(
                          Icons.delete_outline,
                          color: AppColors.secondary,
                          size: 20,
                        ),
                        onPressed: () => _showDeleteConfirmation(context),
                      ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Post Content
            Text(
              post.content,
              style: AppTextStyles.bodyMd.copyWith(
                color: AppColors.onSurface,
              ),
            ),
            // Post Image (Optional)
            if (post.imageUrl != null && post.imageUrl!.isNotEmpty) ...[
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CachedNetworkImage(
                  imageUrl: post.imageUrl!,
                  width: double.infinity,
                  height: 220,
                  fit: BoxFit.cover,
                  // Enforce strict memory caching rules to prevent OOM
                  memCacheWidth: 400,
                  memCacheHeight: 400,
                  placeholder: (context, url) => Container(
                    width: double.infinity,
                    height: 220,
                    color: AppColors.secondary.withOpacity(0.1),
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    width: double.infinity,
                    height: 220,
                    color: AppColors.secondary.withOpacity(0.1),
                    child: const Center(
                      child: Icon(
                        Icons.broken_image_outlined,
                        color: AppColors.secondary,
                        size: 40,
                      ),
                    ),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 16),
            const Divider(height: 1, color: AppColors.secondaryContainer),
            const SizedBox(height: 8),
            // Interaction Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // Like Button (Optimistic + Debounced)
                InkWell(
                  onTap: () {
                    context.read<PostFeedCubit>().toggleLikePost(
                          postId: post.id,
                          userId: currentUserId,
                        );
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Row(
                      children: [
                        Icon(
                          post.isLikedByCurrentUser
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: post.isLikedByCurrentUser
                              ? AppColors.error
                              : AppColors.secondary,
                          size: 20,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          post.likeCount.toString(),
                          style: AppTextStyles.labelLg.copyWith(
                            color: post.isLikedByCurrentUser
                                ? AppColors.error
                                : AppColors.secondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Comment Button
                InkWell(
                  onTap: () {
                    context.push(
                      AppRoutes.postDetails.replaceAll(':id', post.id),
                      extra: post,
                    );
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.chat_bubble_outline,
                          color: AppColors.secondary,
                          size: 20,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          post.commentCount.toString(),
                          style: AppTextStyles.labelLg.copyWith(
                            color: AppColors.secondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
