import '../entities/comment_entity.dart';
import '../repositories/post_repository.dart';

class AddCommentUseCase {
  final PostRepository repository;

  AddCommentUseCase(this.repository);

  Future<CommentEntity> call({
    required String postId,
    required String content,
  }) {
    return repository.addComment(postId: postId, content: content);
  }
}
