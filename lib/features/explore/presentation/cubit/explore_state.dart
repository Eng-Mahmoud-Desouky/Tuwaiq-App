import 'package:equatable/equatable.dart';
import '../../../posts/domain/entities/post_entity.dart';
import '../../../profile/domain/entities/user_profile.dart';

abstract class ExploreState extends Equatable {
  const ExploreState();

  @override
  List<Object?> get props => [];
}

class ExploreInitial extends ExploreState {
  const ExploreInitial();
}

class ExploreSearchLoading extends ExploreState {
  const ExploreSearchLoading();
}

class ExploreSearchLoaded extends ExploreState {
  final String query;
  final List<PostEntity> posts;
  final List<UserProfile> accounts;
  final bool postsHasReachedMax;
  final bool accountsHasReachedMax;
  final bool isLoadingMorePosts;
  final bool isLoadingMoreAccounts;

  const ExploreSearchLoaded({
    required this.query,
    required this.posts,
    required this.accounts,
    required this.postsHasReachedMax,
    required this.accountsHasReachedMax,
    this.isLoadingMorePosts = false,
    this.isLoadingMoreAccounts = false,
  });

  ExploreSearchLoaded copyWith({
    String? query,
    List<PostEntity>? posts,
    List<UserProfile>? accounts,
    bool? postsHasReachedMax,
    bool? accountsHasReachedMax,
    bool? isLoadingMorePosts,
    bool? isLoadingMoreAccounts,
  }) {
    return ExploreSearchLoaded(
      query: query ?? this.query,
      posts: posts ?? this.posts,
      accounts: accounts ?? this.accounts,
      postsHasReachedMax: postsHasReachedMax ?? this.postsHasReachedMax,
      accountsHasReachedMax: accountsHasReachedMax ?? this.accountsHasReachedMax,
      isLoadingMorePosts: isLoadingMorePosts ?? this.isLoadingMorePosts,
      isLoadingMoreAccounts: isLoadingMoreAccounts ?? this.isLoadingMoreAccounts,
    );
  }

  @override
  List<Object?> get props => [
        query,
        posts,
        accounts,
        postsHasReachedMax,
        accountsHasReachedMax,
        isLoadingMorePosts,
        isLoadingMoreAccounts,
      ];
}

class ExploreSearchError extends ExploreState {
  final String message;
  const ExploreSearchError(this.message);

  @override
  List<Object?> get props => [message];
}
