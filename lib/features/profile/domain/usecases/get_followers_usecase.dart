import '../entities/user_profile.dart';
import '../repositories/profile_repository.dart';

class GetFollowersUseCase {
  final ProfileRepository repository;

  const GetFollowersUseCase(this.repository);

  Future<List<UserProfile>> call(String userId) {
    return repository.getFollowers(userId);
  }
}
