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
import 'package:tuwaiq_app/features/events/domain/usecases/save_event_usecase.dart';
import 'package:tuwaiq_app/features/events/domain/usecases/unsave_event_usecase.dart';
import 'package:tuwaiq_app/features/events/domain/usecases/is_event_saved_usecase.dart';
import 'package:tuwaiq_app/features/events/domain/usecases/get_events_by_user_usecase.dart';
import 'package:tuwaiq_app/features/events/domain/usecases/get_saved_events_usecase.dart';

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
import 'package:tuwaiq_app/features/posts/domain/usecases/delete_comment_usecase.dart';
import 'package:tuwaiq_app/features/posts/domain/usecases/update_comment_usecase.dart';

import 'package:tuwaiq_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:tuwaiq_app/features/auth/domain/entities/user_entity.dart';
import 'package:tuwaiq_app/features/auth/domain/usecases/update_password_usecase.dart';
import 'package:tuwaiq_app/features/notifications/domain/repositories/notifications_repository.dart';
import 'package:tuwaiq_app/features/notifications/domain/entities/notification_entity.dart';
import 'package:tuwaiq_app/features/notifications/domain/usecases/get_notifications_usecase.dart';
import 'package:tuwaiq_app/features/notifications/domain/usecases/mark_notification_as_read_usecase.dart';

class FakeAuthRepo implements AuthRepository {
  @override
  Future<UserEntity> signUp({required String email, required String password, required String username, required String fullName}) async =>
      const UserEntity(id: '', email: '', username: '', fullName: '', interests: [], emailConfirmed: true);
  @override
  Future<UserEntity> signIn({required String email, required String password}) async =>
      const UserEntity(id: '', email: '', username: '', fullName: '', interests: [], emailConfirmed: true);
  @override
  Future<void> signOut() async {}
  @override
  Future<void> forgotPassword({required String email}) async {}
  @override
  Future<void> updatePassword({required String newPassword}) async {}
  @override
  Future<UserEntity?> getCurrentUser() async => null;
  @override
  Future<void> saveUserInterests({required String userId, required List<String> interests}) async {}
}

class FakeProfileRepo implements ProfileRepository {
  @override
  Future<UserProfile> getProfile(String userId) async => UserProfile(id: userId, fullName: '', username: '');
  @override
  Future<UserProfile> updateProfile({
    required UserProfile profile,
    String? localAvatarPath,
    String? localCoverPath,
  }) async => profile;
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

  @override
  Future<void> saveEvent({required String userId, required String eventId}) async {}
  @override
  Future<void> unsaveEvent({required String userId, required String eventId}) async {}
  @override
  Future<bool> isEventSaved({required String userId, required String eventId}) async => false;
  @override
  Future<List<EventEntity>> getEventsByUser(String userId) async => [];
  @override
  Future<List<EventEntity>> getSavedEvents(String userId) async => [];
}

class FakePostRepo implements PostRepository {
  @override
  Future<List<PostEntity>> getPostsFeed({
    required int limit,
    DateTime? lastCreatedAt,
    String? lastPostId,
    String? creatorId,
  }) async => [];
  @override
  Future<PostEntity> createPost({required PostEntity post, String? localImagePath}) async => post;
  @override
  Future<void> toggleLike({required String postId, required String userId, required bool isCurrentlyLiked}) async {}
  @override
  Future<List<CommentEntity>> getComments(String postId) async => [];
  @override
  Future<CommentEntity> addComment({required String postId, required String content}) async => throw UnimplementedError();
  @override
  Future<void> deleteComment(String commentId) async {}
  @override
  Future<CommentEntity> updateComment({required String commentId, required String content}) async => throw UnimplementedError();
  @override
  Future<void> deletePost(String postId) async {}
}

class FakeNotificationsRepo implements NotificationsRepository {
  @override
  Future<void> saveFCMToken({required String userId, required String token, required String platform}) async {}
  @override
  Future<void> deleteFCMToken({required String token}) async {}
  @override
  Future<List<NotificationEntity>> getNotifications({required String userId, required int limit, required int offset}) async => [];
  @override
  Future<void> markAsRead({required String id}) async {}
}

void main() {
  testWidgets('App compiles and loads signIn by default', (WidgetTester tester) async {
    final authRepo = FakeAuthRepo();
    final profileRepo = FakeProfileRepo();
    final eventRepo = FakeEventRepo();
    final postRepo = FakePostRepo();
    final notificationsRepo = FakeNotificationsRepo();

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
        saveEventUseCase: SaveEventUseCase(eventRepo),
        unsaveEventUseCase: UnsaveEventUseCase(eventRepo),
        isEventSavedUseCase: IsEventSavedUseCase(eventRepo),
        getEventsByUserUseCase: GetEventsByUserUseCase(eventRepo),
        getSavedEventsUseCase: GetSavedEventsUseCase(eventRepo),
        getPostsFeedUseCase: GetPostsFeedUseCase(postRepo),
        createPostUseCase: CreatePostUseCase(postRepo),
        toggleLikeUseCase: ToggleLikeUseCase(postRepo),
        getCommentsUseCase: GetCommentsUseCase(postRepo),
        addCommentUseCase: AddCommentUseCase(postRepo),
        deleteCommentUseCase: DeleteCommentUseCase(postRepo),
        updateCommentUseCase: UpdateCommentUseCase(postRepo),
        deletePostUseCase: DeletePostUseCase(postRepo),
        updatePasswordUseCase: UpdatePasswordUseCase(authRepo),
        getNotificationsUseCase: GetNotificationsUseCase(notificationsRepo),
        markNotificationAsReadUseCase: MarkNotificationAsReadUseCase(notificationsRepo),
      ),
    );
  });
}
