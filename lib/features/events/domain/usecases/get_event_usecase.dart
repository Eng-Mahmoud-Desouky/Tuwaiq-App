import '../entities/event_entity.dart';
import '../repositories/event_repository.dart';

class GetEventUseCase {
  final EventRepository repository;

  GetEventUseCase(this.repository);

  Future<EventEntity> call(String id) {
    return repository.getEventById(id);
  }
}
