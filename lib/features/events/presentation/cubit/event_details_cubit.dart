import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/event_entity.dart';
import '../../domain/usecases/get_event_usecase.dart';
import 'event_details_state.dart';

class EventDetailsCubit extends Cubit<EventDetailsState> {
  final GetEventUseCase getEventUseCase;

  EventDetailsCubit({required this.getEventUseCase})
    : super(const EventDetailsLoading());

  Future<void> loadEvent(String id) async {
    emit(const EventDetailsLoading());
    try {
      final event = await getEventUseCase(id);
      emit(EventDetailsLoaded(event));
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

  void setEvent(EventEntity event) {
    emit(EventDetailsLoaded(event));
  }
}
