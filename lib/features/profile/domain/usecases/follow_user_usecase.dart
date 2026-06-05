import '../repositories/profile_repository.dart';

class FollowUserUseCase {
  final ProfileRepository repository;

  const FollowUserUseCase(this.repository);

  Future<void> call({
    required String followerId,
    required String followedId,
  }) {
    return repository.followUser(
      followerId: followerId,
      followedId: followedId,
    );
  }
}
