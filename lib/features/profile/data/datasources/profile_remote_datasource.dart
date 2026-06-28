import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_profile_model.dart';
import '../models/profile_social_stats_model.dart';

abstract class ProfileRemoteDataSource {
  Future<UserProfileModel> getProfile(String userId);

  Future<UserProfileModel> updateProfile(UserProfileModel profileModel);

  Future<String> uploadAvatar(String userId, String localFilePath);

  Future<String> uploadCover(String userId, String localFilePath);

  Future<void> deleteAvatarImage(String imageUrl);

  Future<void> deleteCoverImage(String imageUrl);

  Future<ProfileSocialStatsModel> getProfileSocialStats({
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

  Future<List<UserProfileModel>> getFollowers(String userId);

  Future<List<UserProfileModel>> getFollowing(String userId);
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final SupabaseClient _client;

  ProfileRemoteDataSourceImpl(this._client);

  @override
  Future<UserProfileModel> getProfile(String userId) async {
    final response = await _client
        .from('profiles')
        .select()
        .eq('id', userId)
        .single();
    return UserProfileModel.fromJson(response);
  }

  @override
  Future<UserProfileModel> updateProfile(UserProfileModel profileModel) async {
    final response = await _client
        .from('profiles')
        .update(profileModel.toJson())
        .eq('id', profileModel.id)
        .select()
        .single();
    return UserProfileModel.fromJson(response);
  }

  @override
  Future<String> uploadAvatar(String userId, String localFilePath) async {
    final file = File(localFilePath);
    final fileExt = localFilePath.split('.').last;
    final fileName = 'avatar_${DateTime.now().millisecondsSinceEpoch}.$fileExt';
    final path = '$userId/$fileName';

    // Upload to avatars bucket
    await _client.storage.from('avatars').upload(path, file);

    // Get public URL
    final publicUrl = _client.storage.from('avatars').getPublicUrl(path);
    return publicUrl;
  }

  @override
  Future<String> uploadCover(String userId, String localFilePath) async {
    final file = File(localFilePath);
    final fileExt = localFilePath.split('.').last;
    final fileName = 'cover_${DateTime.now().millisecondsSinceEpoch}.$fileExt';
    final path = '$userId/$fileName';

    // Upload to covers bucket
    await _client.storage.from('covers').upload(path, file);

    // Get public URL
    final publicUrl = _client.storage.from('covers').getPublicUrl(path);
    return publicUrl;
  }

  @override
  Future<void> deleteAvatarImage(String imageUrl) async {
    try {
      final path = imageUrl.split('/public/avatars/').last;
      await _client.storage.from('avatars').remove([path]);
    } catch (_) {
      // Fail silently
    }
  }

  @override
  Future<void> deleteCoverImage(String imageUrl) async {
    try {
      final path = imageUrl.split('/public/covers/').last;
      await _client.storage.from('covers').remove([path]);
    } catch (_) {
      // Fail silently
    }
  }

  @override
  Future<ProfileSocialStatsModel> getProfileSocialStats({
    required String targetUserId,
    required String currentUserId,
  }) async {
    // 1. Fetch followers count
    final followersRes = await _client
        .from('follows')
        .select()
        .eq('followed_id', targetUserId)
        .count(CountOption.exact);
    final followersCount = followersRes.count;

    // 2. Fetch following count
    final followingRes = await _client
        .from('follows')
        .select()
        .eq('follower_id', targetUserId)
        .count(CountOption.exact);
    final followingCount = followingRes.count;

    // 3. Fetch isFollowing status
    final isFollowingRes = await _client
        .from('follows')
        .select()
        .eq('follower_id', currentUserId)
        .eq('followed_id', targetUserId)
        .maybeSingle();

    return ProfileSocialStatsModel(
      followersCount: followersCount,
      followingCount: followingCount,
      isFollowing: isFollowingRes != null,
    );
  }

  @override
  Future<void> followUser({
    required String followerId,
    required String followedId,
  }) async {
    await _client.from('follows').insert({
      'follower_id': followerId,
      'followed_id': followedId,
    });
  }

  @override
  Future<void> unfollowUser({
    required String followerId,
    required String followedId,
  }) async {
    await _client
        .from('follows')
        .delete()
        .eq('follower_id', followerId)
        .eq('followed_id', followedId);
  }

  @override
  Future<List<UserProfileModel>> getFollowers(String userId) async {
    final response = await _client
        .from('follows')
        .select('follower:profiles!follower_id(*)')
        .eq('followed_id', userId);

    final list = response as List? ?? const [];
    return list
        .map((item) {
          final followerMap = item['follower'];
          if (followerMap == null) return null;
          return UserProfileModel.fromJson(followerMap as Map<String, dynamic>);
        })
        .whereType<UserProfileModel>()
        .toList();
  }

  @override
  Future<List<UserProfileModel>> getFollowing(String userId) async {
    final response = await _client
        .from('follows')
        .select('followed:profiles!followed_id(*)')
        .eq('follower_id', userId);

    final list = response as List? ?? const [];
    return list
        .map((item) {
          final followedMap = item['followed'];
          if (followedMap == null) return null;
          return UserProfileModel.fromJson(followedMap as Map<String, dynamic>);
        })
        .whereType<UserProfileModel>()
        .toList();
  }
}
