import '../repositories/post_repository.dart';

class ToggleLikeUseCase {
  final PostRepository repository;

  ToggleLikeUseCase(this.repository);

  Future<void> call({
    required String postId,
    required String userId,
    required bool isCurrentlyLiked,
  }) {
    return repository.toggleLike(
      postId: postId,
      userId: userId,
      isCurrentlyLiked: isCurrentlyLiked,
    );
  }
}
