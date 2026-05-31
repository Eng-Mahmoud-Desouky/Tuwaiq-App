import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tuwaiq_app/core/errors/failures.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  const AuthRepositoryImpl({required this.remoteDataSource});

  @override
  Future<UserEntity> signUp({
    required String email,
    required String password,
    required String username,
    required String fullName,
  }) async {
    try {
      final userModel = await remoteDataSource.signUp(
        email: email,
        password: password,
        username: username,
        fullName: fullName,
      );
      return userModel.toEntity();
    } on AuthException catch (e) {
      throw AuthFailure(_mapAuthErrorMessage(e.message, e.statusCode));
    } on SocketException {
      throw const NetworkFailure();
    } catch (e) {
      throw ServerFailure('حدث خطأ غير متوقع أثناء إنشاء الحساب: $e');
    }
  }

  @override
  Future<UserEntity> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final userModel = await remoteDataSource.signIn(
        email: email,
        password: password,
      );
      return userModel.toEntity();
    } on AuthException catch (e) {
      throw AuthFailure(_mapAuthErrorMessage(e.message, e.statusCode));
    } on PostgrestException catch (e) {
      throw ServerFailure('فشل استرداد بيانات الملف الشخصي: ${e.message}');
    } on SocketException {
      throw const NetworkFailure();
    } catch (e) {
      throw ServerFailure('حدث خطأ غير متوقع أثناء تسجيل الدخول: $e');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await remoteDataSource.signOut();
    } on AuthException catch (e) {
      throw AuthFailure(_mapAuthErrorMessage(e.message, e.statusCode));
    } on SocketException {
      throw const NetworkFailure();
    } catch (e) {
      throw ServerFailure('حدث خطأ غير متوقع أثناء تسجيل الخروج: $e');
    }
  }

  @override
  Future<void> forgotPassword({required String email}) async {
    try {
      await remoteDataSource.forgotPassword(email: email);
    } on AuthException catch (e) {
      throw AuthFailure(_mapAuthErrorMessage(e.message, e.statusCode));
    } on SocketException {
      throw const NetworkFailure();
    } catch (e) {
      throw ServerFailure('حدث خطأ غير متوقع أثناء إرسال طلب استعادة كلمة المرور: $e');
    }
  }

  @override
  Future<void> updatePassword({required String newPassword}) async {
    try {
      await remoteDataSource.updatePassword(newPassword: newPassword);
    } on AuthException catch (e) {
      throw AuthFailure(_mapAuthErrorMessage(e.message, e.statusCode));
    } on SocketException {
      throw const NetworkFailure();
    } catch (e) {
      throw ServerFailure('حدث خطأ غير متوقع أثناء تحديث كلمة المرور: $e');
    }
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    try {
      final userModel = await remoteDataSource.getCurrentUser();
      return userModel?.toEntity();
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> saveUserInterests({
    required String userId,
    required List<String> interests,
  }) async {
    try {
      await remoteDataSource.saveUserInterests(
        userId: userId,
        interests: interests,
      );
    } on PostgrestException catch (e) {
      throw ServerFailure('فشل حفظ اهتمامات المستخدم: ${e.message}');
    } on SocketException {
      throw const NetworkFailure();
    } catch (e) {
      throw ServerFailure('حدث خطأ غير متوقع أثناء حفظ الاهتمامات: $e');
    }
  }

  String _mapAuthErrorMessage(String message, String? statusCode) {
    final msg = message.toLowerCase();
    if (msg.contains('invalid login credentials') || msg.contains('invalid credentials')) {
      return 'البريد الإلكتروني أو كلمة المرور غير صحيحة';
    }
    if (msg.contains('email already registered') || msg.contains('user already exists') || msg.contains('already has an account')) {
      return 'البريد الإلكتروني مسجل بالفعل. يرجى تسجيل الدخول.';
    }
    if (msg.contains('email not confirmed') || msg.contains('confirm your email') || msg.contains('email_not_confirmed')) {
      return 'البريد الإلكتروني لم يتم تأكيده بعد. يرجى تفعيل حسابك من خلال الرابط المرسل.';
    }
    if (msg.contains('weak password') || msg.contains('should be at least') || msg.contains('password should contain')) {
      return 'كلمة المرور ضعيفة جداً. يجب أن تحتوي على 8 خانات على الأقل.';
    }
    if (msg.contains('network') || msg.contains('connection')) {
      return 'لا يوجد اتصال بالإنترنت. يرجى التحقق من الشبكة.';
    }
    
    // Arabic fallback mapping if Supabase already returns Arabic or other custom cases
    return message;
  }
}
