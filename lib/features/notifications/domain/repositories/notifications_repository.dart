import '../entities/notification_entity.dart';

abstract class NotificationsRepository {
  Future<void> saveFCMToken({
    required String userId,
    required String token,
    required String platform,
  });

  Future<void> deleteFCMToken({required String token});

  Future<List<NotificationEntity>> getNotifications({
    required String userId,
    required int limit,
    required int offset,
  });

  Future<void> markAsRead({required String id});
}
