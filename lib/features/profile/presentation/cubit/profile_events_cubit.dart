import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../events/domain/entities/event_entity.dart';
import '../../../events/domain/usecases/get_events_by_user_usecase.dart';

abstract class ProfileEventsState extends Equatable {
  const ProfileEventsState();
  @override
  List<Object?> get props => [];
}

class ProfileEventsInitial extends ProfileEventsState {}
class ProfileEventsLoading extends ProfileEventsState {}
class ProfileEventsLoaded extends ProfileEventsState {
  final List<EventEntity> events;
  const ProfileEventsLoaded(this.events);

  @override
  List<Object?> get props => [events];
}
class ProfileEventsError extends ProfileEventsState {
  final String message;
  const ProfileEventsError(this.message);

  @override
  List<Object?> get props => [message];
}

class ProfileEventsCubit extends Cubit<ProfileEventsState> {
  final GetEventsByUserUseCase getEventsByUserUseCase;
  final String userId;

  ProfileEventsCubit({
    required this.getEventsByUserUseCase,
    required this.userId,
  }) : super(ProfileEventsInitial());

  Future<void> loadEvents() async {
    emit(ProfileEventsLoading());
    try {
      final events = await getEventsByUserUseCase(userId);
      emit(ProfileEventsLoaded(events));
    } catch (e) {
      emit(ProfileEventsError(
        e.toString().replaceAll('Exception: ', '').replaceAll('ServerFailure: ', ''),
      ));
    }
  }
}
