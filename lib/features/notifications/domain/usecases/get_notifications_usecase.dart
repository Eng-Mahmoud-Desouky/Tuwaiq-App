import '../entities/notification_entity.dart';
import '../repositories/notifications_repository.dart';

class GetNotificationsUseCase {
  final NotificationsRepository repository;

  GetNotificationsUseCase(this.repository);

  Future<List<NotificationEntity>> call({
    required String userId,
    required int limit,
    required int offset,
  }) async {
    return await repository.getNotifications(
      userId: userId,
      limit: limit,
      offset: offset,
    );
  }
}
