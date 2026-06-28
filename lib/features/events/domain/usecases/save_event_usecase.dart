import '../repositories/event_repository.dart';

class SaveEventUseCase {
  final EventRepository repository;

  SaveEventUseCase(this.repository);

  Future<void> call({required String userId, required String eventId}) {
    return repository.saveEvent(userId: userId, eventId: eventId);
  }
}
