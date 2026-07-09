import '../entities/post_entity.dart';
import '../repositories/post_repository.dart';

class GetPostUseCase {
  final PostRepository repository;

  GetPostUseCase(this.repository);

  Future<PostEntity> call(String postId) {
    return repository.getPostById(postId);
  }
}
