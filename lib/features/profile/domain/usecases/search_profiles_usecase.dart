import '../entities/user_profile.dart';
import '../repositories/profile_repository.dart';

class SearchProfilesUseCase {
  final ProfileRepository repository;

  SearchProfilesUseCase(this.repository);

  Future<List<UserProfile>> call({
    required String query,
    required int limit,
    required int offset,
  }) {
    return repository.searchProfiles(
      query: query,
      limit: limit,
      offset: offset,
    );
  }
}
