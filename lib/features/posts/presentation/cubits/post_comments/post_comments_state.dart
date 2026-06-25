import 'package:equatable/equatable.dart';
import '../../../domain/entities/comment_entity.dart';

abstract class PostCommentsState extends Equatable {
  const PostCommentsState();

  @override
  List<Object?> get props => [];
}

class PostCommentsInitial extends PostCommentsState {
  const PostCommentsInitial();
}

class PostCommentsLoading extends PostCommentsState {
  const PostCommentsLoading();
}

class PostCommentsLoaded extends PostCommentsState {
  final List<CommentEntity> comments;

  const PostCommentsLoaded({required this.comments});

  @override
  List<Object?> get props => [comments];
}

class PostCommentsError extends PostCommentsState {
  final String message;

  const PostCommentsError({required this.message});

  @override
  List<Object?> get props => [message];
}

class PostCommentSubmitting extends PostCommentsState {
  final List<CommentEntity> comments;

  const PostCommentSubmitting({required this.comments});

  @override
  List<Object?> get props => [comments];
}

class PostCommentSubmitSuccess extends PostCommentsState {
  final CommentEntity comment;
  final List<CommentEntity> comments;

  const PostCommentSubmitSuccess({
    required this.comment,
    required this.comments,
  });

  @override
  List<Object?> get props => [comment, comments];
}
