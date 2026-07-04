import '../entities/post_entity.dart';
import '../repositories/post_repository.dart';

class CreatePostUseCase {
  final PostRepository repository;

  CreatePostUseCase(this.repository);

  Future<PostEntity> call({
    required PostEntity post,
    String? localImagePath,
    String? localVideoPath,
  }) {
    return repository.createPost(
      post: post,
      localImagePath: localImagePath,
      localVideoPath: localVideoPath,
    );
  }
}
