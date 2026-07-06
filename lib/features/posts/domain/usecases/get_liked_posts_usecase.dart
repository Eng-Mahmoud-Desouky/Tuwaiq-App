import '../entities/post_entity.dart';
import '../repositories/post_repository.dart';

class GetLikedPostsUseCase {
  final PostRepository repository;

  GetLikedPostsUseCase(this.repository);

  Future<List<PostEntity>> call({
    required String userId,
    required int limit,
    DateTime? lastLikedAt,
    String? lastPostId,
  }) {
    return repository.getLikedPosts(
      userId: userId,
      limit: limit,
      lastLikedAt: lastLikedAt,
      lastPostId: lastPostId,
    );
  }
}
