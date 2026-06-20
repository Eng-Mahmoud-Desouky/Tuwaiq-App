import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/entities/profile_social_stats.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_remote_datasource.dart';
import '../models/user_profile_model.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource remoteDataSource;

  const ProfileRepositoryImpl({required this.remoteDataSource});

  @override
  Future<UserProfile> getProfile(String userId) async {
    try {
      final model = await remoteDataSource.getProfile(userId);
      return model.toEntity();
    } on PostgrestException catch (e) {
      throw ServerFailure('فشل استرداد بيانات الملف الشخصي: ${e.message}');
    } on SocketException {
      throw const NetworkFailure();
    } catch (e) {
      throw ServerFailure('حدث خطأ غير متوقع أثناء استرداد الملف الشخصي: $e');
    }
  }

  @override
  Future<UserProfile> updateProfile({
    required UserProfile profile,
    String? localAvatarPath,
  }) async {
    try {
      String? avatarUrl = profile.avatarUrl;

      if (localAvatarPath != null) {
        avatarUrl = await remoteDataSource.uploadAvatar(
          profile.id,
          localAvatarPath,
        );
      }

      final model = UserProfileModel(
        id: profile.id,
        fullName: profile.fullName,
        username: profile.username,
        bio: profile.bio,
        avatarUrl: avatarUrl,
        interests: profile.interests,
      );

      final updatedModel = await remoteDataSource.updateProfile(model);
      return updatedModel.toEntity();
    } on PostgrestException catch (e) {
      throw ServerFailure('فشل تحديث بيانات الملف الشخصي: ${e.message}');
    } on StorageException catch (e) {
      throw ServerFailure('فشل رفع الصورة الشخصية: ${e.message}');
    } on SocketException {
      throw const NetworkFailure();
    } catch (e) {
      throw ServerFailure('حدث خطأ غير متوقع أثناء تحديث الملف الشخصي: $e');
    }
  }

  @override
  Future<ProfileSocialStats> getProfileSocialStats({
    required String targetUserId,
    required String currentUserId,
  }) async {
    try {
      final model = await remoteDataSource.getProfileSocialStats(
        targetUserId: targetUserId,
        currentUserId: currentUserId,
      );
      return model.toEntity();
    } on PostgrestException catch (e) {
      throw ServerFailure('فشل استرداد الإحصاءات الاجتماعية: ${e.message}');
    } on SocketException {
      throw const NetworkFailure();
    } catch (e) {
      throw ServerFailure('حدث خطأ غير متوقع أثناء استرداد الإحصاءات: $e');
    }
  }

  @override
  Future<void> followUser({
    required String followerId,
    required String followedId,
  }) async {
    try {
      await remoteDataSource.followUser(
        followerId: followerId,
        followedId: followedId,
      );
    } on PostgrestException catch (e) {
      throw ServerFailure('فشل متابعة المستخدم: ${e.message}');
    } on SocketException {
      throw const NetworkFailure();
    } catch (e) {
      throw ServerFailure('حدث خطأ غير متوقع أثناء المتابعة: $e');
    }
  }

  @override
  Future<void> unfollowUser({
    required String followerId,
    required String followedId,
  }) async {
    try {
      await remoteDataSource.unfollowUser(
        followerId: followerId,
        followedId: followedId,
      );
    } on PostgrestException catch (e) {
      throw ServerFailure('فشل إلغاء متابعة المستخدم: ${e.message}');
    } on SocketException {
      throw const NetworkFailure();
    } catch (e) {
      throw ServerFailure('حدث خطأ غير متوقع أثناء إلغاء المتابعة: $e');
    }
  }

  @override
  Future<List<UserProfile>> getFollowers(String userId) async {
    try {
      final list = await remoteDataSource.getFollowers(userId);
      return list.map((m) => m.toEntity()).toList();
    } on PostgrestException catch (e) {
      throw ServerFailure('فشل استرداد قائمة المتابعين: ${e.message}');
    } on SocketException {
      throw const NetworkFailure();
    } catch (e) {
      throw ServerFailure('حدث خطأ غير متوقع أثناء استرداد المتابعين: $e');
    }
  }

  @override
  Future<List<UserProfile>> getFollowing(String userId) async {
    try {
      final list = await remoteDataSource.getFollowing(userId);
      return list.map((m) => m.toEntity()).toList();
    } on PostgrestException catch (e) {
      throw ServerFailure('فشل استرداد قائمة المتابَعين: ${e.message}');
    } on SocketException {
      throw const NetworkFailure();
    } catch (e) {
      throw ServerFailure('حدث خطأ غير متوقع أثناء استرداد المتابَعين: $e');
    }
  }
}
