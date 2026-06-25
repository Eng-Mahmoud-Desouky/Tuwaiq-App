import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/comment_entity.dart';
import '../../../domain/usecases/get_comments_usecase.dart';
import '../../../domain/usecases/add_comment_usecase.dart';
import 'post_comments_state.dart';

class PostCommentsCubit extends Cubit<PostCommentsState> {
  final GetCommentsUseCase getCommentsUseCase;
  final AddCommentUseCase addCommentUseCase;

  PostCommentsCubit({
    required this.getCommentsUseCase,
    required this.addCommentUseCase,
  }) : super(const PostCommentsInitial());

  /// Loads all comments on a post.
  Future<void> loadComments(String postId) async {
    emit(const PostCommentsLoading());
    try {
      final comments = await getCommentsUseCase(postId);
      emit(PostCommentsLoaded(comments: comments));
    } catch (e) {
      emit(PostCommentsError(message: 'فشل تحميل التعليقات: ${e.toString()}'));
    }
  }

  /// Adds a new comment to a post.
  Future<void> addComment({
    required String postId,
    required String content,
  }) async {
    final currentState = state;
    List<CommentEntity> currentComments = [];

    if (currentState is PostCommentsLoaded) {
      currentComments = currentState.comments;
    } else if (currentState is PostCommentSubmitting) {
      currentComments = currentState.comments;
    } else if (currentState is PostCommentSubmitSuccess) {
      currentComments = currentState.comments;
    }

    if (content.trim().isEmpty) {
      emit(PostCommentsError(message: 'لا يمكن إضافة تعليق فارغ'));
      return;
    }

    emit(PostCommentSubmitting(comments: currentComments));

    try {
      final newComment = await addCommentUseCase(
        postId: postId,
        content: content.trim(),
      );

      final updatedComments = List<CommentEntity>.from(currentComments)..add(newComment);
      
      emit(PostCommentSubmitSuccess(
        comment: newComment,
        comments: updatedComments,
      ));
    } catch (e) {
      emit(PostCommentsError(message: 'فشل إضافة التعليق: ${e.toString()}'));
      // Restore loaded state after a small delay
      emit(PostCommentsLoaded(comments: currentComments));
    }
  }
}
