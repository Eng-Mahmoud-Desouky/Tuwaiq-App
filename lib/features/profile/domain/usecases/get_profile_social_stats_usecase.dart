import '../entities/profile_social_stats.dart';
import '../repositories/profile_repository.dart';

class GetProfileSocialStatsUseCase {
  final ProfileRepository repository;

  const GetProfileSocialStatsUseCase(this.repository);

  Future<ProfileSocialStats> call({
    required String targetUserId,
    required String currentUserId,
  }) {
    return repository.getProfileSocialStats(
      targetUserId: targetUserId,
      currentUserId: currentUserId,
    );
  }
}
