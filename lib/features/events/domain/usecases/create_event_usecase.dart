import '../entities/event_entity.dart';
import '../repositories/event_repository.dart';

class CreateEventUseCase {
  final EventRepository repository;

  CreateEventUseCase(this.repository);

  Future<EventEntity> call({
    required EventEntity event,
    String? localImagePath,
  }) {
    return repository.createEvent(event: event, localImagePath: localImagePath);
  }
}
