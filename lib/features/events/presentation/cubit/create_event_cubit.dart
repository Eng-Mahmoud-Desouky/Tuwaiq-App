import 'dart:math';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../profile/domain/entities/user_profile.dart';
import '../../domain/entities/event_entity.dart';
import '../../domain/usecases/create_event_usecase.dart';
import 'create_event_state.dart';

class CreateEventCubit extends Cubit<CreateEventState> {
  final CreateEventUseCase createEventUseCase;

  CreateEventCubit({required this.createEventUseCase})
    : super(const CreateEventInitial());

  String _generatedEventId = '';

  // Generate a cryptographically secure random UUID v4
  String _generateUuid() {
    final random = Random.secure();
    final hex = List.generate(256, (i) => i.toRadixString(16).padLeft(2, '0'));
    final bytes = List.generate(16, (_) => random.nextInt(256));

    // Set version to 4
    bytes[6] = (bytes[6] & 0x0f) | 0x40;
    // Set variant to IETF
    bytes[8] = (bytes[8] & 0x3f) | 0x80;

    final buffer = StringBuffer();
    for (var i = 0; i < 16; i++) {
      if (i == 4 || i == 6 || i == 8 || i == 10) {
        buffer.write('-');
      }
      buffer.write(hex[bytes[i]]);
    }
    return buffer.toString();
  }

  void selectImage(String path) {
    emit(
      CreateEventInitial(
        localImagePath: path,
        coverUrl:
            null, // Reset uploaded cover URL since a new image is selected
      ),
    );
  }

  void reset() {
    _generatedEventId = '';
    emit(const CreateEventInitial());
  }

  Future<void> submitEvent({
    required String creatorId,
    required String title,
    required String description,
    required String category,
    required String region,
    required String city,
    required String locationName,
    String? googleMapsUrl,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final currentLocalImagePath = state.localImagePath;
    String? currentCoverUrl = state.coverUrl;

    // Generate event ID if not already generated
    if (_generatedEventId.isEmpty) {
      _generatedEventId = _generateUuid();
    }

    // Step 1: Upload image if we have a local path but no uploaded URL yet
    if (currentCoverUrl == null && currentLocalImagePath != null) {
      emit(
        CreateEventUploadingImage(
          localImagePath: currentLocalImagePath,
          coverUrl: null,
        ),
      );

      try {
        currentCoverUrl = await createEventUseCase.repository.uploadEventCover(
          eventId: _generatedEventId,
          localFilePath: currentLocalImagePath,
        );
      } catch (e) {
        emit(
          CreateEventError(
            message: e
                .toString()
                .replaceAll('Exception: ', '')
                .replaceAll('ServerFailure: ', ''),
            localImagePath: currentLocalImagePath,
            coverUrl: null,
          ),
        );
        return;
      }
    }

    // Step 2: Save event data
    emit(
      CreateEventSavingData(
        localImagePath: currentLocalImagePath,
        coverUrl: currentCoverUrl,
      ),
    );

    try {
      // Build the event entity (stub creator profile, database only needs creatorId field for insert anyway)
      final event = EventEntity(
        id: _generatedEventId,
        creatorId: creatorId,
        creator: UserProfile(id: creatorId, fullName: '', username: ''),
        title: title,
        description: description,
        coverUrl: currentCoverUrl,
        category: category,
        region: region,
        city: city,
        locationName: locationName,
        googleMapsUrl: googleMapsUrl,
        startDate: startDate,
        endDate: endDate,
        status: 'published',
      );

      await createEventUseCase(event: event);
      emit(
        CreateEventSuccess(
          localImagePath: currentLocalImagePath,
          coverUrl: currentCoverUrl,
        ),
      );
    } catch (e) {
      emit(
        CreateEventError(
          message: e
              .toString()
              .replaceAll('Exception: ', '')
              .replaceAll('ServerFailure: ', ''),
          localImagePath: currentLocalImagePath,
          coverUrl:
              currentCoverUrl, // Retain the uploaded cover URL so they don't have to reupload
        ),
      );
    }
  }
}
