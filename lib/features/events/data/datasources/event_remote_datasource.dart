import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/event_model.dart';

abstract class EventRemoteDataSource {
  Future<EventModel> createEvent(EventModel event);

  Future<EventModel> getEventById(String id);

  Future<List<EventModel>> getAllEvents();

  Future<String> uploadEventCover({
    required String eventId,
    required String localFilePath,
  });

  Future<void> saveEvent(String userId, String eventId);

  Future<void> unsaveEvent(String userId, String eventId);

  Future<bool> isEventSaved(String userId, String eventId);

  Future<List<EventModel>> getEventsByUser(String userId);

  Future<List<EventModel>> getSavedEvents(String userId);
}

class EventRemoteDataSourceImpl implements EventRemoteDataSource {
  final SupabaseClient _client;

  EventRemoteDataSourceImpl(this._client);

  @override
  Future<EventModel> createEvent(EventModel event) async {
    final response = await _client
        .from('events')
        .insert(event.toJson())
        .select('*, profiles!creator_id(*)')
        .single();

    return EventModel.fromJson(response);
  }

  @override
  Future<EventModel> getEventById(String id) async {
    final response = await _client
        .from('events')
        .select('*, profiles!creator_id(*)')
        .eq('id', id)
        .single();

    return EventModel.fromJson(response);
  }

  @override
  Future<List<EventModel>> getAllEvents() async {
    final response = await _client
        .from('events')
        .select('*, profiles!creator_id(*)')
        .order('start_date', ascending: true);

    final list = response as List? ?? const [];
    return list
        .map((json) => EventModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<String> uploadEventCover({
    required String eventId,
    required String localFilePath,
  }) async {
    final file = File(localFilePath);
    final fileExt = localFilePath.split('.').last;
    final fileName = 'cover_${DateTime.now().millisecondsSinceEpoch}.$fileExt';
    final path = '$eventId/$fileName';

    // Upload to events storage bucket
    await _client.storage.from('events').upload(path, file);

    // Get and return public URL
    final publicUrl = _client.storage.from('events').getPublicUrl(path);
    return publicUrl;
  }

  @override
  Future<void> saveEvent(String userId, String eventId) async {
    await _client.from('saved_events').insert({
      'user_id': userId,
      'event_id': eventId,
    });
  }

  @override
  Future<void> unsaveEvent(String userId, String eventId) async {
    await _client
        .from('saved_events')
        .delete()
        .eq('user_id', userId)
        .eq('event_id', eventId);
  }

  @override
  Future<bool> isEventSaved(String userId, String eventId) async {
    final response = await _client
        .from('saved_events')
        .select()
        .eq('user_id', userId)
        .eq('event_id', eventId)
        .maybeSingle();
    return response != null;
  }

  @override
  Future<List<EventModel>> getEventsByUser(String userId) async {
    final response = await _client
        .from('events')
        .select('*, profiles!creator_id(*)')
        .eq('creator_id', userId)
        .order('start_date', ascending: true);

    final list = response as List? ?? const [];
    return list
        .map((json) => EventModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<EventModel>> getSavedEvents(String userId) async {
    final response = await _client
        .from('saved_events')
        .select('event:events(*, profiles!creator_id(*))')
        .eq('user_id', userId);

    final list = response as List? ?? const [];
    return list
        .map((item) {
          final eventMap = item['event'] as Map<String, dynamic>?;
          if (eventMap == null) return null;
          return EventModel.fromJson(eventMap);
        })
        .whereType<EventModel>()
        .toList();
  }
}
