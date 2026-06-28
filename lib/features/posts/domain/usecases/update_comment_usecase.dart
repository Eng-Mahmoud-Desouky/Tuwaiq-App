import '../entities/comment_entity.dart';
import '../repositories/post_repository.dart';

class UpdateCommentUseCase {
  final PostRepository repository;

  UpdateCommentUseCase(this.repository);

  Future<CommentEntity> call({
    required String commentId,
    required String content,
  }) {
    return repository.updateComment(commentId: commentId, content: content);
  }
}
