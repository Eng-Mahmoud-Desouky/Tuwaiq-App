import '../../domain/entities/notification_entity.dart';
import '../../domain/repositories/notifications_repository.dart';
import '../datasources/notifications_remote_data_source.dart';

class NotificationsRepositoryImpl implements NotificationsRepository {
  final NotificationsRemoteDataSource remoteDataSource;

  NotificationsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<void> saveFCMToken({
    required String userId,
    required String token,
    required String platform,
  }) async {
    try {
      await remoteDataSource.saveFCMToken(
        userId: userId,
        token: token,
        platform: platform,
      );
    } catch (e) {
      throw Exception('فشل حفظ رمز الإشعارات: $e');
    }
  }

  @override
  Future<void> deleteFCMToken({required String token}) async {
    try {
      await remoteDataSource.deleteFCMToken(token: token);
    } catch (e) {
      throw Exception('فشل حذف رمز الإشعارات: $e');
    }
  }

  @override
  Future<List<NotificationEntity>> getNotifications({
    required String userId,
    required int limit,
    required int offset,
  }) async {
    try {
      return await remoteDataSource.getNotifications(
        userId: userId,
        limit: limit,
        offset: offset,
      );
    } catch (e) {
      throw Exception('فشل جلب الإشعارات: $e');
    }
  }

  @override
  Future<void> markAsRead({required String id}) async {
    try {
      await remoteDataSource.markAsRead(id: id);
    } catch (e) {
      throw Exception('فشل تحديث حالة الإشعار: $e');
    }
  }
}
