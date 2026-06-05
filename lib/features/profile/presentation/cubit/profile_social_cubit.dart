import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/profile_social_stats.dart';
import '../../domain/usecases/get_profile_social_stats_usecase.dart';
import '../../domain/usecases/follow_user_usecase.dart';
import '../../domain/usecases/unfollow_user_usecase.dart';
import 'profile_social_state.dart';

class ProfileSocialCubit extends Cubit<ProfileSocialState> {
  final GetProfileSocialStatsUseCase getProfileSocialStatsUseCase;
  final FollowUserUseCase followUserUseCase;
  final UnfollowUserUseCase unfollowUserUseCase;

  ProfileSocialCubit({
    required this.getProfileSocialStatsUseCase,
    required this.followUserUseCase,
    required this.unfollowUserUseCase,
  }) : super(ProfileSocialInitial());

  Future<void> loadSocialStats(String targetUserId, String currentUserId) async {
    emit(ProfileSocialLoading());
    try {
      final stats = await getProfileSocialStatsUseCase(
        targetUserId: targetUserId,
        currentUserId: currentUserId,
      );
      emit(ProfileSocialLoaded(stats));
    } catch (e) {
      emit(ProfileSocialError(
        message: e.toString().replaceAll('Failure:', '').replaceAll('ServerFailure:', '').replaceAll('Exception:', '').trim(),
        rollbackStats: const ProfileSocialStats(followersCount: 0, followingCount: 0, isFollowing: false),
      ));
    }
  }

  Future<void> toggleFollow({
    required String targetUserId,
    required String currentUserId,
  }) async {
    final currentState = state;
    if (currentState is! ProfileSocialLoaded) return;

    final rollbackStats = currentState.stats;
    final currentlyFollowing = rollbackStats.isFollowing;

    // Compute optimistic stats
    final optimisticStats = ProfileSocialStats(
      followersCount: currentlyFollowing
          ? (rollbackStats.followersCount - 1).clamp(0, 999999)
          : rollbackStats.followersCount + 1,
      followingCount: rollbackStats.followingCount,
      isFollowing: !currentlyFollowing,
    );

    // Emit optimistic state immediately
    emit(ProfileSocialLoaded(optimisticStats));

    try {
      if (currentlyFollowing) {
        await unfollowUserUseCase(
          followerId: currentUserId,
          followedId: targetUserId,
        );
      } else {
        await followUserUseCase(
          followerId: currentUserId,
          followedId: targetUserId,
        );
      }
    } catch (e) {
      final errorMsg = e.toString().replaceAll('Failure:', '').replaceAll('ServerFailure:', '').replaceAll('Exception:', '').trim();
      
      // Emit error then immediately rollback
      emit(ProfileSocialError(
        message: errorMsg,
        rollbackStats: rollbackStats,
      ));
      emit(ProfileSocialLoaded(rollbackStats));
    }
  }
}
