import '../entities/user_profile.dart';
import '../entities/profile_social_stats.dart';

abstract class ProfileRepository {
  Future<UserProfile> getProfile(String userId);

  Future<UserProfile> updateProfile({
    required UserProfile profile,
    String? localAvatarPath,
  });

  Future<ProfileSocialStats> getProfileSocialStats({
    required String targetUserId,
    required String currentUserId,
  });

  Future<void> followUser({
    required String followerId,
    required String followedId,
  });

  Future<void> unfollowUser({
    required String followerId,
    required String followedId,
  });

  Future<List<UserProfile>> getFollowers(String userId);

  Future<List<UserProfile>> getFollowing(String userId);
}
