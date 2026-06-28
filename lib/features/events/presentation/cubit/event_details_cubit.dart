import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/event_entity.dart';
import '../../domain/usecases/get_event_usecase.dart';
import '../../domain/usecases/is_event_saved_usecase.dart';
import '../../domain/usecases/save_event_usecase.dart';
import '../../domain/usecases/unsave_event_usecase.dart';
import 'event_details_state.dart';

class EventDetailsCubit extends Cubit<EventDetailsState> {
  final GetEventUseCase getEventUseCase;
  final IsEventSavedUseCase isEventSavedUseCase;
  final SaveEventUseCase saveEventUseCase;
  final UnsaveEventUseCase unsaveEventUseCase;

  EventDetailsCubit({
    required this.getEventUseCase,
    required this.isEventSavedUseCase,
    required this.saveEventUseCase,
    required this.unsaveEventUseCase,
  }) : super(const EventDetailsLoading());

  Future<void> loadEvent(String id, String currentUserId) async {
    emit(const EventDetailsLoading());
    try {
      final event = await getEventUseCase(id);
      bool isSaved = false;
      if (currentUserId.isNotEmpty) {
        isSaved = await isEventSavedUseCase(userId: currentUserId, eventId: id);
      }
      emit(EventDetailsLoaded(event, isSaved: isSaved));
    } catch (e) {
      emit(
        EventDetailsError(
          e
              .toString()
              .replaceAll('Exception: ', '')
              .replaceAll('ServerFailure: ', ''),
        ),
      );
    }
  }

  void setEvent(EventEntity event, {bool isSaved = false}) {
    emit(EventDetailsLoaded(event, isSaved: isSaved));
  }

  Future<void> toggleSave(String currentUserId) async {
    final currentState = state;
    if (currentState is EventDetailsLoaded && currentUserId.isNotEmpty) {
      final newSaved = !currentState.isSaved;
      emit(EventDetailsLoaded(currentState.event, isSaved: newSaved));

      try {
        if (newSaved) {
          await saveEventUseCase(userId: currentUserId, eventId: currentState.event.id);
        } else {
          await unsaveEventUseCase(userId: currentUserId, eventId: currentState.event.id);
        }
      } catch (e) {
        // Rollback
        emit(EventDetailsLoaded(currentState.event, isSaved: !newSaved));
      }
    }
  }
}
