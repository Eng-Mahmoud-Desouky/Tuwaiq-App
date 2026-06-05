import '../../domain/entities/profile_social_stats.dart';

class ProfileSocialStatsModel extends ProfileSocialStats {
  const ProfileSocialStatsModel({
    required super.followersCount,
    required super.followingCount,
    required super.isFollowing,
  });

  ProfileSocialStats toEntity() {
    return ProfileSocialStats(
      followersCount: followersCount,
      followingCount: followingCount,
      isFollowing: isFollowing,
    );
  }
}
