import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/event_entity.dart';
import '../../domain/repositories/event_repository.dart';
import '../datasources/event_remote_datasource.dart';
import '../models/event_model.dart';

class EventRepositoryImpl implements EventRepository {
  final EventRemoteDataSource remoteDataSource;

  const EventRepositoryImpl({required this.remoteDataSource});

  @override
  Future<EventEntity> createEvent({
    required EventEntity event,
    String? localImagePath,
  }) async {
    try {
      final model = EventModel(
        id: event.id,
        creatorId: event.creatorId,
        creator: event.creator,
        title: event.title,
        description: event.description,
        coverUrl: event.coverUrl,
        category: event.category,
        region: event.region,
        city: event.city,
        locationName: event.locationName,
        googleMapsUrl: event.googleMapsUrl,
        startDate: event.startDate,
        endDate: event.endDate,
        status: event.status,
      );

      final createdModel = await remoteDataSource.createEvent(model);
      return createdModel.toEntity();
    } on PostgrestException catch (e) {
      throw ServerFailure('فشل حفظ الفعالية في قاعدة البيانات: ${e.message}');
    } on SocketException {
      throw const NetworkFailure();
    } catch (e) {
      throw ServerFailure('حدث خطأ غير متوقع أثناء حفظ الفعالية: $e');
    }
  }

  @override
  Future<EventEntity> getEventById(String id) async {
    try {
      final model = await remoteDataSource.getEventById(id);
      return model.toEntity();
    } on PostgrestException catch (e) {
      throw ServerFailure('فشل استرداد تفاصيل الفعالية: ${e.message}');
    } on SocketException {
      throw const NetworkFailure();
    } catch (e) {
      throw ServerFailure('حدث خطأ غير متوقع أثناء استرداد الفعالية: $e');
    }
  }

  @override
  Future<List<EventEntity>> getAllEvents() async {
    try {
      final models = await remoteDataSource.getAllEvents();
      return models.map((m) => m.toEntity()).toList();
    } on PostgrestException catch (e) {
      throw ServerFailure('فشل استرداد قائمة الفعاليات: ${e.message}');
    } on SocketException {
      throw const NetworkFailure();
    } catch (e) {
      throw ServerFailure(
        'حدث خطأ غير متوقع أثناء استرداد قائمة الفعاليات: $e',
      );
    }
  }

  @override
  Future<String> uploadEventCover({
    required String eventId,
    required String localFilePath,
  }) async {
    try {
      return await remoteDataSource.uploadEventCover(
        eventId: eventId,
        localFilePath: localFilePath,
      );
    } on StorageException catch (e) {
      throw ServerFailure('فشل رفع صورة الغلاف: ${e.message}');
    } on SocketException {
      throw const NetworkFailure();
    } catch (e) {
      throw ServerFailure('حدث خطأ غير متوقع أثناء رفع صورة الغلاف: $e');
    }
  }

  @override
  Future<void> saveEvent({required String userId, required String eventId}) async {
    try {
      await remoteDataSource.saveEvent(userId, eventId);
    } on PostgrestException catch (e) {
      throw ServerFailure('فشل حفظ الفعالية: ${e.message}');
    } on SocketException {
      throw const NetworkFailure();
    } catch (e) {
      throw ServerFailure('حدث خطأ غير متوقع أثناء حفظ الفعالية: $e');
    }
  }

  @override
  Future<void> unsaveEvent({required String userId, required String eventId}) async {
    try {
      await remoteDataSource.unsaveEvent(userId, eventId);
    } on PostgrestException catch (e) {
      throw ServerFailure('فشل إلغاء حفظ الفعالية: ${e.message}');
    } on SocketException {
      throw const NetworkFailure();
    } catch (e) {
      throw ServerFailure('حدث خطأ غير متوقع أثناء إلغاء حفظ الفعالية: $e');
    }
  }

  @override
  Future<bool> isEventSaved({required String userId, required String eventId}) async {
    try {
      return await remoteDataSource.isEventSaved(userId, eventId);
    } on PostgrestException catch (e) {
      throw ServerFailure('فشل التحقق من حالة حفظ الفعالية: ${e.message}');
    } on SocketException {
      throw const NetworkFailure();
    } catch (e) {
      throw ServerFailure('حدث خطأ غير متوقع أثناء التحقق من حالة الحفظ: $e');
    }
  }

  @override
  Future<List<EventEntity>> getEventsByUser(String userId) async {
    try {
      final models = await remoteDataSource.getEventsByUser(userId);
      return models.map((m) => m.toEntity()).toList();
    } on PostgrestException catch (e) {
      throw ServerFailure('فشل استرداد فعاليات المستخدم: ${e.message}');
    } on SocketException {
      throw const NetworkFailure();
    } catch (e) {
      throw ServerFailure('حدث خطأ غير متوقع أثناء استرداد فعاليات المستخدم: $e');
    }
  }

  @override
  Future<List<EventEntity>> getSavedEvents(String userId) async {
    try {
      final models = await remoteDataSource.getSavedEvents(userId);
      return models.map((m) => m.toEntity()).toList();
    } on PostgrestException catch (e) {
      throw ServerFailure('فشل استرداد الفعاليات المحفوظة: ${e.message}');
    } on SocketException {
      throw const NetworkFailure();
    } catch (e) {
      throw ServerFailure('حدث خطأ غير متوقع أثناء استرداد الفعاليات المحفوظة: $e');
    }
  }
}
