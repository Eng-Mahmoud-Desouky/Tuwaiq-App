import 'package:equatable/equatable.dart';
import '../../../profile/domain/entities/user_profile.dart';

/// Represents a post in the domain layer of the application.
class PostEntity extends Equatable {
  final String id;
  final String creatorId;
  final UserProfile creator;
  final String content;
  final String? imageUrl;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int likeCount;
  final int commentCount;
  final bool isLikedByCurrentUser;

  const PostEntity({
    required this.id,
    required this.creatorId,
    required this.creator,
    required this.content,
    this.imageUrl,
    required this.createdAt,
    required this.updatedAt,
    this.likeCount = 0,
    this.commentCount = 0,
    this.isLikedByCurrentUser = false,
  });

  PostEntity copyWith({
    String? id,
    String? creatorId,
    UserProfile? creator,
    String? content,
    String? imageUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? likeCount,
    int? commentCount,
    bool? isLikedByCurrentUser,
  }) {
    return PostEntity(
      id: id ?? this.id,
      creatorId: creatorId ?? this.creatorId,
      creator: creator ?? this.creator,
      content: content ?? this.content,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      likeCount: likeCount ?? this.likeCount,
      commentCount: commentCount ?? this.commentCount,
      isLikedByCurrentUser: isLikedByCurrentUser ?? this.isLikedByCurrentUser,
    );
  }

  @override
  List<Object?> get props => [
        id,
        creatorId,
        creator,
        content,
        imageUrl,
        createdAt,
        updatedAt,
        likeCount,
        commentCount,
        isLikedByCurrentUser,
      ];
}
