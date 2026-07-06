import '../entities/post_entity.dart';
import '../entities/comment_entity.dart';

/// Repository interface defining post and interaction operations.
abstract class PostRepository {
  /// Fetches a paginated feed of posts using cursor-based pagination.
  Future<List<PostEntity>> getPostsFeed({
    required int limit,
    DateTime? lastCreatedAt,
    String? lastPostId,
    String? creatorId,
  });

  /// Fetches a paginated feed of posts liked by a user.
  Future<List<PostEntity>> getLikedPosts({
    required String userId,
    required int limit,
    DateTime? lastLikedAt,
    String? lastPostId,
  });

  /// Searches for posts by text content using Full Text Search (FTS).
  Future<List<PostEntity>> searchPosts({
    required String query,
    required int limit,
    DateTime? lastCreatedAt,
    String? lastPostId,
  });

  /// Creates a new post, with optional local image or video file paths.
  Future<PostEntity> createPost({
    required PostEntity post,
    String? localImagePath,
    String? localVideoPath,
  });

  /// Toggles the like status of a post.
  Future<void> toggleLike({
    required String postId,
    required String userId,
    required bool isCurrentlyLiked,
  });

  /// Fetches all flat comments on a post.
  Future<List<CommentEntity>> getComments(String postId);

  /// Adds a comment to a post.
  Future<CommentEntity> addComment({
    required String postId,
    required String content,
  });

  /// Deletes a comment.
  Future<void> deleteComment(String commentId);

  /// Updates a comment.
  Future<CommentEntity> updateComment({
    required String commentId,
    required String content,
  });

  /// Deletes a post and cleans up associated image storage.
  Future<void> deletePost(String postId);

  /// Updates a post's text content.
  Future<PostEntity> updatePost({
    required String postId,
    required String content,
  });
}
