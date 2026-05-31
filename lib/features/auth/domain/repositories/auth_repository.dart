import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<UserEntity> signUp({
    required String email,
    required String password,
    required String username,
    required String fullName,
  });

  Future<UserEntity> signIn({
    required String email,
    required String password,
  });

  Future<void> signOut();

  Future<void> forgotPassword({required String email});

  Future<void> updatePassword({required String newPassword});

  Future<UserEntity?> getCurrentUser();

  Future<void> saveUserInterests({
    required String userId,
    required List<String> interests,
  });
}
