import '../../domain/entities/user_profile.dart';

class UserProfileModel extends UserProfile {
  const UserProfileModel({
    required super.id,
    required super.fullName,
    required super.username,
    super.bio,
    super.avatarUrl,
    super.interests = const [],
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    final List<String> parsedInterests = json['interests'] != null
        ? List<String>.from(json['interests'] as List)
        : const [];

    return UserProfileModel(
      id: json['id'] as String,
      fullName: json['full_name'] as String? ?? '',
      username: json['username'] as String? ?? '',
      avatarUrl: json['avatar_url'] as String?,
      bio: json['bio'] as String?,
      interests: parsedInterests,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'username': username,
      'bio': bio,
      'avatar_url': avatarUrl,
      'interests': interests,
    };
  }

  UserProfile toEntity() {
    return UserProfile(
      id: id,
      fullName: fullName,
      username: username,
      bio: bio,
      avatarUrl: avatarUrl,
      interests: interests,
    );
  }
}
