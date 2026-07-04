import '../entities/post_entity.dart';
import '../repositories/post_repository.dart';

class UpdatePostUseCase {
  final PostRepository repository;

  UpdatePostUseCase(this.repository);

  Future<PostEntity> call({
    required String postId,
    required String content,
  }) {
    return repository.updatePost(postId: postId, content: content);
  }
}
