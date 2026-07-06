import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.email,
    required super.username,
    required super.fullName,
    super.avatarUrl,
    super.bio,
    super.interests = const [],
    super.emailConfirmed = false,
    super.isVerified = false,
    super.isAdmin = false,
  });

  factory UserModel.fromJson(
    Map<String, dynamic> json, {
    required String email,
    required bool emailConfirmed,
  }) {
    // Supabase returns interests as text[] which maps to dynamic List or text format.
    final List<String> parsedInterests = json['interests'] != null
        ? List<String>.from(json['interests'] as List)
        : const [];

    return UserModel(
      id: json['id'] as String,
      email: email,
      username: json['username'] as String? ?? '',
      fullName: json['full_name'] as String? ?? '',
      avatarUrl: json['avatar_url'] as String?,
      bio: json['bio'] as String?,
      interests: parsedInterests,
      emailConfirmed: emailConfirmed,
      isVerified: json['is_verified'] as bool? ?? false,
      isAdmin: json['is_admin'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'full_name': fullName,
      'avatar_url': avatarUrl,
      'bio': bio,
      'interests': interests,
      'is_verified': isVerified,
      'is_admin': isAdmin,
    };
  }

  UserEntity toEntity() {
    return UserEntity(
      id: id,
      email: email,
      username: username,
      fullName: fullName,
      avatarUrl: avatarUrl,
      bio: bio,
      interests: interests,
      emailConfirmed: emailConfirmed,
      isVerified: isVerified,
      isAdmin: isAdmin,
    );
  }
}
