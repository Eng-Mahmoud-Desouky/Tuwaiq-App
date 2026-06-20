import '../repositories/auth_repository.dart';

class SaveUserInterestsUseCase {
  final AuthRepository repository;

  const SaveUserInterestsUseCase(this.repository);

  Future<void> call({required String userId, required List<String> interests}) {
    return repository.saveUserInterests(userId: userId, interests: interests);
  }
}
