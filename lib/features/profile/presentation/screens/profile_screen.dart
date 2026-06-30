import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import '../../../posts/presentation/widgets/post_card.dart';
import '../../../events/presentation/widgets/event_card_widget.dart';
import '../../domain/entities/user_profile.dart';
import '../cubit/profile_info_cubit.dart';
import '../cubit/profile_info_state.dart';
import '../cubit/profile_social_cubit.dart';
import '../cubit/profile_social_state.dart';
import '../cubit/profile_posts_cubit.dart';
import '../cubit/profile_events_cubit.dart';
import '../cubit/profile_saved_events_cubit.dart';
import '../../../posts/domain/entities/post_entity.dart';
import '../../../events/domain/entities/event_entity.dart';

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
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
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
        title: const Text(
          'الملف الشخصي',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        shape: const Border(
          bottom: BorderSide(
            color: AppColors.outline,
            width: 0.5,
          ),
        ),
      ),
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
                  context.read<ProfileEventsCubit>().loadEvents();
                  context.read<ProfileSavedEventsCubit>().loadSavedEvents();
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.only(bottom: 100),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Profile Header with overlapping Cover & Avatar
                      _buildProfileHeader(
                        context,
                        profile,
                        isOwnProfile,
                        currentUserId,
                      ),
                      const SizedBox(height: 20),
                      // Social Stats Card
                      _buildSocialStatsCard(context, profile),
                      const SizedBox(height: 24),
                      // Interests
                      _buildInterestsSection(profile.interests),
                      const SizedBox(height: 28),
                      const SizedBox(height: 28),
                      // Unified Feed (Posts & Events sorted by newest first)
                      _buildUnifiedFeed(),
                    ],
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

  Widget _buildProfileHeader(
    BuildContext context,
    UserProfile profile,
    bool isOwnProfile,
    String currentUserId,
  ) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomCenter,
          clipBehavior: Clip.none,
          children: [
            // Cover Image banner
            profile.coverUrl != null && profile.coverUrl!.isNotEmpty
                ? Image.network(
                    profile.coverUrl!,
                    width: double.infinity,
                    height: 180,
                    fit: BoxFit.cover,
                  )
                : const AnimatedCoverBackground(),
            // Edit Cover Photo icon overlay
            if (isOwnProfile)
              Positioned(
                top: 16,
                left: 16,
                child: GestureDetector(
                  onTap: () => _navigateToEditProfile(context, profile),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Colors.black54,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.photo_camera,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
            // Avatar positioned overlapping with premium hexagon shape/border
            Positioned(
              bottom: -50,
              child: Container(
                width: 104,
                height: 104,
                decoration: const BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x3F000000),
                      blurRadius: 12,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipPath(
                  clipper: HexagonClipper(),
                  child: Container(
                    color: AppColors.tuwaiqGold, // Gold border
                    padding: const EdgeInsets.all(4),
                    child: ClipPath(
                      clipper: HexagonClipper(),
                      child: Container(
                        color: AppColors.background,
                        child: profile.avatarUrl != null && profile.avatarUrl!.isNotEmpty
                            ? Image.network(
                                profile.avatarUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    _buildDefaultAvatar(profile.fullName),
                              )
                            : _buildDefaultAvatar(profile.fullName),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 58),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              profile.fullName,
              style: AppTextStyles.titleMd.copyWith(color: AppColors.onSurface, fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 6),
            const Icon(
              Icons.verified,
              color: Colors.blue, // Verified badge in Twitter-like blue color
              size: 18,
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          '@${profile.username}',
          style: AppTextStyles.bodyMd.copyWith(
            color: AppColors.onSurfaceVariant,
          ),
        ),
        if (profile.bio != null && profile.bio!.isNotEmpty) ...[
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Text(
              profile.bio!,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyLg.copyWith(color: AppColors.onSurface),
            ),
          ),
        ],
        const SizedBox(height: 16),
        if (isOwnProfile)
          OutlinedButton(
            onPressed: () => _navigateToEditProfile(context, profile),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.outline),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            ),
            child: Text(
              'تعديل الملف الشخصي',
              style: AppTextStyles.labelLg.copyWith(color: AppColors.onSurface),
            ),
          )
        else
          BlocBuilder<ProfileSocialCubit, ProfileSocialState>(
            builder: (context, socialState) {
              if (socialState is ProfileSocialLoaded) {
                final stats = socialState.stats;
                if (stats.isFollowing) {
                  return OutlinedButton(
                    onPressed: () =>
                        context.read<ProfileSocialCubit>().toggleFollow(
                          targetUserId: widget.userId,
                          currentUserId: currentUserId,
                        ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.outlineVariant),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(999),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 10,
                      ),
                    ),
                    child: Text(
                      'إلغاء المتابعه',
                      style: AppTextStyles.labelLg.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  );
                } else {
                  return ElevatedButton(
                    onPressed: () =>
                        context.read<ProfileSocialCubit>().toggleFollow(
                          targetUserId: widget.userId,
                          currentUserId: currentUserId,
                        ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(999),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 10,
                      ),
                    ),
                    child: Text(
                      'متابعة',
                      style: AppTextStyles.labelLg.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.background,
                      ),
                    ),
                  );
                }
              }
              return const SizedBox(
                height: 38,
                width: 100,
                child: Center(
                  child: SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              );
            },
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

  Widget _buildSocialStatsCard(BuildContext context, UserProfile profile) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0F000000),
              blurRadius: 24,
              offset: Offset(0, 8),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: BlocBuilder<ProfileSocialCubit, ProfileSocialState>(
          builder: (context, socialState) {
            int followersCount = 0;
            int followingCount = 0;

            if (socialState is ProfileSocialLoaded) {
              followersCount = socialState.stats.followersCount;
              followingCount = socialState.stats.followingCount;
            }

            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                GestureDetector(
                  onTap: () => _navigateToConnections(context, profile, 0),
                  behavior: HitTestBehavior.opaque,
                  child: Column(
                    children: [
                      Text(
                        _formatNumber(followersCount),
                        style: AppTextStyles.headlineLgMobile.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'المتابعون',
                        style: AppTextStyles.labelSm.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 1,
                  height: 48,
                  color: AppColors.outlineVariant.withOpacity(0.3),
                ),
                GestureDetector(
                  onTap: () => _navigateToConnections(context, profile, 1),
                  behavior: HitTestBehavior.opaque,
                  child: Column(
                    children: [
                      Text(
                        _formatNumber(followingCount),
                        style: AppTextStyles.headlineLgMobile.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'أتابعهم',
                        style: AppTextStyles.labelSm.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildInterestsSection(List<String> interests) {
    if (interests.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.0),
          child: Text(
            'الاهتمامات',
            style: TextStyle(
              color: AppColors.onSurfaceVariant,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 40,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            itemCount: interests.length,
            itemBuilder: (context, index) {
              final interest = interests[index];
              final isActive = index < 4; 
              return Padding(
                padding: const EdgeInsets.only(left: 8.0), // RTL padding
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isActive
                        ? AppColors.primary.withOpacity(0.1)
                        : AppColors.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    interest,
                    style: AppTextStyles.labelLg.copyWith(
                      color: isActive
                          ? AppColors.primary
                          : AppColors.onSurfaceVariant,
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

  Widget _buildUnifiedFeed() {
    return BlocBuilder<ProfilePostsCubit, ProfilePostsState>(
      builder: (context, postsState) {
        return BlocBuilder<ProfileEventsCubit, ProfileEventsState>(
          builder: (context, eventsState) {
            bool isLoading = postsState is ProfilePostsLoading || eventsState is ProfileEventsLoading;

            if (isLoading) {
              return const Padding(
                padding: EdgeInsets.all(32.0),
                child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
              );
            }

            List<PostEntity> posts = [];
            if (postsState is ProfilePostsLoaded) {
              posts = postsState.posts;
            }

            List<EventEntity> events = [];
            if (eventsState is ProfileEventsLoaded) {
              events = eventsState.events;
            }

            if (posts.isEmpty && events.isEmpty) {
              return const Padding(
                padding: EdgeInsets.all(32.0),
                child: Center(
                  child: Text(
                    'لا توجد منشورات أو فعاليات حالياً',
                    style: TextStyle(color: AppColors.secondary, fontSize: 14),
                  ),
                ),
              );
            }

            // Combine and sort by date (newest first)
            final List<dynamic> combinedList = [...posts, ...events];
            combinedList.sort((a, b) {
              final dateA = (a is PostEntity) ? a.createdAt : (a as EventEntity).startDate;
              final dateB = (b is PostEntity) ? b.createdAt : (b as EventEntity).startDate;
              return dateB.compareTo(dateA);
            });

            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: combinedList.length,
              itemBuilder: (context, index) {
                final item = combinedList[index];
                if (item is PostEntity) {
                  return PostCard(post: item);
                } else {
                  final event = item as EventEntity;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: EventCardWidget(
                      event: event,
                      onTap: () {
                        context.push('/events/${event.id}', extra: event);
                      },
                    ),
                  );
                }
              },
            );
          },
        );
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
      context.read<ProfileEventsCubit>().loadEvents();
      context.read<ProfileSavedEventsCubit>().loadSavedEvents();
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

// Custom Hexagonal Clipper for Premium Profile Avatar
class HexagonClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    final w = size.width;
    final h = size.height;
    path.moveTo(w * 0.5, 0);
    path.lineTo(w, h * 0.25);
    path.lineTo(w, h * 0.75);
    path.lineTo(w * 0.5, h);
    path.lineTo(0, h * 0.75);
    path.lineTo(0, h * 0.25);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

// Premium Animated Gradient Background for Profile Cover
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
          height: 180,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: const [
                Color(0xFF7B5FF8), // Brand Purple
                Color(0xFF1E144D), // Dark Purple/Navy
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
