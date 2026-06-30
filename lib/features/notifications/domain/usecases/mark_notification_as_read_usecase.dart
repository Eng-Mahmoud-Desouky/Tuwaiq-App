import '../repositories/notifications_repository.dart';

class MarkNotificationAsReadUseCase {
  final NotificationsRepository repository;

  MarkNotificationAsReadUseCase(this.repository);

  Future<void> call({required String id}) async {
    return await repository.markAsRead(id: id);
  }
}
