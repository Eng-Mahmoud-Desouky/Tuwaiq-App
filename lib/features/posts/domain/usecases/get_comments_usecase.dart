import '../entities/comment_entity.dart';
import '../repositories/post_repository.dart';

class GetCommentsUseCase {
  final PostRepository repository;

  GetCommentsUseCase(this.repository);

  Future<List<CommentEntity>> call(String postId) {
    return repository.getComments(postId);
  }
}
