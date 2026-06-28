import '../entities/event_entity.dart';
import '../repositories/event_repository.dart';

class GetSavedEventsUseCase {
  final EventRepository repository;

  GetSavedEventsUseCase(this.repository);

  Future<List<EventEntity>> call(String userId) {
    return repository.getSavedEvents(userId);
  }
}
