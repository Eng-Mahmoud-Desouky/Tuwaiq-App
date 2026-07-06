import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'explore_state.dart';
import '../../../posts/domain/usecases/search_posts_usecase.dart';
import '../../../profile/domain/usecases/search_profiles_usecase.dart';

class ExploreCubit extends Cubit<ExploreState> {
  final SearchPostsUseCase searchPostsUseCase;
  final SearchProfilesUseCase searchProfilesUseCase;
  final int _limit = 10;
  Timer? _debounceTimer;

  ExploreCubit({
    required this.searchPostsUseCase,
    required this.searchProfilesUseCase,
  }) : super(const ExploreInitial());

  void onSearchTextChanged(String query) {
    _debounceTimer?.cancel();
    if (query.trim().isEmpty) {
      emit(const ExploreInitial());
      return;
    }

    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      performSearch(query.trim());
    });
  }

  Future<void> performSearch(String query) async {
    emit(const ExploreSearchLoading());
    try {
      final posts = await searchPostsUseCase(query: query, limit: _limit);
      final accounts = await searchProfilesUseCase(query: query, limit: _limit, offset: 0);

      emit(ExploreSearchLoaded(
        query: query,
        posts: posts,
        accounts: accounts,
        postsHasReachedMax: posts.length < _limit,
        accountsHasReachedMax: accounts.length < _limit,
      ));
    } catch (e) {
      emit(ExploreSearchError(
        e.toString().replaceAll('Exception: ', '').replaceAll('ServerFailure: ', ''),
      ));
    }
  }

  Future<void> loadMorePosts() async {
    final currentState = state;
    if (currentState is ExploreSearchLoaded &&
        !currentState.postsHasReachedMax &&
        !currentState.isLoadingMorePosts) {
      
      emit(currentState.copyWith(isLoadingMorePosts: true));
      try {
        final lastPost = currentState.posts.last;
        final morePosts = await searchPostsUseCase(
          query: currentState.query,
          limit: _limit,
          lastCreatedAt: lastPost.createdAt,
          lastPostId: lastPost.id,
        );

        emit(currentState.copyWith(
          posts: List.from(currentState.posts)..addAll(morePosts),
          postsHasReachedMax: morePosts.length < _limit,
          isLoadingMorePosts: false,
        ));
      } catch (e) {
        emit(currentState.copyWith(isLoadingMorePosts: false));
      }
    }
  }

  Future<void> loadMoreAccounts() async {
    final currentState = state;
    if (currentState is ExploreSearchLoaded &&
        !currentState.accountsHasReachedMax &&
        !currentState.isLoadingMoreAccounts) {
      
      emit(currentState.copyWith(isLoadingMoreAccounts: true));
      try {
        final offset = currentState.accounts.length;
        final moreAccounts = await searchProfilesUseCase(
          query: currentState.query,
          limit: _limit,
          offset: offset,
        );

        emit(currentState.copyWith(
          accounts: List.from(currentState.accounts)..addAll(moreAccounts),
          accountsHasReachedMax: moreAccounts.length < _limit,
          isLoadingMoreAccounts: false,
        ));
      } catch (e) {
        emit(currentState.copyWith(isLoadingMoreAccounts: false));
      }
    }
  }

  void toggleLike(String postId, bool isLiked, int likeCount) {
    final currentState = state;
    if (currentState is ExploreSearchLoaded) {
      final updatedPosts = currentState.posts.map((post) {
        if (post.id == postId) {
          return post.copyWith(
            isLikedByCurrentUser: isLiked,
            likeCount: likeCount,
          );
        }
        return post;
      }).toList();
      emit(currentState.copyWith(posts: updatedPosts));
    }
  }

  @override
  Future<void> close() {
    _debounceTimer?.cancel();
    return super.close();
  }
}
