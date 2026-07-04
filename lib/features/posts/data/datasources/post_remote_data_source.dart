import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/post_model.dart';
import '../models/comment_model.dart';

abstract class PostRemoteDataSource {
  Future<List<PostModel>> getPostsFeed({
    required int limit,
    DateTime? lastCreatedAt,
    String? lastPostId,
    String? creatorId,
  });

  Future<PostModel> createPost(PostModel post);

  Future<void> insertLike(String postId, String userId);

  Future<void> deleteLike(String postId, String userId);

  Future<List<CommentModel>> getComments(String postId);

  Future<CommentModel> addComment(CommentModel comment);

  Future<void> deleteComment(String commentId);

  Future<CommentModel> updateComment(String commentId, String content);

  Future<void> deletePost(String postId);

  Future<PostModel> updatePost(String postId, String content);

  Future<String> uploadPostMedia({
    required String postId,
    required String userId,
    required String localFilePath,
  });

  Future<void> deletePostMedia(String mediaUrl);
}

class PostRemoteDataSourceImpl implements PostRemoteDataSource {
  final SupabaseClient _client;

  PostRemoteDataSourceImpl(this._client);

  @override
  Future<List<PostModel>> getPostsFeed({
    required int limit,
    DateTime? lastCreatedAt,
    String? lastPostId,
    String? creatorId,
  }) async {
    var query = _client
        .from('posts')
        .select('*, profiles:profiles!posts_creator_id_fkey(*), post_likes(count), post_comments(count)');

    if (creatorId != null) {
      query = query.eq('creator_id', creatorId);
    }

    // Cursor-based filter: (created_at < lastCreatedAt) OR (created_at = lastCreatedAt AND id < lastPostId)
    if (lastCreatedAt != null && lastPostId != null) {
      final lastTimeStr = lastCreatedAt.toIso8601String();
      query = query.or('created_at.lt.$lastTimeStr,and(created_at.eq.$lastTimeStr,id.lt.$lastPostId)');
    }

    final response = await query
        .order('created_at', ascending: false)
        .order('id', ascending: false)
        .limit(limit);

    final list = response as List? ?? const [];
    final postIds = list.map((json) => json['id'] as String).toList();

    // Query likes for loaded posts to resolve isLikedByCurrentUser in a single batched query
    final currentUserId = _client.auth.currentUser?.id;
    final Set<String> likedPostIds = {};

    if (currentUserId != null && postIds.isNotEmpty) {
      final likesResponse = await _client
          .from('post_likes')
          .select('post_id')
          .eq('user_id', currentUserId)
          .inFilter('post_id', postIds);

      final likesList = likesResponse as List? ?? const [];
      for (final like in likesList) {
        likedPostIds.add(like['post_id'] as String);
      }
    }

    return list.map((json) {
      final postId = json['id'] as String;
      final isLiked = likedPostIds.contains(postId);
      return PostModel.fromJson(json as Map<String, dynamic>, isLiked: isLiked);
    }).toList();
  }

  @override
  Future<PostModel> createPost(PostModel post) async {
    final response = await _client
        .from('posts')
        .insert(post.toJson())
        .select('*, profiles:profiles!posts_creator_id_fkey(*), post_likes(count), post_comments(count)')
        .single();

    return PostModel.fromJson(response);
  }

  @override
  Future<void> insertLike(String postId, String userId) async {
    await _client.from('post_likes').insert({
      'post_id': postId,
      'user_id': userId,
    });
  }

  @override
  Future<void> deleteLike(String postId, String userId) async {
    await _client
        .from('post_likes')
        .delete()
        .eq('post_id', postId)
        .eq('user_id', userId);
  }

  @override
  Future<List<CommentModel>> getComments(String postId) async {
    final response = await _client
        .from('post_comments')
        .select('*, profiles(*)')
        .eq('post_id', postId)
        .order('created_at', ascending: true);

    final list = response as List? ?? const [];
    return list
        .map((json) => CommentModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<CommentModel> addComment(CommentModel comment) async {
    final response = await _client
        .from('post_comments')
        .insert(comment.toJson())
        .select('*, profiles(*)')
        .single();

    return CommentModel.fromJson(response);
  }

  @override
  Future<void> deleteComment(String commentId) async {
    await _client.from('post_comments').delete().eq('id', commentId);
  }

  @override
  Future<CommentModel> updateComment(String commentId, String content) async {
    final response = await _client
        .from('post_comments')
        .update({
          'content': content,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', commentId)
        .select('*, profiles(*)')
        .single();

    return CommentModel.fromJson(response);
  }

  @override
  Future<void> deletePost(String postId) async {
    // Delete the post row and request the deleted row's image_url and video_url
    final response = await _client
        .from('posts')
        .delete()
        .eq('id', postId)
        .select('image_url, video_url')
        .single();

    final imageUrl = response['image_url'] as String?;
    final videoUrl = response['video_url'] as String?;

    // If an image was associated, delete it from storage to prevent leaks
    if (imageUrl != null && imageUrl.isNotEmpty) {
      await deletePostMedia(imageUrl);
    }
    // If a video was associated, delete it from storage to prevent leaks
    if (videoUrl != null && videoUrl.isNotEmpty) {
      await deletePostMedia(videoUrl);
    }
  }

  @override
  Future<PostModel> updatePost(String postId, String content) async {
    final response = await _client
        .from('posts')
        .update({
          'content': content,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', postId)
        .select('*, profiles:profiles!posts_creator_id_fkey(*), post_likes(count), post_comments(count)')
        .single();

    return PostModel.fromJson(response);
  }

  @override
  Future<String> uploadPostMedia({
    required String postId,
    required String userId,
    required String localFilePath,
  }) async {
    final file = File(localFilePath);
    final fileExt = localFilePath.split('.').last;
    final fileName = '${postId}_${DateTime.now().millisecondsSinceEpoch}.$fileExt';
    final path = '$userId/$fileName'; // Structured as posts/{userId}/{fileName}

    // Upload to posts storage bucket
    await _client.storage.from('posts').upload(path, file);

    // Get and return public URL
    final publicUrl = _client.storage.from('posts').getPublicUrl(path);
    return publicUrl;
  }

  @override
  Future<void> deletePostMedia(String mediaUrl) async {
    try {
      // Extract the relative storage path inside the 'posts' bucket
      // Example public URL: https://.../storage/v1/object/public/posts/userId/fileName.jpg
      final path = mediaUrl.split('/public/posts/').last;
      await _client.storage.from('posts').remove([path]);
    } catch (_) {
      // Fail silently to prevent deletion process block if storage cleanup fails
    }
  }
}
