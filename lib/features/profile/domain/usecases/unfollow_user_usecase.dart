import '../repositories/profile_repository.dart';

class UnfollowUserUseCase {
  final ProfileRepository repository;

  const UnfollowUserUseCase(this.repository);

  Future<void> call({
    required String followerId,
    required String followedId,
  }) {
    return repository.unfollowUser(
      followerId: followerId,
      followedId: followedId,
    );
  }
}
