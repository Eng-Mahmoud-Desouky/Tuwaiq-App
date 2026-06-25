import '../../../profile/data/models/user_profile_model.dart';
import '../../domain/entities/comment_entity.dart';

class CommentModel extends CommentEntity {
  const CommentModel({
    required super.id,
    required super.postId,
    required super.creatorId,
    required super.creator,
    required super.content,
    required super.createdAt,
    required super.updatedAt,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    final creatorData = json['profiles'];
    final creator = creatorData != null
        ? UserProfileModel.fromJson(creatorData as Map<String, dynamic>).toEntity()
        : UserProfileModel(
            id: json['creator_id'] as String? ?? '',
            fullName: '',
            username: '',
          ).toEntity();

    return CommentModel(
      id: json['id'] as String,
      postId: json['post_id'] as String,
      creatorId: json['creator_id'] as String,
      creator: creator,
      content: json['content'] as String? ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String).toLocal()
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String).toLocal()
          : DateTime.now(),
    );
  }

  /// Converts the model to JSON for database insert.
  /// Excludes created_at and updated_at to prevent client timestamp spoofing.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'post_id': postId,
      'creator_id': creatorId,
      'content': content,
    };
  }

  CommentEntity toEntity() {
    return this;
  }
}
