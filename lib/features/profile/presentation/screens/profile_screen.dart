import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import '../../../posts/presentation/widgets/post_card.dart';
import '../../domain/entities/user_profile.dart';
import '../cubit/profile_info_cubit.dart';
import '../cubit/profile_info_state.dart';
import '../cubit/profile_social_cubit.dart';
import '../cubit/profile_social_state.dart';
import '../cubit/profile_posts_cubit.dart';
import '../cubit/profile_likes_cubit.dart';

class ProfileScreen extends StatefulWidget {
  final String userId;

  const ProfileScreen({super.key, required this.userId});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {

  void _showLogoutConfirmation(BuildContext context) {
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
            'تسجيل الخروج',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            textAlign: TextAlign.right,
          ),
          content: const Text(
            'هل أنت متأكد من رغبتك في تسجيل الخروج؟',
            style: TextStyle(color: Colors.white70),
            textAlign: TextAlign.right,
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
                backgroundColor: AppColors.error,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                context.read<AuthCubit>().signOut();
                context.go(AppRoutes.signIn);
              },
              child: const Text(
                'خروج',
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
    final isOwnProfile = widget.userId == currentUserId;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocListener<ProfileSocialCubit, ProfileSocialState>(
        listener: (context, state) {
          if (state is ProfileSocialError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        child: BlocBuilder<ProfileInfoCubit, ProfileInfoState>(
          builder: (context, infoState) {
            if (infoState is ProfileInfoLoading) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              );
            } else if (infoState is ProfileInfoLoaded) {
              final profile = infoState.profile;
              return RefreshIndicator(
                color: AppColors.primary,
                onRefresh: () async {
                  context.read<ProfileInfoCubit>().loadProfile(widget.userId);
                  context.read<ProfileSocialCubit>().loadSocialStats(
                    widget.userId,
                    currentUserId,
                  );
                  context.read<ProfilePostsCubit>().loadPosts();
                  context.read<ProfileLikesCubit>().loadLikes();
                },
                child: DefaultTabController(
                  length: 2,
                  child: NestedScrollView(
                    headerSliverBuilder: (context, innerBoxIsScrolled) {
                      return [
                        SliverAppBar(
                          backgroundColor: AppColors.background,
                          elevation: 0,
                          pinned: true,
                          centerTitle: true,
                          leading: !isOwnProfile
                              ? const BackButton(color: Colors.white)
                              : null,
                          actions: [
                            if (isOwnProfile)
                              IconButton(
                                icon: const Icon(Icons.logout, color: AppColors.error),
                                onPressed: () => _showLogoutConfirmation(context),
                              ),
                          ],
                          title: Text(
                            profile.fullName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          shape: const Border(
                            bottom: BorderSide(
                              color: AppColors.outline,
                              width: 0.5,
                            ),
                          ),
                        ),
                        SliverToBoxAdapter(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _buildCoverImage(profile.coverUrl),
                              _buildAvatarAndActionsRow(
                                context,
                                profile,
                                isOwnProfile,
                                currentUserId,
                              ),
                              _buildProfileDetails(context, profile),
                              const SizedBox(height: 16),
                            ],
                          ),
                        ),
                        SliverPersistentHeader(
                          pinned: true,
                          delegate: _SliverTabBarDelegate(
                            TabBar(
                              labelColor: AppColors.primary,
                              unselectedLabelColor: AppColors.secondary,
                              indicatorColor: AppColors.primary,
                              indicatorWeight: 2,
                              tabs: const [
                                Tab(text: 'المنشورات'),
                                Tab(text: 'الإعجابات'),
                              ],
                            ),
                          ),
                        ),
                      ];
                    },
                    body: TabBarView(
                      children: [
                        _buildPostsTab(context),
                        _buildLikesTab(context),
                      ],
                    ),
                  ),
                ),
              );
            } else if (infoState is ProfileInfoError) {
              return Center(
                child: Text(
                  infoState.message,
                  style: AppTextStyles.bodyLg.copyWith(color: AppColors.error),
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildCoverImage(String? coverUrl) {
    return coverUrl != null && coverUrl.isNotEmpty
        ? CachedNetworkImage(
            imageUrl: coverUrl,
            width: double.infinity,
            height: 150,
            fit: BoxFit.cover,
            memCacheWidth: 800,
            memCacheHeight: 400,
            placeholder: (context, url) => Container(
              height: 150,
              color: AppColors.surfaceContainerLow,
              child: const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            ),
            errorWidget: (context, url, error) => const AnimatedCoverBackground(),
          )
        : const AnimatedCoverBackground();
  }

  Widget _buildAvatarAndActionsRow(
    BuildContext context,
    UserProfile profile,
    bool isOwnProfile,
    String currentUserId,
  ) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        const SizedBox(height: 50),
        Positioned(
          top: -45,
          right: 16,
          child: Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.background,
              border: Border.all(
                color: AppColors.background,
                width: 4,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black38,
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: ClipOval(
              child: profile.avatarUrl != null && profile.avatarUrl!.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: profile.avatarUrl!,
                      width: 90,
                      height: 90,
                      fit: BoxFit.cover,
                      memCacheWidth: 250,
                      memCacheHeight: 250,
                      placeholder: (context, url) => Container(
                        color: AppColors.surfaceContainerLow,
                        child: const Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) =>
                          _buildDefaultAvatar(profile.fullName),
                    )
                  : _buildDefaultAvatar(profile.fullName),
            ),
          ),
        ),
        Positioned(
          left: 16,
          top: 10,
          child: isOwnProfile
              ? OutlinedButton(
                  onPressed: () => _navigateToEditProfile(context, profile),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.outline),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  ),
                  child: Text(
                    'تعديل الملف الشخصي',
                    style: AppTextStyles.labelLg.copyWith(
                      color: AppColors.onSurface,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              : BlocBuilder<ProfileSocialCubit, ProfileSocialState>(
                  builder: (context, socialState) {
                    if (socialState is ProfileSocialLoaded) {
                      final stats = socialState.stats;
                      final isFollowing = stats.isFollowing;
                      return isFollowing
                          ? OutlinedButton(
                              onPressed: () =>
                                  context.read<ProfileSocialCubit>().toggleFollow(
                                        targetUserId: widget.userId,
                                        currentUserId: currentUserId,
                                      ),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: AppColors.outline),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 6,
                                ),
                              ),
                              child: Text(
                                'إلغاء المتابعة',
                                style: AppTextStyles.labelLg.copyWith(
                                  color: AppColors.onSurface,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            )
                          : ElevatedButton(
                              onPressed: () =>
                                  context.read<ProfileSocialCubit>().toggleFollow(
                                        targetUserId: widget.userId,
                                        currentUserId: currentUserId,
                                      ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: AppColors.onPrimary,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 18,
                                  vertical: 6,
                                ),
                              ),
                              child: Text(
                                'متابعة',
                                style: AppTextStyles.labelLg.copyWith(
                                  color: AppColors.onPrimary,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            );
                    }
                    return const SizedBox(
                      height: 32,
                      width: 80,
                      child: Center(
                        child: SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildDefaultAvatar(String name) {
    final initial = name.isNotEmpty ? name.substring(0, 1).toUpperCase() : '?';
    return Container(
      color: AppColors.surfaceContainerHighest,
      child: Center(
        child: Text(
          initial,
          style: AppTextStyles.headlineLg.copyWith(color: AppColors.primary),
        ),
      ),
    );
  }

  Widget _buildProfileDetails(BuildContext context, UserProfile profile) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                profile.fullName,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              if (profile.isVerified) ...[
                const SizedBox(width: 4),
                const Icon(
                  Icons.verified,
                  color: Colors.blue,
                  size: 18,
                ),
              ],
            ],
          ),
          const SizedBox(height: 2),
          Text(
            '@${profile.username}',
            style: const TextStyle(
              color: AppColors.secondary,
              fontSize: 14,
            ),
          ),
          if (profile.bio != null && profile.bio!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              profile.bio!,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                height: 1.4,
              ),
            ),
          ],
          const SizedBox(height: 12),
          BlocBuilder<ProfileSocialCubit, ProfileSocialState>(
            builder: (context, socialState) {
              int followersCount = 0;
              int followingCount = 0;

              if (socialState is ProfileSocialLoaded) {
                followersCount = socialState.stats.followersCount;
                followingCount = socialState.stats.followingCount;
              }

              return Row(
                children: [
                  GestureDetector(
                    onTap: () => _navigateToConnections(context, profile, 1),
                    child: Row(
                      children: [
                        Text(
                          _formatNumber(followingCount),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Text(
                          'أتابعهم',
                          style: TextStyle(
                            color: AppColors.secondary,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 20),
                  GestureDetector(
                    onTap: () => _navigateToConnections(context, profile, 0),
                    child: Row(
                      children: [
                        Text(
                          _formatNumber(followersCount),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Text(
                          'المتابعون',
                          style: TextStyle(
                            color: AppColors.secondary,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPostsTab(BuildContext context) {
    return BlocBuilder<ProfilePostsCubit, ProfilePostsState>(
      builder: (context, state) {
        if (state is ProfilePostsLoading) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        } else if (state is ProfilePostsLoaded) {
          final posts = state.posts;
          if (posts.isEmpty) {
            return const Center(
              child: Text(
                'لا توجد منشورات حالياً',
                style: TextStyle(color: AppColors.secondary, fontSize: 14),
              ),
            );
          }
          return NotificationListener<ScrollNotification>(
            onNotification: (ScrollNotification scrollInfo) {
              if (scrollInfo.metrics.pixels >=
                  scrollInfo.metrics.maxScrollExtent - 200) {
                context.read<ProfilePostsCubit>().loadMorePosts();
              }
              return false;
            },
            child: ListView.builder(
              key: const PageStorageKey('profile_posts'),
              padding: const EdgeInsets.only(top: 8, bottom: 80),
              itemCount: posts.length,
              itemBuilder: (context, index) {
                return PostCard(post: posts[index]);
              },
            ),
          );
        } else if (state is ProfilePostsError) {
          return Center(
            child: Text(
              state.message,
              style: const TextStyle(color: AppColors.error),
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildLikesTab(BuildContext context) {
    return BlocBuilder<ProfileLikesCubit, ProfileLikesState>(
      builder: (context, state) {
        if (state is ProfileLikesLoading) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        } else if (state is ProfileLikesLoaded) {
          final posts = state.posts;
          if (posts.isEmpty) {
            return const Center(
              child: Text(
                'لا توجد إعجابات حالياً',
                style: TextStyle(color: AppColors.secondary, fontSize: 14),
              ),
            );
          }
          return NotificationListener<ScrollNotification>(
            onNotification: (ScrollNotification scrollInfo) {
              if (scrollInfo.metrics.pixels >=
                  scrollInfo.metrics.maxScrollExtent - 200) {
                context.read<ProfileLikesCubit>().loadMoreLikes();
              }
              return false;
            },
            child: ListView.builder(
              key: const PageStorageKey('profile_likes'),
              padding: const EdgeInsets.only(top: 8, bottom: 80),
              itemCount: posts.length,
              itemBuilder: (context, index) {
                return PostCard(post: posts[index]);
              },
            ),
          );
        } else if (state is ProfileLikesError) {
          return Center(
            child: Text(
              state.message,
              style: const TextStyle(color: AppColors.error),
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}m';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}k';
    }
    return number.toString();
  }

  void _navigateToEditProfile(BuildContext context, UserProfile profile) {
    context.push('/profile/${AppRoutes.editProfile}', extra: profile).then((_) {
      final authState = context.read<AuthCubit>().state;
      final currentUserId = (authState is AuthSuccess) ? authState.user.id : '';
      context.read<ProfileInfoCubit>().loadProfile(widget.userId);
      context.read<ProfileSocialCubit>().loadSocialStats(
        widget.userId,
        currentUserId,
      );
      context.read<ProfilePostsCubit>().loadPosts();
      context.read<ProfileLikesCubit>().loadLikes();
    });
  }

  void _navigateToConnections(
    BuildContext context,
    UserProfile profile,
    int initialIndex,
  ) {
    context
        .push(
          '/profile/${AppRoutes.connections}',
          extra: {
            'userId': widget.userId,
            'userName': profile.fullName,
            'initialIndex': initialIndex,
          },
        )
        .then((_) {
          final authState = context.read<AuthCubit>().state;
          final currentUserId = (authState is AuthSuccess)
              ? authState.user.id
              : '';
          context.read<ProfileSocialCubit>().loadSocialStats(
            widget.userId,
            currentUserId,
          );
        });
  }
}

class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  _SliverTabBarDelegate(this.tabBar);

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: AppColors.background,
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverTabBarDelegate oldDelegate) {
    return false;
  }
}

class AnimatedCoverBackground extends StatefulWidget {
  const AnimatedCoverBackground({super.key});

  @override
  State<AnimatedCoverBackground> createState() => _AnimatedCoverBackgroundState();
}

class _AnimatedCoverBackgroundState extends State<AnimatedCoverBackground> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Alignment> _topAlignment;
  late Animation<Alignment> _bottomAlignment;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 6),
      vsync: this,
    )..repeat(reverse: true);

    _topAlignment = TweenSequence<Alignment>([
      TweenSequenceItem(tween: AlignmentTween(begin: Alignment.topLeft, end: Alignment.topRight), weight: 1),
      TweenSequenceItem(tween: AlignmentTween(begin: Alignment.topRight, end: Alignment.bottomRight), weight: 1),
      TweenSequenceItem(tween: AlignmentTween(begin: Alignment.bottomRight, end: Alignment.bottomLeft), weight: 1),
      TweenSequenceItem(tween: AlignmentTween(begin: Alignment.bottomLeft, end: Alignment.topLeft), weight: 1),
    ]).animate(_controller);

    _bottomAlignment = TweenSequence<Alignment>([
      TweenSequenceItem(tween: AlignmentTween(begin: Alignment.bottomRight, end: Alignment.bottomLeft), weight: 1),
      TweenSequenceItem(tween: AlignmentTween(begin: Alignment.bottomLeft, end: Alignment.topLeft), weight: 1),
      TweenSequenceItem(tween: AlignmentTween(begin: Alignment.topLeft, end: Alignment.topRight), weight: 1),
      TweenSequenceItem(tween: AlignmentTween(begin: Alignment.topRight, end: Alignment.bottomRight), weight: 1),
    ]).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: double.infinity,
          height: 150,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: const [
                Color(0xFF1E293B), // Dark Slate/Metallic
                Color(0xFF0F172A), // Dark Navy
                Color(0xFF000000), // Pitch Black
              ],
              begin: _topAlignment.value,
              end: _bottomAlignment.value,
            ),
          ),
        );
      },
    );
  }
}
