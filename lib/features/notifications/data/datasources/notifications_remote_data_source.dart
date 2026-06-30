import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/notification_model.dart';

abstract class NotificationsRemoteDataSource {
  Future<void> saveFCMToken({
    required String userId,
    required String token,
    required String platform,
  });

  Future<void> deleteFCMToken({required String token});

  Future<List<NotificationModel>> getNotifications({
    required String userId,
    required int limit,
    required int offset,
  });

  Future<void> markAsRead({required String id});
}

class NotificationsRemoteDataSourceImpl implements NotificationsRemoteDataSource {
  final SupabaseClient _client;

  NotificationsRemoteDataSourceImpl(this._client);

  @override
  Future<void> saveFCMToken({
    required String userId,
    required String token,
    required String platform,
  }) async {
    await _client.from('user_tokens').upsert({
      'user_id': userId,
      'fcm_token': token,
      'device_platform': platform,
      'updated_at': DateTime.now().toIso8601String(),
    });
  }

  @override
  Future<void> deleteFCMToken({required String token}) async {
    await _client.from('user_tokens').delete().eq('fcm_token', token);
  }

  @override
  Future<List<NotificationModel>> getNotifications({
    required String userId,
    required int limit,
    required int offset,
  }) async {
    final response = await _client
        .from('notifications')
        .select('*')
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .range(offset, offset + limit - 1);

    final list = response as List? ?? const [];
    return list
        .map((json) => NotificationModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> markAsRead({required String id}) async {
    await _client.from('notifications').update({'is_read': true}).eq('id', id);
  }
}
