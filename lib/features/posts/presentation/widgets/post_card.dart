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
import 'post_video_player.dart';
import '../../../profile/presentation/cubit/profile_posts_cubit.dart';
import '../../../profile/presentation/cubit/profile_likes_cubit.dart';
import '../../../explore/presentation/cubit/explore_cubit.dart';

class PostCard extends StatelessWidget {
  final PostEntity post;

  const PostCard({super.key, required this.post});

  static DateTime? _lastNavigateTime;

  static void _safelyPush(BuildContext context, String route, {Object? extra}) {
    final now = DateTime.now();
    if (_lastNavigateTime != null &&
        now.difference(_lastNavigateTime!) < const Duration(milliseconds: 800)) {
      return;
    }
    _lastNavigateTime = now;
    context.push(route, extra: extra);
  }

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

  void _showEditDialog(BuildContext context) {
    final controller = TextEditingController(text: post.content ?? '');
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.surfaceContainerLow,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: AppColors.outline, width: 0.5),
          ),
          title: const Text(
            'تعديل المنشور',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            textAlign: TextAlign.right,
          ),
          content: TextField(
            controller: controller,
            maxLines: 5,
            maxLength: 2000,
            style: const TextStyle(color: Colors.white),
            textAlign: TextAlign.right,
            textDirection: TextDirection.rtl,
            decoration: InputDecoration(
              hintText: 'تعديل محتوى المنشور...',
              hintStyle: const TextStyle(color: Colors.white38),
              filled: true,
              fillColor: AppColors.background,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.outline, width: 0.5),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.primary, width: 1),
              ),
            ),
          ),
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
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                final newContent = controller.text.trim();
                if (newContent.isNotEmpty) {
                  context.read<PostFeedCubit>().updatePost(
                        postId: post.id,
                        content: newContent,
                      );
                }
                Navigator.of(dialogContext).pop();
              },
              child: const Text(
                'حفظ',
                style: TextStyle(color: Colors.black),
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
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.outline,
          width: 0.5,
        ),
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
                    _safelyPush(context, AppRoutes.profile, extra: post.creatorId);
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
                // Name, Username, Dot, Relative Time Inline Layout
                Expanded(
                  child: Row(
                    children: [
                      Flexible(
                        child: GestureDetector(
                          onTap: () {
                            _safelyPush(context, AppRoutes.profile, extra: post.creatorId);
                          },
                          child: Text(
                            post.creator.fullName.isNotEmpty
                                ? post.creator.fullName
                                : post.creator.username,
                            style: AppTextStyles.labelLg.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.onSurface,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          '@${post.creator.username}',
                          style: AppTextStyles.labelSm.copyWith(
                            color: AppColors.secondary,
                            fontWeight: FontWeight.normal,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                      Text(
                        ' • ',
                        style: AppTextStyles.labelSm.copyWith(
                          color: AppColors.secondary,
                        ),
                      ),
                      Text(
                        _formatRelativeTime(post.createdAt),
                        style: AppTextStyles.labelSm.copyWith(
                          color: AppColors.secondary,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isOwner)
                  PopupMenuButton<String>(
                    icon: const Icon(
                      Icons.more_vert,
                      color: AppColors.secondary,
                      size: 20,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 100),
                    onSelected: (value) {
                      if (value == 'delete') {
                        _showDeleteConfirmation(context);
                      } else if (value == 'edit') {
                        _showEditDialog(context);
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit_outlined, size: 18, color: AppColors.onSurface),
                            SizedBox(width: 8),
                            Text('تعديل', style: TextStyle(fontSize: 13)),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete_outline, color: AppColors.error, size: 18),
                            SizedBox(width: 8),
                            Text(
                              'حذف',
                              style: TextStyle(color: AppColors.error, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
              ],
            ),
            if (post.content != null && post.content!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                post.content!,
                style: AppTextStyles.bodyMd.copyWith(
                  color: AppColors.onSurface,
                ),
              ),
            ],
            // Post Media (Optional Video or Image)
            if (post.mediaType == 'video' && post.videoUrl != null && post.videoUrl!.isNotEmpty) ...[
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: PostVideoPlayer(
                  videoUrl: post.videoUrl!,
                  isLocal: false,
                  autoPlay: true,
                  startMuted: true,
                ),
              ),
            ] else if (post.imageUrl != null && post.imageUrl!.isNotEmpty) ...[
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
                    final newLiked = !post.isLikedByCurrentUser;
                    final newCount = newLiked ? post.likeCount + 1 : post.likeCount - 1;

                    context.read<PostFeedCubit>().toggleLikePost(
                          postId: post.id,
                          userId: currentUserId,
                        );

                    try {
                      context.read<ProfilePostsCubit>().toggleLike(post.id, newLiked, newCount);
                    } catch (_) {}

                    try {
                      context.read<ProfileLikesCubit>().toggleLike(post.id, newLiked, newCount);
                    } catch (_) {}

                    try {
                      context.read<ExploreCubit>().toggleLike(post.id, newLiked, newCount);
                    } catch (_) {}
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
                    _safelyPush(
                      context,
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
