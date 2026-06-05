import 'package:equatable/equatable.dart';

class ProfileSocialStats extends Equatable {
  final int followersCount;
  final int followingCount;
  final bool isFollowing;

  const ProfileSocialStats({
    required this.followersCount,
    required this.followingCount,
    required this.isFollowing,
  });

  ProfileSocialStats copyWith({
    int? followersCount,
    int? followingCount,
    bool? isFollowing,
  }) {
    return ProfileSocialStats(
      followersCount: followersCount ?? this.followersCount,
      followingCount: followingCount ?? this.followingCount,
      isFollowing: isFollowing ?? this.isFollowing,
    );
  }

  @override
  List<Object?> get props => [followersCount, followingCount, isFollowing];
}
