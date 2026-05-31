import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class SignUpUseCase {
  final AuthRepository repository;

  const SignUpUseCase(this.repository);

  Future<UserEntity> call({
    required String email,
    required String password,
    required String username,
    required String fullName,
  }) {
    return repository.signUp(
      email: email,
      password: password,
      username: username,
      fullName: fullName,
    );
  }
}
