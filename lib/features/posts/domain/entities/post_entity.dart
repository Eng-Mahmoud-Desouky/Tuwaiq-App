import 'package:equatable/equatable.dart';
import '../../../profile/domain/entities/user_profile.dart';

/// Represents a post in the domain layer of the application.
class PostEntity extends Equatable {
  final String id;
  final String creatorId;
  final UserProfile creator;
  final String? content;
  final String? imageUrl;
  final String? mediaType;
  final String? videoUrl;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int likeCount;
  final int commentCount;
  final bool isLikedByCurrentUser;
  final DateTime? likedAt;

  const PostEntity({
    required this.id,
    required this.creatorId,
    required this.creator,
    this.content,
    this.imageUrl,
    this.mediaType,
    this.videoUrl,
    required this.createdAt,
    required this.updatedAt,
    this.likeCount = 0,
    this.commentCount = 0,
    this.isLikedByCurrentUser = false,
    this.likedAt,
  });

  PostEntity copyWith({
    String? id,
    String? creatorId,
    UserProfile? creator,
    String? content,
    String? imageUrl,
    String? mediaType,
    String? videoUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? likeCount,
    int? commentCount,
    bool? isLikedByCurrentUser,
    DateTime? likedAt,
  }) {
    return PostEntity(
      id: id ?? this.id,
      creatorId: creatorId ?? this.creatorId,
      creator: creator ?? this.creator,
      content: content ?? this.content,
      imageUrl: imageUrl ?? this.imageUrl,
      mediaType: mediaType ?? this.mediaType,
      videoUrl: videoUrl ?? this.videoUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      likeCount: likeCount ?? this.likeCount,
      commentCount: commentCount ?? this.commentCount,
      isLikedByCurrentUser: isLikedByCurrentUser ?? this.isLikedByCurrentUser,
      likedAt: likedAt ?? this.likedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        creatorId,
        creator,
        content,
        imageUrl,
        mediaType,
        videoUrl,
        createdAt,
        updatedAt,
        likeCount,
        commentCount,
        isLikedByCurrentUser,
        likedAt,
      ];
}
