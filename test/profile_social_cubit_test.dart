import 'package:flutter_test/flutter_test.dart';
import 'package:tuwaiq_app/features/profile/domain/entities/profile_social_stats.dart';
import 'package:tuwaiq_app/features/profile/domain/entities/user_profile.dart';
import 'package:tuwaiq_app/features/profile/domain/repositories/profile_repository.dart';
import 'package:tuwaiq_app/features/profile/domain/usecases/follow_user_usecase.dart';
import 'package:tuwaiq_app/features/profile/domain/usecases/get_profile_social_stats_usecase.dart';
import 'package:tuwaiq_app/features/profile/domain/usecases/unfollow_user_usecase.dart';
import 'package:tuwaiq_app/features/profile/presentation/cubit/profile_social_cubit.dart';
import 'package:tuwaiq_app/features/profile/presentation/cubit/profile_social_state.dart';

class FakeProfileRepository implements ProfileRepository {
  bool shouldFail = false;
  int followCountCall = 0;
  int unfollowCountCall = 0;

  @override
  Future<UserProfile> getProfile(String userId) async {
    return UserProfile(id: userId, fullName: 'Test User', username: 'test_user');
  }

  @override
  Future<UserProfile> updateProfile({required UserProfile profile, String? localAvatarPath}) async {
    return profile;
  }

  @override
  Future<ProfileSocialStats> getProfileSocialStats({
    required String targetUserId,
    required String currentUserId,
  }) async {
    return const ProfileSocialStats(followersCount: 10, followingCount: 5, isFollowing: false);
  }

  @override
  Future<void> followUser({required String followerId, required String followedId}) async {
    followCountCall++;
    if (shouldFail) {
      throw Exception('Database Connection Error');
    }
  }

  @override
  Future<void> unfollowUser({required String followerId, required String followedId}) async {
    unfollowCountCall++;
    if (shouldFail) {
      throw Exception('Database Connection Error');
    }
  }

  @override
  Future<List<UserProfile>> getFollowers(String userId) async => [];

  @override
  Future<List<UserProfile>> getFollowing(String userId) async => [];
}

void main() {
  late FakeProfileRepository repository;
  late ProfileSocialCubit cubit;

  setUp(() {
    repository = FakeProfileRepository();
    cubit = ProfileSocialCubit(
      getProfileSocialStatsUseCase: GetProfileSocialStatsUseCase(repository),
      followUserUseCase: FollowUserUseCase(repository),
      unfollowUserUseCase: UnfollowUserUseCase(repository),
    );
  });

  tearDown(() {
    cubit.close();
  });

  test('initial state should be ProfileSocialInitial', () {
    expect(cubit.state, ProfileSocialInitial());
  });

  test('loadSocialStats should load stats successfully', () async {
    final Future<void> expectation = expectLater(
      cubit.stream,
      emitsInOrder([
        ProfileSocialLoading(),
        const ProfileSocialLoaded(
          ProfileSocialStats(followersCount: 10, followingCount: 5, isFollowing: false),
        ),
      ]),
    );

    await cubit.loadSocialStats('target_id', 'current_id');
    await expectation;
  });

  test('toggleFollow should optimistically update follow status and increment follower count', () async {
    // 1. Manually emit loaded state to simulate loaded stats
    const initialStats = ProfileSocialStats(followersCount: 10, followingCount: 5, isFollowing: false);
    cubit.emit(const ProfileSocialLoaded(initialStats));

    // 2. We expect it to immediately emit isFollowing: true, followersCount: 11
    final Future<void> expectation = expectLater(
      cubit.stream,
      emitsInOrder([
        const ProfileSocialLoaded(
          ProfileSocialStats(followersCount: 11, followingCount: 5, isFollowing: true),
        ),
      ]),
    );

    await cubit.toggleFollow(targetUserId: 'target_id', currentUserId: 'current_id');
    await expectation;
    
    expect(repository.followCountCall, 1);
  });

  test('toggleFollow should rollback and emit error if follow action fails', () async {
    // 1. Set repository to fail
    repository.shouldFail = true;

    // 2. Manually emit loaded state
    const initialStats = ProfileSocialStats(followersCount: 10, followingCount: 5, isFollowing: false);
    cubit.emit(const ProfileSocialLoaded(initialStats));

    // 3. We expect it to emit optimistic state (11 followers, isFollowing: true),
    // followed by ProfileSocialError, followed immediately by original state rollback (10 followers, isFollowing: false)
    final Future<void> expectation = expectLater(
      cubit.stream,
      emitsInOrder([
        const ProfileSocialLoaded(
          ProfileSocialStats(followersCount: 11, followingCount: 5, isFollowing: true),
        ),
        const ProfileSocialError(
          message: 'Database Connection Error',
          rollbackStats: initialStats,
        ),
        const ProfileSocialLoaded(initialStats),
      ]),
    );

    await cubit.toggleFollow(targetUserId: 'target_id', currentUserId: 'current_id');
    await expectation;
  });
}
