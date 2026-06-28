import '../entities/post_entity.dart';
import '../repositories/post_repository.dart';

class GetPostsFeedUseCase {
  final PostRepository repository;

  GetPostsFeedUseCase(this.repository);

  Future<List<PostEntity>> call({
    required int limit,
    DateTime? lastCreatedAt,
    String? lastPostId,
    String? creatorId,
  }) {
    return repository.getPostsFeed(
      limit: limit,
      lastCreatedAt: lastCreatedAt,
      lastPostId: lastPostId,
      creatorId: creatorId,
    );
  }
}
