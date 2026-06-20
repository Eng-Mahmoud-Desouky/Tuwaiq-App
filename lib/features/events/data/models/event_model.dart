import '../../domain/entities/event_entity.dart';
import '../../../profile/data/models/user_profile_model.dart';

class EventModel extends EventEntity {
  const EventModel({
    required super.id,
    required super.creatorId,
    required super.creator,
    required super.title,
    required super.description,
    super.coverUrl,
    required super.category,
    required super.region,
    required super.city,
    required super.locationName,
    super.googleMapsUrl,
    required super.startDate,
    required super.endDate,
    required super.status,
  });

  factory EventModel.fromJson(Map<String, dynamic> json) {
    final creatorData = json['profiles'];
    final creator = creatorData != null
        ? UserProfileModel.fromJson(
            creatorData as Map<String, dynamic>,
          ).toEntity()
        : null;

    return EventModel(
      id: json['id'] as String,
      creatorId: json['creator_id'] as String,
      creator:
          creator ??
          UserProfileModel(
            id: json['creator_id'] as String? ?? '',
            fullName: '',
            username: '',
          ).toEntity(),
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      coverUrl: json['cover_url'] as String?,
      category: json['category'] as String? ?? '',
      region: json['region'] as String? ?? '',
      city: json['city'] as String? ?? '',
      locationName: json['location_name'] as String? ?? '',
      googleMapsUrl: json['google_maps_url'] as String?,
      startDate: json['start_date'] != null
          ? DateTime.parse(json['start_date'] as String)
          : DateTime.now(),
      endDate: json['end_date'] != null
          ? DateTime.parse(json['end_date'] as String)
          : DateTime.now(),
      status: json['status'] as String? ?? 'published',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'cover_url': coverUrl,
      'category': category,
      'region': region,
      'city': city,
      'location_name': locationName,
      'google_maps_url': googleMapsUrl,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'status': status,
      'creator_id': creatorId,
    };
  }

  EventEntity toEntity() {
    return this;
  }
}
