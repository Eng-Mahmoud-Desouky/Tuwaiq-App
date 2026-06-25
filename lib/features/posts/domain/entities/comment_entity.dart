import 'package:equatable/equatable.dart';
import '../../../profile/domain/entities/user_profile.dart';

/// Represents a flat comment on a post in the domain layer.
class CommentEntity extends Equatable {
  final String id;
  final String postId;
  final String creatorId;
  final UserProfile creator;
  final String content;
  final DateTime createdAt;
  final DateTime updatedAt;

  const CommentEntity({
    required this.id,
    required this.postId,
    required this.creatorId,
    required this.creator,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
  });

  CommentEntity copyWith({
    String? id,
    String? postId,
    String? creatorId,
    UserProfile? creator,
    String? content,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CommentEntity(
      id: id ?? this.id,
      postId: postId ?? this.postId,
      creatorId: creatorId ?? this.creatorId,
      creator: creator ?? this.creator,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        postId,
        creatorId,
        creator,
        content,
        createdAt,
        updatedAt,
      ];
}
