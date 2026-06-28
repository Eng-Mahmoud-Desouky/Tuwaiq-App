import '../repositories/event_repository.dart';

class UnsaveEventUseCase {
  final EventRepository repository;

  UnsaveEventUseCase(this.repository);

  Future<void> call({required String userId, required String eventId}) {
    return repository.unsaveEvent(userId: userId, eventId: eventId);
  }
}
