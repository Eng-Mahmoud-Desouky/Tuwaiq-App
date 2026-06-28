import '../repositories/post_repository.dart';

class DeleteCommentUseCase {
  final PostRepository repository;

  DeleteCommentUseCase(this.repository);

  Future<void> call(String commentId) {
    return repository.deleteComment(commentId);
  }
}
