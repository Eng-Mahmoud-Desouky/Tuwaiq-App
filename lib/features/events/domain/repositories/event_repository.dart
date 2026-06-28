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

  Future<void> saveEvent({required String userId, required String eventId});
  Future<void> unsaveEvent({required String userId, required String eventId});
  Future<bool> isEventSaved({required String userId, required String eventId});
  Future<List<EventEntity>> getEventsByUser(String userId);
  Future<List<EventEntity>> getSavedEvents(String userId);
}
