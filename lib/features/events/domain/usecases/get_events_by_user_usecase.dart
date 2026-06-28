import '../entities/event_entity.dart';
import '../repositories/event_repository.dart';

class GetEventsByUserUseCase {
  final EventRepository repository;

  GetEventsByUserUseCase(this.repository);

  Future<List<EventEntity>> call(String userId) {
    return repository.getEventsByUser(userId);
  }
}
