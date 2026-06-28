import '../repositories/event_repository.dart';

class IsEventSavedUseCase {
  final EventRepository repository;

  IsEventSavedUseCase(this.repository);

  Future<bool> call({required String userId, required String eventId}) {
    return repository.isEventSaved(userId: userId, eventId: eventId);
  }
}
