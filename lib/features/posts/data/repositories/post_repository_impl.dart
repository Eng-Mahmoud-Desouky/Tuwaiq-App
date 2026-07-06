import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../../../profile/domain/entities/user_profile.dart';
import '../../domain/entities/post_entity.dart';
import '../../domain/entities/comment_entity.dart';
import '../../domain/repositories/post_repository.dart';
import '../datasources/post_remote_data_source.dart';
import '../models/post_model.dart';
import '../models/comment_model.dart';

class PostRepositoryImpl implements PostRepository {
  final PostRemoteDataSource remoteDataSource;

  PostRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<PostEntity>> getPostsFeed({
    required int limit,
    DateTime? lastCreatedAt,
    String? lastPostId,
    String? creatorId,
  }) async {
    return await remoteDataSource.getPostsFeed(
      limit: limit,
      lastCreatedAt: lastCreatedAt,
      lastPostId: lastPostId,
      creatorId: creatorId,
    );
  }

  @override
  Future<List<PostEntity>> getLikedPosts({
    required String userId,
    required int limit,
    DateTime? lastLikedAt,
    String? lastPostId,
  }) async {
    return await remoteDataSource.getLikedPosts(
      userId: userId,
      limit: limit,
      lastLikedAt: lastLikedAt,
      lastPostId: lastPostId,
    );
  }

  @override
  Future<List<PostEntity>> searchPosts({
    required String query,
    required int limit,
    DateTime? lastCreatedAt,
    String? lastPostId,
  }) async {
    return await remoteDataSource.searchPosts(
      query: query,
      limit: limit,
      lastCreatedAt: lastCreatedAt,
      lastPostId: lastPostId,
    );
  }

  @override
  Future<PostEntity> createPost({
    required PostEntity post,
    String? localImagePath,
    String? localVideoPath,
  }) async {
    String? uploadedImageUrl;
    String? uploadedVideoUrl;

    try {
      if (localImagePath != null && localImagePath.isNotEmpty) {
        // Upload image first
        uploadedImageUrl = await remoteDataSource.uploadPostMedia(
          postId: post.id,
          userId: post.creatorId,
          localFilePath: localImagePath,
        );
      }

      if (localVideoPath != null && localVideoPath.isNotEmpty) {
        // Upload video next
        uploadedVideoUrl = await remoteDataSource.uploadPostMedia(
          postId: post.id,
          userId: post.creatorId,
          localFilePath: localVideoPath,
        );
      }

      final postModel = PostModel(
        id: post.id,
        creatorId: post.creatorId,
        creator: post.creator,
        content: post.content,
        imageUrl: uploadedImageUrl ?? post.imageUrl,
        videoUrl: uploadedVideoUrl ?? post.videoUrl,
        mediaType: uploadedVideoUrl != null
            ? 'video'
            : (uploadedImageUrl != null ? 'image' : null),
        createdAt: post.createdAt,
        updatedAt: post.updatedAt,
      );

      // Attempt to save post to the database
      return await remoteDataSource.createPost(postModel);
    } catch (e) {
      // Rollback mechanism: If database insertion failed but media was uploaded, delete it
      if (uploadedImageUrl != null) {
        await remoteDataSource.deletePostMedia(uploadedImageUrl);
      }
      if (uploadedVideoUrl != null) {
        await remoteDataSource.deletePostMedia(uploadedVideoUrl);
      }
      rethrow;
    }
  }

  @override
  Future<void> toggleLike({
    required String postId,
    required String userId,
    required bool isCurrentlyLiked,
  }) async {
    if (isCurrentlyLiked) {
      await remoteDataSource.deleteLike(postId, userId);
    } else {
      await remoteDataSource.insertLike(postId, userId);
    }
  }

  @override
  Future<List<CommentEntity>> getComments(String postId) async {
    return await remoteDataSource.getComments(postId);
  }

  @override
  Future<CommentEntity> addComment({
    required String postId,
    required String content,
  }) async {
    final commentId = const Uuid().v4();
    final currentUserId = Supabase.instance.client.auth.currentUser?.id ?? '';

    final commentModel = CommentModel(
      id: commentId,
      postId: postId,
      creatorId: currentUserId,
      creator: const UserProfile(id: '', fullName: '', username: ''),
      content: content,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    return await remoteDataSource.addComment(commentModel);
  }

  @override
  Future<void> deleteComment(String commentId) async {
    await remoteDataSource.deleteComment(commentId);
  }

  @override
  Future<CommentEntity> updateComment({
    required String commentId,
    required String content,
  }) async {
    return await remoteDataSource.updateComment(commentId, content);
  }

  @override
  Future<void> deletePost(String postId) async {
    await remoteDataSource.deletePost(postId);
  }

  @override
  Future<PostEntity> updatePost({
    required String postId,
    required String content,
  }) async {
    return await remoteDataSource.updatePost(postId, content);
  }
}
