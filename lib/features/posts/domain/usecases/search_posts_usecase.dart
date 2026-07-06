import '../entities/post_entity.dart';
import '../repositories/post_repository.dart';

class SearchPostsUseCase {
  final PostRepository repository;

  SearchPostsUseCase(this.repository);

  Future<List<PostEntity>> call({
    required String query,
    required int limit,
    DateTime? lastCreatedAt,
    String? lastPostId,
  }) {
    return repository.searchPosts(
      query: query,
      limit: limit,
      lastCreatedAt: lastCreatedAt,
      lastPostId: lastPostId,
    );
  }
}
