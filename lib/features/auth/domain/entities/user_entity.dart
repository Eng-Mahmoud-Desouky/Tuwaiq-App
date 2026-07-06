import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String id;
  final String email;
  final String username;
  final String fullName;
  final String? avatarUrl;
  final String? bio;
  final List<String> interests;
  final bool emailConfirmed;
  final bool isVerified;
  final bool isAdmin;

  const UserEntity({
    required this.id,
    required this.email,
    required this.username,
    required this.fullName,
    this.avatarUrl,
    this.bio,
    this.interests = const [],
    this.emailConfirmed = false,
    this.isVerified = false,
    this.isAdmin = false,
  });

  UserEntity copyWith({
    String? id,
    String? email,
    String? username,
    String? fullName,
    String? avatarUrl,
    String? bio,
    List<String>? interests,
    bool? emailConfirmed,
    bool? isVerified,
    bool? isAdmin,
  }) {
    return UserEntity(
      id: id ?? this.id,
      email: email ?? this.email,
      username: username ?? this.username,
      fullName: fullName ?? this.fullName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      bio: bio ?? this.bio,
      interests: interests ?? this.interests,
      emailConfirmed: emailConfirmed ?? this.emailConfirmed,
      isVerified: isVerified ?? this.isVerified,
      isAdmin: isAdmin ?? this.isAdmin,
    );
  }

  @override
  List<Object?> get props => [
    id,
    email,
    username,
    fullName,
    avatarUrl,
    bio,
    interests,
    emailConfirmed,
    isVerified,
    isAdmin,
  ];
}
