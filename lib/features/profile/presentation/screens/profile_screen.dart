import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import '../../domain/entities/user_profile.dart';
import '../cubit/profile_info_cubit.dart';
import '../cubit/profile_info_state.dart';
import '../cubit/profile_social_cubit.dart';
import '../cubit/profile_social_state.dart';

class ProfileScreen extends StatefulWidget {
  final String userId;

  const ProfileScreen({super.key, required this.userId});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

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
                  // Options drawer or sign out
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
            : IconButton(
                icon: const Icon(Icons.arrow_back, color: AppColors.onSurfaceVariant),
                onPressed: () {
                  if (context.canPop()) {
                    context.pop();
                  } else {
                    context.go(AppRoutes.home);
                  }
                },
              ),
        title: Text(
          isOwnProfile ? '\$CRATCH' : 'الملف الشخصي',
          style: AppTextStyles.titleMd.copyWith(
            fontStyle: FontStyle.italic,
            fontWeight: FontWeight.w900,
            color: AppColors.primary,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: AppColors.onSurfaceVariant),
            onPressed: () {
              // Mock search action
            },
          ),
        ],
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
              return const Center(child: CircularProgressIndicator(color: AppColors.primary));
            } else if (infoState is ProfileInfoLoaded) {
              final profile = infoState.profile;
              return RefreshIndicator(
                color: AppColors.primary,
                onRefresh: () async {
                  context.read<ProfileInfoCubit>().loadProfile(widget.userId);
                  context.read<ProfileSocialCubit>().loadSocialStats(widget.userId, currentUserId);
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.only(bottom: 100),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 24),
                      // Profile Header Info
                      _buildProfileHeader(context, profile, isOwnProfile, currentUserId),
                      const SizedBox(height: 24),
                      // Social Stats Card
                      _buildSocialStatsCard(context, profile),
                      const SizedBox(height: 24),
                      // Interests
                      _buildInterestsSection(profile.interests),
                      const SizedBox(height: 32),
                      // Content Tabs
                      _buildTabsSection(),
                    ],
                  ),
                ),
              );
            } else if (infoState is ProfileInfoError) {
              return Center(child: Text(infoState.message, style: AppTextStyles.bodyLg.copyWith(color: AppColors.error)));
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, UserProfile profile, bool isOwnProfile, String currentUserId) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 128,
              height: 128,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.surfaceContainerLowest, width: 4),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x0F000000),
                    blurRadius: 24,
                    offset: Offset(0, 8),
                  )
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: profile.avatarUrl != null && profile.avatarUrl!.isNotEmpty
                    ? Image.network(
                        profile.avatarUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => _buildDefaultAvatar(profile.fullName),
                      )
                    : _buildDefaultAvatar(profile.fullName),
              ),
            ),
            if (isOwnProfile)
              Positioned(
                bottom: 0,
                right: 0,
                child: InkWell(
                  onTap: () => _navigateToEditProfile(context, profile),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: AppColors.primaryContainer,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Color(0x1F000000),
                          blurRadius: 6,
                          offset: Offset(0, 2),
                        )
                      ],
                    ),
                    child: const Icon(
                      Icons.edit,
                      size: 16,
                      color: AppColors.onPrimaryContainer,
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          profile.fullName,
          style: AppTextStyles.titleMd.copyWith(color: AppColors.onSurface),
        ),
        Text(
          '@${profile.username}',
          style: AppTextStyles.bodyMd.copyWith(color: AppColors.onSurfaceVariant),
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
              'Edit Profile',
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
                    onPressed: () => context.read<ProfileSocialCubit>().toggleFollow(
                          targetUserId: widget.userId,
                          currentUserId: currentUserId,
                        ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.outlineVariant),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(999),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                    ),
                    child: Text(
                      'Following',
                      style: AppTextStyles.labelLg.copyWith(color: AppColors.onSurfaceVariant),
                    ),
                  );
                } else {
                  return ElevatedButton(
                    onPressed: () => context.read<ProfileSocialCubit>().toggleFollow(
                          targetUserId: widget.userId,
                          currentUserId: currentUserId,
                        ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryContainer,
                      foregroundColor: AppColors.onPrimaryContainer,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(999),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                    ),
                    child: Text(
                      'Follow',
                      style: AppTextStyles.labelLg.copyWith(fontWeight: FontWeight.bold),
                    ),
                  );
                }
              }
              return const SizedBox(
                height: 38,
                width: 100,
                child: Center(child: SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary))),
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
            )
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
                        style: AppTextStyles.headlineLgMobile.copyWith(color: AppColors.primary),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Followers',
                        style: AppTextStyles.labelSm.copyWith(color: AppColors.onSurfaceVariant),
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
                        style: AppTextStyles.headlineLgMobile.copyWith(color: AppColors.primary),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Following',
                        style: AppTextStyles.labelSm.copyWith(color: AppColors.onSurfaceVariant),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Text(
            'INTERESTS',
            style: AppTextStyles.labelLg.copyWith(color: AppColors.onSurfaceVariant, letterSpacing: 1.2),
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
              final isActive = index < 4; // Mock first few as active matching HTML
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isActive ? AppColors.primary.withOpacity(0.1) : AppColors.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    interest,
                    style: AppTextStyles.labelLg.copyWith(
                      color: isActive ? AppColors.primary : AppColors.onSurfaceVariant,
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

  Widget _buildTabsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.onSurfaceVariant,
          indicatorColor: AppColors.primary,
          indicatorWeight: 3.0,
          tabs: const [
            Tab(text: 'Posts'),
            Tab(text: 'Events'),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 400,
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildBentoLayout(),
              const Center(
                child: Text(
                  'لا توجد فعاليات مسجلة حالياً',
                  style: AppTextStyles.bodyMd,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }



  // Replacing posts grid with custom Bento layout widget
  Widget _buildBentoLayout() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left: Big Card
              Expanded(
                flex: 2,
                child: AspectRatio(
                  aspectRatio: 1.0,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: AppColors.surfaceContainer,
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x08000000),
                          blurRadius: 12,
                          offset: Offset(0, 4),
                        )
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.network(
                            'https://lh3.googleusercontent.com/aida-public/AB6AXuDYnqF7_r3ia8jvreX3lzkWpaQFzPaQw9a9ybiApRYiEJirxmvvYJz-y68EIAv5EliuOY1JKewZMUjbq7pUF_f7DHFhckU89l3IWFCU4SXSvQR943YoC4ehP7vncsmsBwM78BHPtT2KYS6Gm-jDmNeaX9q_3qw-urBJYn87IbpCUQZo7hLrNUeAsOb9ig9qEvgLf7UIOq9RwpuAfmcD2n8xH-98upk70OHRCYz6rpoXkgy5ASokd6Ckhu_EuAsXQkyRbnkf2pvY33E',
                            fit: BoxFit.cover,
                          ),
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Colors.black54, Colors.transparent],
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Underground Indie Fest',
                                  style: AppTextStyles.titleMd.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(Icons.location_on, size: 14, color: Colors.white70),
                                    const SizedBox(width: 4),
                                    Text(
                                      'The Warehouse',
                                      style: AppTextStyles.labelLg.copyWith(color: Colors.white70),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Right: Smaller Card
              Expanded(
                flex: 1,
                child: AspectRatio(
                  aspectRatio: 1.0,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: AppColors.surfaceContainer,
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x08000000),
                          blurRadius: 12,
                          offset: Offset(0, 4),
                        )
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.network(
                        'https://lh3.googleusercontent.com/aida-public/AB6AXuCL7tx9RVOTN9MMelJc7xmiC6nks8fJF3inI0X_PTGhayjrIG0SdzGSUEOLKKVME8go1UTVJ_UG-MD_jU-nkuBq9WTFjBMBlAq5lyBraEiZfYkQ3ZKLM1_KW-Dcfq9JLMpYq0bLg7Tnwt5hR51EzR6sVrqKf1us91Q_lU23nuq7g88fktoFfzAsQ4n0JS5W70VUbiYre-Y7XnVs-b7hIgdsBYXTaV-ve5HYSDCnRCKbTb93c9rcrrp9U1KANbLl6fr3ixL_B81mZX8',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              // Quote Card
              Expanded(
                flex: 1,
                child: AspectRatio(
                  aspectRatio: 1.0,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.format_quote, size: 28, color: AppColors.primary),
                        const SizedBox(height: 4),
                        Text(
                          '"Music is the space between the notes."',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.bodyMd.copyWith(
                            fontStyle: FontStyle.italic,
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Gaming Setup Card
              Expanded(
                flex: 1,
                child: AspectRatio(
                  aspectRatio: 1.0,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: AppColors.surfaceContainer,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.network(
                        'https://lh3.googleusercontent.com/aida-public/AB6AXuAXGvn3ifsOWvzqRmk4az_0U9E70GF2S_xMWZcWw0abOIeEaV9vAT77avAHBYtxrrKB-Q2yDBMnpyGqntMZ5Pdbgo1AsnLmN2ZbqzDcUqStKh7bliEwsssDqLLElEuJgizTbTK8gdjwNnfWGE_AwmFtGdzwEdEPgiG93wSTqK0332Zq2e3woMogwTrxfnaj8UKQfLkE8B3p1Dui-UeVe-hmkS0zilP0eeYkkAKXPsfBUrQIOWxWW9DIrQ9fIeHG1xhSq4RHAlWWXpI',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // We override TabBarView's child in _buildTabsSection with:
  // _buildBentoLayout() instead of _buildPostsGrid()

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
      // Reload on pop back
      final authState = context.read<AuthCubit>().state;
      final currentUserId = (authState is AuthSuccess) ? authState.user.id : '';
      context.read<ProfileInfoCubit>().loadProfile(widget.userId);
      context.read<ProfileSocialCubit>().loadSocialStats(widget.userId, currentUserId);
    });
  }

  void _navigateToConnections(BuildContext context, UserProfile profile, int initialIndex) {
    context.push('/profile/${AppRoutes.connections}', extra: {
      'userId': widget.userId,
      'userName': profile.fullName,
      'initialIndex': initialIndex,
    }).then((_) {
      // Reload stats on pop back
      final authState = context.read<AuthCubit>().state;
      final currentUserId = (authState is AuthSuccess) ? authState.user.id : '';
      context.read<ProfileSocialCubit>().loadSocialStats(widget.userId, currentUserId);
    });
  }

}
