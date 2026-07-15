import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> signUp({
    required String email,
    required String password,
    required String username,
    required String fullName,
  });

  Future<UserModel> signIn({required String email, required String password});

  Future<void> signOut();

  Future<void> forgotPassword({required String email});

  Future<void> updatePassword({required String newPassword});

  Future<UserModel?> getCurrentUser();

  Future<void> saveUserInterests({
    required String userId,
    required List<String> interests,
  });

  Future<void> deleteAccount();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final SupabaseClient _client;

  AuthRemoteDataSourceImpl(this._client);

  @override
  Future<UserModel> signUp({
    required String email,
    required String password,
    required String username,
    required String fullName,
  }) async {
    // 1. Authenticate with Supabase Auth
    final response = await _client.auth.signUp(
      email: email,
      password: password,
      data: {'username': username, 'full_name': fullName},
    );

    final user = response.user;
    if (user == null) {
      throw const AuthException('فشل إنشاء الحساب. يرجى المحاولة مرة أخرى.');
    }

    // Note: Due to the Postgres DB trigger handle_new_user(),
    // a row in public.profiles was automatically created upon signUp.
    // However, if email confirmation is enabled, we cannot fetch it authenticated yet,
    // so we construct a temporary UserModel.
    return UserModel(
      id: user.id,
      email: email,
      username: username,
      fullName: fullName,
      emailConfirmed: user.emailConfirmedAt != null,
    );
  }

  @override
  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    final response = await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );

    final user = response.user;
    if (user == null) {
      throw const AuthException('فشل تسجيل الدخول. يرجى المحاولة مرة أخرى.');
    }

    // Check email confirmation status
    final isConfirmed = user.emailConfirmedAt != null;

    // Fetch user profile from public.profiles
    final profileData = await _client
        .from('profiles')
        .select()
        .eq('id', user.id)
        .single();

    return UserModel.fromJson(
      profileData,
      email: user.email ?? email,
      emailConfirmed: isConfirmed,
    );
  }

  @override
  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  @override
  Future<void> forgotPassword({required String email}) async {
    await _client.auth.resetPasswordForEmail(
      email,
      redirectTo: 'cratch://reset-callback',
    );
  }

  @override
  Future<void> updatePassword({required String newPassword}) async {
    await _client.auth.updateUser(UserAttributes(password: newPassword));
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    final session = _client.auth.currentSession;
    if (session == null) {
      return null;
    }

    final user = session.user;
    final isConfirmed = user.emailConfirmedAt != null;

    try {
      final profileData = await _client
          .from('profiles')
          .select()
          .eq('id', user.id)
          .single();

      return UserModel.fromJson(
        profileData,
        email: user.email ?? '',
        emailConfirmed: isConfirmed,
      );
    } catch (_) {
      // Return bare model if profile does not exist yet (e.g. trigger failed or didn't run)
      return UserModel(
        id: user.id,
        email: user.email ?? '',
        username: '',
        fullName: '',
        emailConfirmed: isConfirmed,
      );
    }
  }

  @override
  Future<void> saveUserInterests({
    required String userId,
    required List<String> interests,
  }) async {
    await _client
        .from('profiles')
        .update({
          'interests': interests,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', userId);
  }

  @override
  Future<void> deleteAccount() async {
    await _client.rpc('delete_user_account');
  }
}
