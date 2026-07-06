import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../posts/domain/entities/post_entity.dart';
import '../../../posts/domain/usecases/get_liked_posts_usecase.dart';

abstract class ProfileLikesState extends Equatable {
  const ProfileLikesState();
  @override
  List<Object?> get props => [];
}

class ProfileLikesInitial extends ProfileLikesState {}
class ProfileLikesLoading extends ProfileLikesState {}
class ProfileLikesLoaded extends ProfileLikesState {
  final List<PostEntity> posts;
  final bool hasReachedMax;

  const ProfileLikesLoaded({
    required this.posts,
    required this.hasReachedMax,
  });

  @override
  List<Object?> get props => [posts, hasReachedMax];
}
class ProfileLikesError extends ProfileLikesState {
  final String message;
  const ProfileLikesError(this.message);

  @override
  List<Object?> get props => [message];
}

class ProfileLikesCubit extends Cubit<ProfileLikesState> {
  final GetLikedPostsUseCase getLikedPostsUseCase;
  final String userId;
  final int _limit = 10;

  ProfileLikesCubit({
    required this.getLikedPostsUseCase,
    required this.userId,
  }) : super(ProfileLikesInitial());

  Future<void> loadLikes() async {
    emit(ProfileLikesLoading());
    try {
      final posts = await getLikedPostsUseCase(
        userId: userId,
        limit: _limit,
      );
      emit(ProfileLikesLoaded(
        posts: posts,
        hasReachedMax: posts.length < _limit,
      ));
    } catch (e) {
      emit(ProfileLikesError(
        e.toString().replaceAll('Exception: ', '').replaceAll('ServerFailure: ', ''),
      ));
    }
  }

  Future<void> loadMoreLikes() async {
    final currentState = state;
    if (currentState is ProfileLikesLoaded && !currentState.hasReachedMax) {
      try {
        final lastPost = currentState.posts.last;
        final morePosts = await getLikedPostsUseCase(
          userId: userId,
          limit: _limit,
          lastLikedAt: lastPost.likedAt ?? lastPost.createdAt,
          lastPostId: lastPost.id,
        );

        emit(ProfileLikesLoaded(
          posts: List.from(currentState.posts)..addAll(morePosts),
          hasReachedMax: morePosts.length < _limit,
        ));
      } catch (e) {
        // Fail silently to keep UX smooth
      }
    }
  }

  void toggleLike(String postId, bool isLiked, int likeCount) {
    final currentState = state;
    if (currentState is ProfileLikesLoaded) {
      final updatedPosts = currentState.posts.map((post) {
        if (post.id == postId) {
          return post.copyWith(
            isLikedByCurrentUser: isLiked,
            likeCount: likeCount,
          );
        }
        return post;
      }).toList();
      emit(ProfileLikesLoaded(
        posts: updatedPosts,
        hasReachedMax: currentState.hasReachedMax,
      ));
    }
  }
}
