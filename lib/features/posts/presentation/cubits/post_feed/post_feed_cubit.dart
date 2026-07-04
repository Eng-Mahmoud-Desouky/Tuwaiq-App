import 'dart:async';
import 'dart:math';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/post_entity.dart';
import '../../../domain/usecases/get_posts_feed_usecase.dart';
import '../../../domain/usecases/toggle_like_usecase.dart';
import '../../../domain/usecases/delete_post_usecase.dart';
import '../../../../events/domain/usecases/get_all_events_usecase.dart';
import '../../../domain/usecases/update_post_usecase.dart';
import 'post_feed_state.dart';

class PostFeedCubit extends Cubit<PostFeedState> {
  final GetPostsFeedUseCase getPostsFeedUseCase;
  final ToggleLikeUseCase toggleLikeUseCase;
  final DeletePostUseCase deletePostUseCase;
  final GetAllEventsUseCase getAllEventsUseCase;
  final UpdatePostUseCase updatePostUseCase;

  static const int _limit = 10;
  final Map<String, Timer> _likeDebouncers = {};
  final Map<String, bool> _originalLikeStates = {};


  PostFeedCubit({
    required this.getPostsFeedUseCase,
    required this.toggleLikeUseCase,
    required this.deletePostUseCase,
    required this.getAllEventsUseCase,
    required this.updatePostUseCase,
  }) : super(const PostFeedInitial());



  /// Initial fetch of posts feed.
  Future<void> loadPosts() async {
    emit(const PostFeedLoading());
    try {
      final posts = await getPostsFeedUseCase(limit: _limit);

      emit(PostFeedLoaded(
        posts: posts,
        hasReachedMax: posts.length < _limit,
      ));
    } catch (e) {
      emit(PostFeedError(message: 'فشل تحميل المنشورات: ${e.toString()}'));
    }
  }

  /// Paginated scroll load of next post batch.
  Future<void> loadMorePosts() async {
    final currentState = state;
    if (currentState is! PostFeedLoaded || currentState.hasReachedMax) return;

    try {
      final postsOnly = currentState.posts.whereType<PostEntity>().toList();
      if (postsOnly.isEmpty) return;

      final lastPost = postsOnly.last;
      final morePosts = await getPostsFeedUseCase(
        limit: _limit,
        lastCreatedAt: lastPost.createdAt,
        lastPostId: lastPost.id,
      );

      emit(PostFeedLoaded(
        posts: currentState.posts + morePosts,
        hasReachedMax: morePosts.length < _limit,
      ));
    } catch (_) {
      // Keep state as is on pagination failure
    }
  }

  /// Toggles post like with Optimistic UI updates and 500ms debounce.
  Future<void> toggleLikePost({
    required String postId,
    required String userId,
  }) async {
    final currentState = state;
    if (currentState is! PostFeedLoaded) return;

    final posts = List<dynamic>.from(currentState.posts);
    final index = posts.indexWhere((p) => p is PostEntity && p.id == postId);
    if (index == -1) return;

    final post = posts[index] as PostEntity;
    final bool originalLiked = post.isLikedByCurrentUser;
    final int originalCount = post.likeCount;

    // Cache original state if not already set (first tap of a sequence)
    if (!_originalLikeStates.containsKey(postId)) {
      _originalLikeStates[postId] = originalLiked;
    }

    // 1. Optimistic Update (Immediate UI response)
    final bool newLiked = !originalLiked;
    final int newCount = newLiked ? originalCount + 1 : originalCount - 1;

    posts[index] = post.copyWith(
      isLikedByCurrentUser: newLiked,
      likeCount: newCount,
    );
    emit(currentState.copyWith(posts: posts));

    // 2. Debouncing logic (500ms)
    _likeDebouncers[postId]?.cancel();
    _likeDebouncers[postId] = Timer(const Duration(milliseconds: 500), () async {
      _likeDebouncers.remove(postId);
      
      final finalLiked = newLiked;
      final finalOriginal = _originalLikeStates.remove(postId) ?? originalLiked;

      // Only perform database operation if final state differs from initial
      if (finalLiked != finalOriginal) {
        try {
          await toggleLikeUseCase(
            postId: postId,
            userId: userId,
            isCurrentlyLiked: finalOriginal,
          );
        } catch (_) {
          // Revert on DB error
          final currentLoadedState = state;
          if (currentLoadedState is PostFeedLoaded) {
            final rollbackPosts = List<dynamic>.from(currentLoadedState.posts);
            final rollbackIndex = rollbackPosts.indexWhere((p) => p is PostEntity && p.id == postId);
            if (rollbackIndex != -1) {
              final p = rollbackPosts[rollbackIndex] as PostEntity;
              rollbackPosts[rollbackIndex] = p.copyWith(
                isLikedByCurrentUser: finalOriginal,
                likeCount: finalOriginal ? p.likeCount + 1 : p.likeCount - 1,
              );
              emit(currentLoadedState.copyWith(posts: rollbackPosts));
            }
          }
        }
      }
    });
  }

  /// Deletes a post.
  Future<void> deletePost(String postId) async {
    final currentState = state;
    if (currentState is! PostFeedLoaded) return;

    try {
      await deletePostUseCase(postId);
      final updatedPosts = currentState.posts.where((p) {
        if (p is PostEntity) {
          return p.id != postId;
        }
        return true;
      }).toList();
      emit(PostFeedLoaded(
        posts: updatedPosts,
        hasReachedMax: currentState.hasReachedMax,
      ));
    } catch (_) {
      // Revert or show error could be handled, for simplicity keep state unchanged
    }
  }

  /// Invoked when a new post is successfully created to prepend to feed.
  void onPostAdded(PostEntity newPost) {
    final currentState = state;
    if (currentState is PostFeedLoaded) {
      final updatedPosts = [newPost, ...currentState.posts];
      emit(PostFeedLoaded(
        posts: updatedPosts,
        hasReachedMax: currentState.hasReachedMax,
      ));
    }
  }

  /// Updates a post's content in the feed.
  Future<void> updatePost({
    required String postId,
    required String content,
  }) async {
    final currentState = state;
    if (currentState is! PostFeedLoaded) return;

    final currentPosts = List<dynamic>.from(currentState.posts);
    final index = currentPosts.indexWhere((p) => p is PostEntity && p.id == postId);
    if (index == -1) return;

    final originalPost = currentPosts[index] as PostEntity;
    final updatedPost = originalPost.copyWith(content: content, updatedAt: DateTime.now());
    currentPosts[index] = updatedPost;
    emit(currentState.copyWith(posts: currentPosts));

    try {
      await updatePostUseCase(postId: postId, content: content);
    } catch (_) {
      // Revert on error
      currentPosts[index] = originalPost;
      emit(currentState.copyWith(posts: currentPosts));
    }
  }

  /// Increments comments count of a post in state upon addition.
  void onCommentAdded(String postId) {
    final currentState = state;
    if (currentState is PostFeedLoaded) {
      final posts = List<dynamic>.from(currentState.posts);
      final index = posts.indexWhere((p) => p is PostEntity && p.id == postId);
      if (index != -1) {
        final post = posts[index] as PostEntity;
        posts[index] = post.copyWith(
          commentCount: post.commentCount + 1,
        );
        emit(currentState.copyWith(posts: posts));
      }
    }
  }

  /// Decrements comments count of a post in state upon deletion.
  void onCommentDeleted(String postId) {
    final currentState = state;
    if (currentState is PostFeedLoaded) {
      final posts = List<dynamic>.from(currentState.posts);
      final index = posts.indexWhere((p) => p is PostEntity && p.id == postId);
      if (index != -1) {
        final post = posts[index] as PostEntity;
        posts[index] = post.copyWith(
          commentCount: max(0, post.commentCount - 1),
        );
        emit(currentState.copyWith(posts: posts));
      }
    }
  }

  @override
  Future<void> close() {
    for (final timer in _likeDebouncers.values) {
      timer.cancel();
    }
    return super.close();
  }
}
