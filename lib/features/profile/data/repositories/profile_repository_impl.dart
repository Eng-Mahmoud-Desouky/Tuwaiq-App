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
    String? localCoverPath,
  }) async {
    String? uploadedAvatarUrl;
    String? uploadedCoverUrl;

    try {
      if (localAvatarPath != null) {
        uploadedAvatarUrl = await remoteDataSource.uploadAvatar(
          profile.id,
          localAvatarPath,
        );
      }

      if (localCoverPath != null) {
        uploadedCoverUrl = await remoteDataSource.uploadCover(
          profile.id,
          localCoverPath,
        );
      }

      final model = UserProfileModel(
        id: profile.id,
        fullName: profile.fullName,
        username: profile.username,
        bio: profile.bio,
        avatarUrl: uploadedAvatarUrl ?? profile.avatarUrl,
        coverUrl: uploadedCoverUrl ?? profile.coverUrl,
        interests: profile.interests,
        isVerified: profile.isVerified,
        isAdmin: profile.isAdmin,
      );

      final updatedModel = await remoteDataSource.updateProfile(model);
      return updatedModel.toEntity();
    } catch (e) {
      // Rollback newly uploaded storage files on DB error to prevent storage leaks
      if (uploadedAvatarUrl != null) {
        try {
          await remoteDataSource.deleteAvatarImage(uploadedAvatarUrl);
        } catch (_) {}
      }
      if (uploadedCoverUrl != null) {
        try {
          await remoteDataSource.deleteCoverImage(uploadedCoverUrl);
        } catch (_) {}
      }

      if (e is PostgrestException) {
        throw ServerFailure('فشل تحديث بيانات الملف الشخصي: ${e.message}');
      } else if (e is StorageException) {
        throw ServerFailure('فشل رفع الوسائط: ${e.message}');
      } else if (e is SocketException) {
        throw const NetworkFailure();
      } else {
        throw ServerFailure('حدث خطأ غير متوقع أثناء تحديث الملف الشخصي: $e');
      }
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

  @override
  Future<List<UserProfile>> searchProfiles({
    required String query,
    required int limit,
    required int offset,
  }) async {
    try {
      final list = await remoteDataSource.searchProfiles(
        query: query,
        limit: limit,
        offset: offset,
      );
      return list.map((m) => m.toEntity()).toList();
    } on PostgrestException catch (e) {
      throw ServerFailure('فشل البحث عن الحسابات: ${e.message}');
    } on SocketException {
      throw const NetworkFailure();
    } catch (e) {
      throw ServerFailure('حدث خطأ غير متوقع أثناء البحث عن الحسابات: $e');
    }
  }
}
