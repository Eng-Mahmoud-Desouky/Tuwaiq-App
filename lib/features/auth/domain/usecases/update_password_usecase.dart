import '../repositories/auth_repository.dart';

class UpdatePasswordUseCase {
  final AuthRepository repository;

  const UpdatePasswordUseCase(this.repository);

  Future<void> call({required String newPassword}) {
    return repository.updatePassword(newPassword: newPassword);
  }
}
