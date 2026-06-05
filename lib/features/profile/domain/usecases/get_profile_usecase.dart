import '../entities/user_profile.dart';
import '../repositories/profile_repository.dart';

class GetProfileUseCase {
  final ProfileRepository repository;

  const GetProfileUseCase(this.repository);

  Future<UserProfile> call(String userId) {
    return repository.getProfile(userId);
  }
}
