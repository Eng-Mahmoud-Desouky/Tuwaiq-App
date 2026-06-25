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

// Posts imports
import 'package:tuwaiq_app/features/posts/domain/repositories/post_repository.dart';
import 'package:tuwaiq_app/features/posts/domain/entities/post_entity.dart';
import 'package:tuwaiq_app/features/posts/domain/entities/comment_entity.dart';
import 'package:tuwaiq_app/features/posts/domain/usecases/create_post_usecase.dart';
import 'package:tuwaiq_app/features/posts/domain/usecases/get_posts_feed_usecase.dart';
import 'package:tuwaiq_app/features/posts/domain/usecases/toggle_like_usecase.dart';
import 'package:tuwaiq_app/features/posts/domain/usecases/get_comments_usecase.dart';
import 'package:tuwaiq_app/features/posts/domain/usecases/add_comment_usecase.dart';
import 'package:tuwaiq_app/features/posts/domain/usecases/delete_post_usecase.dart';

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

class FakePostRepo implements PostRepository {
  @override
  Future<List<PostEntity>> getPostsFeed({required int limit, DateTime? lastCreatedAt, String? lastPostId}) async => [];
  @override
  Future<PostEntity> createPost({required PostEntity post, String? localImagePath}) async => post;
  @override
  Future<void> toggleLike({required String postId, required String userId, required bool isCurrentlyLiked}) async {}
  @override
  Future<List<CommentEntity>> getComments(String postId) async => [];
  @override
  Future<CommentEntity> addComment({required String postId, required String content}) async => throw UnimplementedError();
  @override
  Future<void> deletePost(String postId) async {}
}

void main() {
  testWidgets('App compiles and loads signIn by default', (WidgetTester tester) async {
    final profileRepo = FakeProfileRepo();
    final eventRepo = FakeEventRepo();
    final postRepo = FakePostRepo();

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
        getPostsFeedUseCase: GetPostsFeedUseCase(postRepo),
        createPostUseCase: CreatePostUseCase(postRepo),
        toggleLikeUseCase: ToggleLikeUseCase(postRepo),
        getCommentsUseCase: GetCommentsUseCase(postRepo),
        addCommentUseCase: AddCommentUseCase(postRepo),
        deletePostUseCase: DeletePostUseCase(postRepo),
      ),
    );
  });
}
