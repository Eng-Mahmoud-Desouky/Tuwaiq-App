import 'package:equatable/equatable.dart';

class UserProfile extends Equatable {
  final String id;
  final String fullName;
  final String username;
  final String? bio;
  final String? avatarUrl;
  final String? coverUrl;
  final List<String> interests;

  const UserProfile({
    required this.id,
    required this.fullName,
    required this.username,
    this.bio,
    this.avatarUrl,
    this.coverUrl,
    this.interests = const [],
  });

  UserProfile copyWith({
    String? id,
    String? fullName,
    String? username,
    String? bio,
    String? avatarUrl,
    String? coverUrl,
    List<String>? interests,
  }) {
    return UserProfile(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      username: username ?? this.username,
      bio: bio ?? this.bio,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      coverUrl: coverUrl ?? this.coverUrl,
      interests: interests ?? this.interests,
    );
  }

  @override
  List<Object?> get props => [
    id,
    fullName,
    username,
    bio,
    avatarUrl,
    coverUrl,
    interests,
  ];
}
