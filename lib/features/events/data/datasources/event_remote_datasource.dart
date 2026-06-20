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
}

class EventRemoteDataSourceImpl implements EventRemoteDataSource {
  final SupabaseClient _client;

  EventRemoteDataSourceImpl(this._client);

  @override
  Future<EventModel> createEvent(EventModel event) async {
    final response = await _client
        .from('events')
        .insert(event.toJson())
        .select('*, profiles(*)')
        .single();

    return EventModel.fromJson(response);
  }

  @override
  Future<EventModel> getEventById(String id) async {
    final response = await _client
        .from('events')
        .select('*, profiles(*)')
        .eq('id', id)
        .single();

    return EventModel.fromJson(response);
  }

  @override
  Future<List<EventModel>> getAllEvents() async {
    final response = await _client
        .from('events')
        .select('*, profiles(*)')
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
}
