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

// Events imports
import 'package:tuwaiq_app/features/events/domain/repositories/event_repository.dart';
import 'package:tuwaiq_app/features/events/domain/entities/event_entity.dart';
import 'package:tuwaiq_app/features/events/domain/usecases/create_event_usecase.dart';
import 'package:tuwaiq_app/features/events/domain/usecases/get_event_usecase.dart';
import 'package:tuwaiq_app/features/events/domain/usecases/get_all_events_usecase.dart';

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

class FakeEventRepo implements EventRepository {
  @override
  Future<EventEntity> createEvent({required EventEntity event, String? localImagePath}) async => event;
  @override
  Future<EventEntity> getEventById(String id) async => throw UnimplementedError();
  @override
  Future<List<EventEntity>> getAllEvents() async => [];
  @override
  Future<String> uploadEventCover({required String eventId, required String localFilePath}) async => '';
}

void main() {
  testWidgets('App compiles and loads signIn by default', (WidgetTester tester) async {
    final profileRepo = FakeProfileRepo();
    final eventRepo = FakeEventRepo();
    await tester.pumpWidget(
      MyApp(
        getProfileUseCase: GetProfileUseCase(profileRepo),
        updateProfileUseCase: UpdateProfileUseCase(profileRepo),
        getProfileSocialStatsUseCase: GetProfileSocialStatsUseCase(profileRepo),
        followUserUseCase: FollowUserUseCase(profileRepo),
        unfollowUserUseCase: UnfollowUserUseCase(profileRepo),
        getFollowersUseCase: GetFollowersUseCase(profileRepo),
        getFollowingUseCase: GetFollowingUseCase(profileRepo),
        createEventUseCase: CreateEventUseCase(eventRepo),
        getEventUseCase: GetEventUseCase(eventRepo),
        getAllEventsUseCase: GetAllEventsUseCase(eventRepo),
      ),
    );
  });
}
