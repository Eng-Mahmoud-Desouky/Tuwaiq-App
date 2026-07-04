import '../../../profile/data/models/user_profile_model.dart';
import '../../domain/entities/post_entity.dart';

class PostModel extends PostEntity {
  const PostModel({
    required super.id,
    required super.creatorId,
    required super.creator,
    super.content,
    super.imageUrl,
    super.mediaType,
    super.videoUrl,
    required super.createdAt,
    required super.updatedAt,
    super.likeCount = 0,
    super.commentCount = 0,
    super.isLikedByCurrentUser = false,
  });

  factory PostModel.fromJson(Map<String, dynamic> json, {bool isLiked = false}) {
    final creatorData = json['profiles'];
    final creator = creatorData != null
        ? UserProfileModel.fromJson(creatorData as Map<String, dynamic>).toEntity()
        : UserProfileModel(
            id: json['creator_id'] as String? ?? '',
            fullName: '',
            username: '',
          ).toEntity();

    // Parse counts from PostgREST aggregate select response format
    int parsedLikes = 0;
    if (json['post_likes'] != null) {
      if (json['post_likes'] is List && (json['post_likes'] as List).isNotEmpty) {
        parsedLikes = (json['post_likes'] as List)[0]['count'] as int? ?? 0;
      }
    }

    int parsedComments = 0;
    if (json['post_comments'] != null) {
      if (json['post_comments'] is List && (json['post_comments'] as List).isNotEmpty) {
        parsedComments = (json['post_comments'] as List)[0]['count'] as int? ?? 0;
      }
    }

    return PostModel(
      id: json['id'] as String,
      creatorId: json['creator_id'] as String,
      creator: creator,
      content: json['content'] as String?,
      imageUrl: json['image_url'] as String?,
      mediaType: json['media_type'] as String?,
      videoUrl: json['video_url'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String).toLocal()
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String).toLocal()
          : DateTime.now(),
      likeCount: parsedLikes,
      commentCount: parsedComments,
      isLikedByCurrentUser: isLiked,
    );
  }

  /// Converts the model to JSON for database insert/update operations.
  /// Strictly excludes created_at and updated_at to prevent client timestamp spoofing.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'creator_id': creatorId,
      'content': content,
      'image_url': imageUrl,
      'media_type': mediaType,
      'video_url': videoUrl,
    };
  }

  PostEntity toEntity() {
    return this;
  }
}
