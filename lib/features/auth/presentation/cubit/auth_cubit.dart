import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app_links/app_links.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;
import '../../domain/usecases/sign_up_usecase.dart';
import '../../domain/usecases/sign_in_usecase.dart';
import '../../domain/usecases/sign_out_usecase.dart';
import '../../domain/usecases/forgot_password_usecase.dart';
import '../../domain/usecases/update_password_usecase.dart';
import '../../domain/usecases/get_current_user_usecase.dart';
import '../../domain/usecases/save_user_interests_usecase.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final SignUpUseCase signUpUseCase;
  final SignInUseCase signInUseCase;
  final SignOutUseCase signOutUseCase;
  final ForgotPasswordUseCase forgotPasswordUseCase;
  final UpdatePasswordUseCase updatePasswordUseCase;
  final GetCurrentUserUseCase getCurrentUserUseCase;
  final SaveUserInterestsUseCase saveUserInterestsUseCase;

  final AppLinks _appLinks = AppLinks();
  StreamSubscription<Uri>? _linkSubscription;
  StreamSubscription<dynamic>? _authSubscription;

  AuthCubit({
    required this.signUpUseCase,
    required this.signInUseCase,
    required this.signOutUseCase,
    required this.forgotPasswordUseCase,
    required this.updatePasswordUseCase,
    required this.getCurrentUserUseCase,
    required this.saveUserInterestsUseCase,
  }) : super(const AuthInitial()) {
    _initDeepLinks();
    _initAuthListener();
  }

  void _initAuthListener() {
    _authSubscription = Supabase.instance.client.auth.onAuthStateChange.listen(
      (data) {
        if (data.event == AuthChangeEvent.passwordRecovery) {
          emit(const AuthPasswordRecovery());
        }
      },
      onError: (err) {
        emit(AuthError('حدث خطأ في الجلسة: $err'));
      },
    );
  }

  void _initDeepLinks() {
    _linkSubscription = _appLinks.uriLinkStream.listen(
      (uri) {
        handleDeepLink(uri);
      },
      onError: (err) {
        emit(AuthError('فشل معالجة الرابط: $err'));
      },
    );
  }

  Future<void> handleDeepLink(Uri uri) async {
    // Check if the deep link is tuwaiq://auth/callback or cratch://reset-callback
    if ((uri.scheme == 'tuwaiq' && uri.host == 'auth') ||
        (uri.scheme == 'cratch' && uri.host == 'reset-callback')) {
      emit(const AuthLoading());

      // Check if it is a password reset callback or standard confirmation callback
      final fragment = uri.fragment;
      final queryParams = uri.queryParameters;

      // In Supabase, tokens might be passed in query params or fragment
      final isPasswordReset =
          uri.scheme == 'cratch' ||
          fragment.contains('type=recovery') ||
          queryParams['type'] == 'recovery';

      // Refresh current user session
      final user = await getCurrentUserUseCase();

      if (user != null) {
        if (isPasswordReset) {
          // Send user to update password screen
          emit(AuthSuccess(user));
        } else if (user.emailConfirmed) {
          // If confirmed, send to Interests screen
          emit(AuthSuccess(user));
        } else {
          // Should not happen if they used a confirmation link, but just in case
          emit(AuthSuccess(user));
        }
      } else {
        emit(const AuthError('انتهت صلاحية جلسة التحقق. يرجى إعادة المحاولة.'));
      }
    }
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String username,
    required String fullName,
  }) async {
    emit(const AuthLoading());
    try {
      final user = await signUpUseCase(
        email: email,
        password: password,
        username: username,
        fullName: fullName,
      );

      // Bypassing email confirmation for development
      emit(AuthSuccess(user));
    } catch (e) {
      emit(
        AuthError(
          e
              .toString()
              .replaceAll('Failure:', '')
              .replaceAll('AuthFailure:', '')
              .replaceAll('Exception:', '')
              .trim(),
        ),
      );
    }
  }

  Future<void> signIn({required String email, required String password}) async {
    emit(const AuthLoading());
    try {
      final user = await signInUseCase(email: email, password: password);

      // Bypassing email confirmation for development
      emit(AuthSuccess(user));
    } catch (e) {
      emit(
        AuthError(
          e
              .toString()
              .replaceAll('Failure:', '')
              .replaceAll('AuthFailure:', '')
              .replaceAll('Exception:', '')
              .trim(),
        ),
      );
    }
  }

  Future<void> signOut() async {
    emit(const AuthLoading());
    try {
      await signOutUseCase();
      emit(const AuthInitial());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> forgotPassword({required String email}) async {
    emit(const AuthLoading());
    try {
      await forgotPasswordUseCase(email: email);
      // We emit initial or custom state since they show success message on the same screen
      emit(const AuthInitial());
    } catch (e) {
      emit(
        AuthError(
          e
              .toString()
              .replaceAll('Failure:', '')
              .replaceAll('AuthFailure:', '')
              .trim(),
        ),
      );
    }
  }

  Future<void> updatePassword({required String newPassword}) async {
    emit(const AuthLoading());
    try {
      await updatePasswordUseCase(newPassword: newPassword);
      emit(const AuthInitial()); // After update, user will login again
    } catch (e) {
      emit(
        AuthError(
          e
              .toString()
              .replaceAll('Failure:', '')
              .replaceAll('AuthFailure:', '')
              .trim(),
        ),
      );
    }
  }

  Future<void> checkCurrentUser() async {
    try {
      final user = await getCurrentUserUseCase();
      if (user != null) {
        // Bypassing email confirmation for development
        emit(AuthSuccess(user));
      } else {
        emit(const AuthInitial());
      }
    } catch (_) {
      emit(const AuthInitial());
    }
  }

  Future<void> saveUserInterests({required List<String> interests}) async {
    final currentState = state;
    if (currentState is AuthSuccess) {
      emit(const AuthLoading());
      try {
        await saveUserInterestsUseCase(
          userId: currentState.user.id,
          interests: interests,
        );
        final updatedUser = currentState.user.copyWith(interests: interests);
        emit(AuthSuccess(updatedUser));
      } catch (e) {
        emit(
          AuthError(
            e
                .toString()
                .replaceAll('Failure:', '')
                .replaceAll('AuthFailure:', '')
                .trim(),
          ),
        );
        // Re-emit previous success so they don't get locked out of the screen
        emit(currentState);
      }
    } else {
      emit(const AuthError('يجب تسجيل الدخول أولاً لحفظ الاهتمامات.'));
    }
  }

  @override
  Future<void> close() {
    _linkSubscription?.cancel();
    _authSubscription?.cancel();
    return super.close();
  }
}
