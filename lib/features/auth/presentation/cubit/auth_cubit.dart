import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
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
import '../../../notifications/domain/usecases/save_fcm_token_usecase.dart';
import '../../../notifications/domain/usecases/delete_fcm_token_usecase.dart';
import '../../../../core/services/notification_service.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final SignUpUseCase signUpUseCase;
  final SignInUseCase signInUseCase;
  final SignOutUseCase signOutUseCase;
  final ForgotPasswordUseCase forgotPasswordUseCase;
  final UpdatePasswordUseCase updatePasswordUseCase;
  final GetCurrentUserUseCase getCurrentUserUseCase;
  final SaveUserInterestsUseCase saveUserInterestsUseCase;
  final SaveFCMTokenUseCase saveFCMTokenUseCase;
  final DeleteFCMTokenUseCase deleteFCMTokenUseCase;

  final AppLinks _appLinks = AppLinks();
  StreamSubscription<Uri>? _linkSubscription;
  StreamSubscription<dynamic>? _authSubscription;
  StreamSubscription<String>? _fcmTokenSubscription;

  AuthCubit({
    required this.signUpUseCase,
    required this.signInUseCase,
    required this.signOutUseCase,
    required this.forgotPasswordUseCase,
    required this.updatePasswordUseCase,
    required this.getCurrentUserUseCase,
    required this.saveUserInterestsUseCase,
    required this.saveFCMTokenUseCase,
    required this.deleteFCMTokenUseCase,
  }) : super(const AuthLoading()) {
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
    // Ignore password recovery links as they are handled by the native onAuthStateChange listener
    if (uri.scheme == 'cratch' || uri.host == 'reset-callback') {
      return;
    }

    // Check if the deep link is tuwaiq://auth/callback
    if (uri.scheme == 'tuwaiq' && uri.host == 'auth') {
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
      final user = await getCurrentUserUseCase().timeout(
        const Duration(seconds: 6),
        onTimeout: () => throw TimeoutException('انتهت مهلة التحقق من الجلسة'),
      );
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
  void emit(AuthState state) {
    if (state is AuthSuccess) {
      _syncFCMToken(state.user.id);
    } else if (state is AuthInitial) {
      _unsyncFCMToken();
    }
    super.emit(state);
  }

  void _syncFCMToken(String userId) async {
    if (Platform.environment.containsKey('FLUTTER_TEST')) return;
    _fcmTokenSubscription?.cancel();
    final notificationService = NotificationService();
    final token = await notificationService.getToken();
    if (token != null) {
      try {
        final platform = kIsWeb ? 'web' : (Platform.isAndroid ? 'android' : 'ios');
        await saveFCMTokenUseCase(
          userId: userId,
          token: token,
          platform: platform,
        );
        print("FCM Token synced successfully: $token");
      } catch (e) {
        print("Error syncing FCM Token: $e");
      }
    }

    _fcmTokenSubscription = notificationService.onTokenRefresh.listen((newToken) async {
      try {
        final platform = kIsWeb ? 'web' : (Platform.isAndroid ? 'android' : 'ios');
        await saveFCMTokenUseCase(
          userId: userId,
          token: newToken,
          platform: platform,
        );
        print("FCM Token refreshed and synced: $newToken");
      } catch (e) {
        print("Error syncing refreshed FCM Token: $e");
      }
    });
  }

  void _unsyncFCMToken() async {
    if (Platform.environment.containsKey('FLUTTER_TEST')) return;
    _fcmTokenSubscription?.cancel();
    _fcmTokenSubscription = null;
    final token = await NotificationService().getToken();
    if (token != null) {
      try {
        await deleteFCMTokenUseCase(token: token);
        print("FCM Token deleted from server successfully.");
      } catch (e) {
        print("Error deleting FCM Token from server: $e");
      }
    }
  }

  @override
  Future<void> close() {
    _linkSubscription?.cancel();
    _authSubscription?.cancel();
    _fcmTokenSubscription?.cancel();
    return super.close();
  }
}
