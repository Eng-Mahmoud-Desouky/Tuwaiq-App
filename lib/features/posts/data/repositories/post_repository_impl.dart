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
  Future<PostEntity> createPost({
    required PostEntity post,
    String? localImagePath,
  }) async {
    String? uploadedImageUrl;

    try {
      if (localImagePath != null && localImagePath.isNotEmpty) {
        // Upload image first
        uploadedImageUrl = await remoteDataSource.uploadPostImage(
          postId: post.id,
          userId: post.creatorId,
          localFilePath: localImagePath,
        );
      }

      final postModel = PostModel(
        id: post.id,
        creatorId: post.creatorId,
        creator: post.creator,
        content: post.content,
        imageUrl: uploadedImageUrl ?? post.imageUrl,
        createdAt: post.createdAt,
        updatedAt: post.updatedAt,
      );

      // Attempt to save post to the database
      return await remoteDataSource.createPost(postModel);
    } catch (e) {
      // Rollback mechanism: If database insertion failed but an image was uploaded, delete it
      if (uploadedImageUrl != null) {
        await remoteDataSource.deletePostImage(uploadedImageUrl);
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
}
