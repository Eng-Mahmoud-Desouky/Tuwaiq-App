import '../repositories/notifications_repository.dart';

class SaveFCMTokenUseCase {
  final NotificationsRepository repository;

  SaveFCMTokenUseCase(this.repository);

  Future<void> call({
    required String userId,
    required String token,
    required String platform,
  }) async {
    return await repository.saveFCMToken(
      userId: userId,
      token: token,
      platform: platform,
    );
  }
}
