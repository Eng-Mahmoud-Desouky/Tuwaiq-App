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

class ProfileScreen extends StatefulWidget {
  final String userId;

  const ProfileScreen({super.key, required this.userId});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _mainTabIndex = 0; // 0: أنشطتي, 1: المحفوظات
  int _innerTabIndex = 0; // 0: منشوراتي, 1: فعالياتي

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthCubit>().state;
    final currentUserId = (authState is AuthSuccess) ? authState.user.id : '';
    final isOwnProfile = widget.userId == currentUserId;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceContainerLowest,
        elevation: 0,
        centerTitle: true,
        leading: isOwnProfile
            ? IconButton(
                icon: const Icon(Icons.menu, color: AppColors.onSurfaceVariant),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('تسجيل الخروج...'),
                      action: SnackBarAction(
                        label: 'نعم',
                        onPressed: () {
                          context.read<AuthCubit>().signOut();
                          context.go(AppRoutes.signIn);
                        },
                      ),
                    ),
                  );
                },
              )
            : const BackButton(color: AppColors.onSurface),
        title: Text(
          'الملف الشخصي',
          style: AppTextStyles.titleMd.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
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
                      // Main sliding tab selection
                      _buildMainTabBar(isOwnProfile),
                      const SizedBox(height: 20),
                      // Selected Content View
                      if (_mainTabIndex == 0) ...[
                        _buildInnerTabSelector(),
                        const SizedBox(height: 16),
                        if (_innerTabIndex == 0)
                          _buildPostsList()
                        else
                          _buildEventsList()
                      ] else if (_mainTabIndex == 1 && isOwnProfile) ...[
                        _buildSavedEventsList(),
                      ],
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
                : Container(
                    width: double.infinity,
                    height: 180,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.primary, AppColors.secondary],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
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
            // Avatar positioned overlapping
            Positioned(
              bottom: -50,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.background,
                    width: 4,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x0F000000),
                      blurRadius: 12,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(999),
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
          ],
        ),
        const SizedBox(height: 58),
        Text(
          profile.fullName,
          style: AppTextStyles.titleMd.copyWith(color: AppColors.onSurface, fontWeight: FontWeight.bold),
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
                      'متابع',
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

  Widget _buildMainTabBar(bool showSavedTab) {
    if (!showSavedTab) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _mainTabIndex = 0),
                child: Container(
                  decoration: BoxDecoration(
                    color: _mainTabIndex == 0
                        ? AppColors.primary
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'أنشطتي',
                    style: AppTextStyles.labelLg.copyWith(
                      color: _mainTabIndex == 0 ? Colors.white : AppColors.onSurfaceVariant,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _mainTabIndex = 1),
                child: Container(
                  decoration: BoxDecoration(
                    color: _mainTabIndex == 1
                        ? AppColors.primary
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'المحفوظات',
                    style: AppTextStyles.labelLg.copyWith(
                      color: _mainTabIndex == 1 ? Colors.white : AppColors.onSurfaceVariant,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInnerTabSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ChoiceChip(
            label: const Text('المنشورات'),
            selected: _innerTabIndex == 0,
            onSelected: (selected) {
              if (selected) {
                setState(() => _innerTabIndex = 0);
              }
            },
            selectedColor: AppColors.primary.withOpacity(0.15),
            labelStyle: TextStyle(
              color: _innerTabIndex == 0 ? AppColors.primary : AppColors.onSurfaceVariant,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 16),
          ChoiceChip(
            label: const Text('الفعاليات'),
            selected: _innerTabIndex == 1,
            onSelected: (selected) {
              if (selected) {
                setState(() => _innerTabIndex = 1);
              }
            },
            selectedColor: AppColors.primary.withOpacity(0.15),
            labelStyle: TextStyle(
              color: _innerTabIndex == 1 ? AppColors.primary : AppColors.onSurfaceVariant,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostsList() {
    return BlocBuilder<ProfilePostsCubit, ProfilePostsState>(
      builder: (context, state) {
        if (state is ProfilePostsLoading) {
          return const Padding(
            padding: EdgeInsets.all(32.0),
            child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
          );
        } else if (state is ProfilePostsLoaded) {
          final posts = state.posts;
          if (posts.isEmpty) {
            return const Padding(
              padding: EdgeInsets.all(32.0),
              child: Center(child: Text('لا توجد منشورات حالياً', style: AppTextStyles.bodyMd)),
            );
          }
          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: posts.length,
            itemBuilder: (context, index) {
              return PostCard(post: posts[index]);
            },
          );
        } else if (state is ProfilePostsError) {
          return Padding(
            padding: const EdgeInsets.all(32.0),
            child: Center(
              child: Text(
                state.message,
                style: AppTextStyles.bodyMd.copyWith(color: AppColors.error),
              ),
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildEventsList() {
    return BlocBuilder<ProfileEventsCubit, ProfileEventsState>(
      builder: (context, state) {
        if (state is ProfileEventsLoading) {
          return const Padding(
            padding: EdgeInsets.all(32.0),
            child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
          );
        } else if (state is ProfileEventsLoaded) {
          final events = state.events;
          if (events.isEmpty) {
            return const Padding(
              padding: EdgeInsets.all(32.0),
              child: Center(child: Text('لا توجد فعاليات حالياً', style: AppTextStyles.bodyMd)),
            );
          }
          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: events.length,
            itemBuilder: (context, index) {
              final event = events[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                child: EventCardWidget(
                  event: event,
                  onTap: () {
                    context.push('/event-details/${event.id}', extra: event);
                  },
                ),
              );
            },
          );
        } else if (state is ProfileEventsError) {
          return Padding(
            padding: const EdgeInsets.all(32.0),
            child: Center(
              child: Text(
                state.message,
                style: AppTextStyles.bodyMd.copyWith(color: AppColors.error),
              ),
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildSavedEventsList() {
    return BlocBuilder<ProfileSavedEventsCubit, ProfileSavedEventsState>(
      builder: (context, state) {
        if (state is ProfileSavedEventsLoading) {
          return const Padding(
            padding: EdgeInsets.all(32.0),
            child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
          );
        } else if (state is ProfileSavedEventsLoaded) {
          final events = state.events;
          if (events.isEmpty) {
            return const Padding(
              padding: EdgeInsets.all(32.0),
              child: Center(child: Text('لا توجد فعاليات محفوظة حالياً', style: AppTextStyles.bodyMd)),
            );
          }
          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: events.length,
            itemBuilder: (context, index) {
              final event = events[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                child: EventCardWidget(
                  event: event,
                  onTap: () {
                    context.push('/event-details/${event.id}', extra: event);
                  },
                ),
              );
            },
          );
        } else if (state is ProfileSavedEventsError) {
          return Padding(
            padding: const EdgeInsets.all(32.0),
            child: Center(
              child: Text(
                state.message,
                style: AppTextStyles.bodyMd.copyWith(color: AppColors.error),
              ),
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
