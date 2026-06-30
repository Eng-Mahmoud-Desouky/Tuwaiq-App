import '../repositories/notifications_repository.dart';

class DeleteFCMTokenUseCase {
  final NotificationsRepository repository;

  DeleteFCMTokenUseCase(this.repository);

  Future<void> call({required String token}) async {
    return await repository.deleteFCMToken(token: token);
  }
}
