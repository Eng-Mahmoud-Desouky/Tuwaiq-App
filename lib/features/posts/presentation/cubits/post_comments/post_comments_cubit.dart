import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/comment_entity.dart';
import '../../../domain/usecases/get_comments_usecase.dart';
import '../../../domain/usecases/add_comment_usecase.dart';
import '../../../domain/usecases/delete_comment_usecase.dart';
import '../../../domain/usecases/update_comment_usecase.dart';
import 'post_comments_state.dart';

class PostCommentsCubit extends Cubit<PostCommentsState> {
  final GetCommentsUseCase getCommentsUseCase;
  final AddCommentUseCase addCommentUseCase;
  final DeleteCommentUseCase deleteCommentUseCase;
  final UpdateCommentUseCase updateCommentUseCase;

  PostCommentsCubit({
    required this.getCommentsUseCase,
    required this.addCommentUseCase,
    required this.deleteCommentUseCase,
    required this.updateCommentUseCase,
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

  /// Deletes a comment.
  Future<void> deleteComment(String commentId) async {
    final currentState = state;
    if (currentState is! PostCommentsLoaded) return;

    final currentComments = currentState.comments;
    // Optimistically update UI
    final updatedComments = currentComments.where((c) => c.id != commentId).toList();
    emit(PostCommentsLoaded(comments: updatedComments));

    try {
      await deleteCommentUseCase(commentId);
    } catch (e) {
      // Revert if error occurs
      emit(PostCommentsError(message: 'فشل حذف التعليق: ${e.toString()}'));
      emit(PostCommentsLoaded(comments: currentComments));
    }
  }

  /// Updates a comment.
  Future<void> updateComment({
    required String commentId,
    required String content,
  }) async {
    final currentState = state;
    if (currentState is! PostCommentsLoaded) return;

    if (content.trim().isEmpty) {
      emit(const PostCommentsError(message: 'لا يمكن تعديل التعليق إلى نص فارغ'));
      return;
    }

    final currentComments = currentState.comments;

    try {
      final updatedComment = await updateCommentUseCase(
        commentId: commentId,
        content: content.trim(),
      );

      final updatedComments = currentComments.map((c) {
        return c.id == commentId ? updatedComment : c;
      }).toList();

      emit(PostCommentsLoaded(comments: updatedComments));
    } catch (e) {
      emit(PostCommentsError(message: 'فشل تعديل التعليق: ${e.toString()}'));
      emit(PostCommentsLoaded(comments: currentComments));
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
