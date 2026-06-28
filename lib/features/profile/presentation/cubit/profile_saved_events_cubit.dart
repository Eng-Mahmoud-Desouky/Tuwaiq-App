import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../events/domain/entities/event_entity.dart';
import '../../../events/domain/usecases/get_saved_events_usecase.dart';

abstract class ProfileSavedEventsState extends Equatable {
  const ProfileSavedEventsState();
  @override
  List<Object?> get props => [];
}

class ProfileSavedEventsInitial extends ProfileSavedEventsState {}
class ProfileSavedEventsLoading extends ProfileSavedEventsState {}
class ProfileSavedEventsLoaded extends ProfileSavedEventsState {
  final List<EventEntity> events;
  const ProfileSavedEventsLoaded(this.events);

  @override
  List<Object?> get props => [events];
}
class ProfileSavedEventsError extends ProfileSavedEventsState {
  final String message;
  const ProfileSavedEventsError(this.message);

  @override
  List<Object?> get props => [message];
}

class ProfileSavedEventsCubit extends Cubit<ProfileSavedEventsState> {
  final GetSavedEventsUseCase getSavedEventsUseCase;
  final String userId;

  ProfileSavedEventsCubit({
    required this.getSavedEventsUseCase,
    required this.userId,
  }) : super(ProfileSavedEventsInitial());

  Future<void> loadSavedEvents() async {
    emit(ProfileSavedEventsLoading());
    try {
      final events = await getSavedEventsUseCase(userId);
      emit(ProfileSavedEventsLoaded(events));
    } catch (e) {
      emit(ProfileSavedEventsError(
        e.toString().replaceAll('Exception: ', '').replaceAll('ServerFailure: ', ''),
      ));
    }
  }
}
