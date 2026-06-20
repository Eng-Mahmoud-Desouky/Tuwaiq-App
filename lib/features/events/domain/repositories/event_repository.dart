import '../entities/event_entity.dart';

abstract class EventRepository {
  Future<EventEntity> createEvent({
    required EventEntity event,
    String? localImagePath,
  });

  Future<EventEntity> getEventById(String id);

  Future<List<EventEntity>> getAllEvents();

  Future<String> uploadEventCover({
    required String eventId,
    required String localFilePath,
  });
}
