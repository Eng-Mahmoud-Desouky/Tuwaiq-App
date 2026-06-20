import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import '../../domain/entities/user_profile.dart';
import '../cubit/connections_cubit.dart';
import '../cubit/connections_state.dart';

class SocialConnectionsScreen extends StatefulWidget {
  final String targetUserId;
  final String targetUserName;
  final int initialIndex;

  const SocialConnectionsScreen({
    super.key,
    required this.targetUserId,
    required this.targetUserName,
    required this.initialIndex,
  });

  @override
  State<SocialConnectionsScreen> createState() =>
      _SocialConnectionsScreenState();
}

class _SocialConnectionsScreenState extends State<SocialConnectionsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialIndex,
    );
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

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceContainerLowest,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.targetUserName,
          style: AppTextStyles.titleMd.copyWith(color: AppColors.onSurface),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.onSurfaceVariant,
          indicatorColor: AppColors.primary,
          indicatorWeight: 3.0,
          tabs: const [
            Tab(text: 'Followers'),
            Tab(text: 'Following'),
          ],
        ),
      ),
      body: BlocBuilder<ConnectionsCubit, ConnectionsState>(
        builder: (context, state) {
          if (state is ConnectionsLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          } else if (state is ConnectionsLoaded) {
            return TabBarView(
              controller: _tabController,
              children: [
                _buildUserList(
                  state.followers,
                  state.followedUserIds,
                  currentUserId,
                ),
                _buildUserList(
                  state.following,
                  state.followedUserIds,
                  currentUserId,
                ),
              ],
            );
          } else if (state is ConnectionsError) {
            return Center(
              child: Text(
                state.message,
                style: AppTextStyles.bodyLg.copyWith(color: AppColors.error),
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildUserList(
    List<UserProfile> users,
    Set<String> followedUserIds,
    String currentUserId,
  ) {
    if (users.isEmpty) {
      return const Center(
        child: Text('لا يوجد مستخدمون حالياً', style: AppTextStyles.bodyMd),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user = users[index];
        final isMe = user.id == currentUserId;
        final isFollowing = followedUserIds.contains(user.id);

        return Card(
          color: AppColors.surfaceContainerLowest,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                // Avatar
                GestureDetector(
                  onTap: () => _navigateToProfile(context, user.id),
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.surfaceContainerHighest,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child:
                          user.avatarUrl != null && user.avatarUrl!.isNotEmpty
                          ? Image.network(
                              user.avatarUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  _buildDefaultAvatar(user.fullName),
                            )
                          : _buildDefaultAvatar(user.fullName),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Name / Username
                Expanded(
                  child: GestureDetector(
                    onTap: () => _navigateToProfile(context, user.id),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.fullName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.labelLg.copyWith(
                            color: AppColors.onSurface,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '@${user.username}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.labelSm.copyWith(
                            color: AppColors.onSurfaceVariant,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Follow / Following Button
                if (!isMe)
                  isFollowing
                      ? OutlinedButton(
                          onPressed: () =>
                              _toggleFollow(context, user.id, currentUserId),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(
                              color: AppColors.outlineVariant,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(999),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 8,
                            ),
                          ),
                          child: Text(
                            'Following',
                            style: AppTextStyles.labelSm.copyWith(
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        )
                      : ElevatedButton(
                          onPressed: () =>
                              _toggleFollow(context, user.id, currentUserId),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryContainer,
                            foregroundColor: AppColors.onPrimaryContainer,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(999),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 22,
                              vertical: 8,
                            ),
                          ),
                          child: Text(
                            'Follow',
                            style: AppTextStyles.labelSm.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDefaultAvatar(String name) {
    final initial = name.isNotEmpty ? name.substring(0, 1).toUpperCase() : '?';
    return Center(
      child: Text(
        initial,
        style: AppTextStyles.labelLg.copyWith(color: AppColors.primary),
      ),
    );
  }

  void _navigateToProfile(BuildContext context, String userId) {
    Navigator.pushNamed(context, AppRoutes.profile, arguments: userId);
  }

  void _toggleFollow(
    BuildContext context,
    String targetUserId,
    String currentUserId,
  ) {
    context.read<ConnectionsCubit>().toggleFollowUser(
      targetUserId: targetUserId,
      currentUserId: currentUserId,
    );
  }
}
