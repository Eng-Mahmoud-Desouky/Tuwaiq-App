import '../entities/user_profile.dart';
import '../repositories/profile_repository.dart';

class UpdateProfileUseCase {
  final ProfileRepository repository;

  const UpdateProfileUseCase(this.repository);

  Future<UserProfile> call({
    required UserProfile profile,
    String? localAvatarPath,
    String? localCoverPath,
  }) {
    return repository.updateProfile(
      profile: profile,
      localAvatarPath: localAvatarPath,
      localCoverPath: localCoverPath,
    );
  }
}
