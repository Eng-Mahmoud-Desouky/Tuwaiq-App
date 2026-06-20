import '../entities/event_entity.dart';
import '../repositories/event_repository.dart';

class GetAllEventsUseCase {
  final EventRepository repository;

  GetAllEventsUseCase(this.repository);

  Future<List<EventEntity>> call() {
    return repository.getAllEvents();
  }
}
