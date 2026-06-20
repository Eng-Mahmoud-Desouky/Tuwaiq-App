import 'package:equatable/equatable.dart';
import '../../../profile/domain/entities/user_profile.dart';

class EventEntity extends Equatable {
  final String id;
  final String creatorId;
  final UserProfile creator;
  final String title;
  final String description;
  final String? coverUrl;
  final String category;
  final String region;
  final String city;
  final String locationName;
  final String? googleMapsUrl;
  final DateTime startDate;
  final DateTime endDate;
  final String status;

  const EventEntity({
    required this.id,
    required this.creatorId,
    required this.creator,
    required this.title,
    required this.description,
    this.coverUrl,
    required this.category,
    required this.region,
    required this.city,
    required this.locationName,
    this.googleMapsUrl,
    required this.startDate,
    required this.endDate,
    required this.status,
  });

  EventEntity copyWith({
    String? id,
    String? creatorId,
    UserProfile? creator,
    String? title,
    String? description,
    String? coverUrl,
    String? category,
    String? region,
    String? city,
    String? locationName,
    String? googleMapsUrl,
    DateTime? startDate,
    DateTime? endDate,
    String? status,
  }) {
    return EventEntity(
      id: id ?? this.id,
      creatorId: creatorId ?? this.creatorId,
      creator: creator ?? this.creator,
      title: title ?? this.title,
      description: description ?? this.description,
      coverUrl: coverUrl ?? this.coverUrl,
      category: category ?? this.category,
      region: region ?? this.region,
      city: city ?? this.city,
      locationName: locationName ?? this.locationName,
      googleMapsUrl: googleMapsUrl ?? this.googleMapsUrl,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      status: status ?? this.status,
    );
  }

  @override
  List<Object?> get props => [
    id,
    creatorId,
    creator,
    title,
    description,
    coverUrl,
    category,
    region,
    city,
    locationName,
    googleMapsUrl,
    startDate,
    endDate,
    status,
  ];
}
