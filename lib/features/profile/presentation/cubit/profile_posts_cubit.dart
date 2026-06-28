import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../posts/domain/entities/post_entity.dart';
import '../../../posts/domain/usecases/get_posts_feed_usecase.dart';

abstract class ProfilePostsState extends Equatable {
  const ProfilePostsState();
  @override
  List<Object?> get props => [];
}

class ProfilePostsInitial extends ProfilePostsState {}
class ProfilePostsLoading extends ProfilePostsState {}
class ProfilePostsLoaded extends ProfilePostsState {
  final List<PostEntity> posts;
  final bool hasReachedMax;

  const ProfilePostsLoaded({
    required this.posts,
    required this.hasReachedMax,
  });

  @override
  List<Object?> get props => [posts, hasReachedMax];
}
class ProfilePostsError extends ProfilePostsState {
  final String message;
  const ProfilePostsError(this.message);

  @override
  List<Object?> get props => [message];
}

class ProfilePostsCubit extends Cubit<ProfilePostsState> {
  final GetPostsFeedUseCase getPostsFeedUseCase;
  final String userId;
  final int _limit = 10;

  ProfilePostsCubit({
    required this.getPostsFeedUseCase,
    required this.userId,
  }) : super(ProfilePostsInitial());

  Future<void> loadPosts() async {
    emit(ProfilePostsLoading());
    try {
      final posts = await getPostsFeedUseCase(
        limit: _limit,
        creatorId: userId,
      );
      emit(ProfilePostsLoaded(
        posts: posts,
        hasReachedMax: posts.length < _limit,
      ));
    } catch (e) {
      emit(ProfilePostsError(
        e.toString().replaceAll('Exception: ', '').replaceAll('ServerFailure: ', ''),
      ));
    }
  }

  Future<void> loadMorePosts() async {
    final currentState = state;
    if (currentState is ProfilePostsLoaded && !currentState.hasReachedMax) {
      try {
        final lastPost = currentState.posts.last;
        final morePosts = await getPostsFeedUseCase(
          limit: _limit,
          lastCreatedAt: lastPost.createdAt,
          lastPostId: lastPost.id,
          creatorId: userId,
        );

        emit(ProfilePostsLoaded(
          posts: List.from(currentState.posts)..addAll(morePosts),
          hasReachedMax: morePosts.length < _limit,
        ));
      } catch (e) {
        // Keep current state on error
      }
    }
  }
}
