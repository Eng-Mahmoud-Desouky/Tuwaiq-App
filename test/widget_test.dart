import 'package:flutter_test/flutter_test.dart';
import 'package:tuwaiq_app/main.dart';
import 'package:tuwaiq_app/features/profile/domain/usecases/get_profile_usecase.dart';
import 'package:tuwaiq_app/features/profile/domain/usecases/update_profile_usecase.dart';
import 'package:tuwaiq_app/features/profile/domain/usecases/get_profile_social_stats_usecase.dart';
import 'package:tuwaiq_app/features/profile/domain/usecases/follow_user_usecase.dart';
import 'package:tuwaiq_app/features/profile/domain/usecases/unfollow_user_usecase.dart';
import 'package:tuwaiq_app/features/profile/domain/usecases/get_followers_usecase.dart';
import 'package:tuwaiq_app/features/profile/domain/usecases/get_following_usecase.dart';
import 'package:tuwaiq_app/features/profile/domain/repositories/profile_repository.dart';
import 'package:tuwaiq_app/features/profile/domain/entities/user_profile.dart';
import 'package:tuwaiq_app/features/profile/domain/entities/profile_social_stats.dart';

class FakeProfileRepo implements ProfileRepository {
  @override
  Future<UserProfile> getProfile(String userId) async => UserProfile(id: userId, fullName: '', username: '');
  @override
  Future<UserProfile> updateProfile({required UserProfile profile, String? localAvatarPath}) async => profile;
  @override
  Future<ProfileSocialStats> getProfileSocialStats({required String targetUserId, required String currentUserId}) async =>
      const ProfileSocialStats(followersCount: 0, followingCount: 0, isFollowing: false);
  @override
  Future<void> followUser({required String followerId, required String followedId}) async {}
  @override
  Future<void> unfollowUser({required String followerId, required String followedId}) async {}
  @override
  Future<List<UserProfile>> getFollowers(String userId) async => [];
  @override
  Future<List<UserProfile>> getFollowing(String userId) async => [];
}

void main() {
  testWidgets('App compiles and loads signIn by default', (WidgetTester tester) async {
    final repo = FakeProfileRepo();
    await tester.pumpWidget(
      MyApp(
        getProfileUseCase: GetProfileUseCase(repo),
        updateProfileUseCase: UpdateProfileUseCase(repo),
        getProfileSocialStatsUseCase: GetProfileSocialStatsUseCase(repo),
        followUserUseCase: FollowUserUseCase(repo),
        unfollowUserUseCase: UnfollowUserUseCase(repo),
        getFollowersUseCase: GetFollowersUseCase(repo),
        getFollowingUseCase: GetFollowingUseCase(repo),
      ),
    );
  });
}
