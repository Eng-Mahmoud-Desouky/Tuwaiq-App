import '../entities/user_profile.dart';
import '../repositories/profile_repository.dart';

class GetFollowingUseCase {
  final ProfileRepository repository;

  const GetFollowingUseCase(this.repository);

  Future<List<UserProfile>> call(String userId) {
    return repository.getFollowing(userId);
  }
}
