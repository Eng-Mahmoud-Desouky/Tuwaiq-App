import 'package:equatable/equatable.dart';

abstract class PostFeedState extends Equatable {
  const PostFeedState();

  @override
  List<Object?> get props => [];
}

class PostFeedInitial extends PostFeedState {
  const PostFeedInitial();
}

class PostFeedLoading extends PostFeedState {
  const PostFeedLoading();
}

class PostFeedLoaded extends PostFeedState {
  final List<dynamic> posts;
  final bool hasReachedMax;

  const PostFeedLoaded({
    required this.posts,
    required this.hasReachedMax,
  });

  PostFeedLoaded copyWith({
    List<dynamic>? posts,
    bool? hasReachedMax,
  }) {
    return PostFeedLoaded(
      posts: posts ?? this.posts,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }

  @override
  List<Object?> get props => [posts, hasReachedMax];
}

class PostFeedError extends PostFeedState {
  final String message;

  const PostFeedError({required this.message});

  @override
  List<Object?> get props => [message];
}
