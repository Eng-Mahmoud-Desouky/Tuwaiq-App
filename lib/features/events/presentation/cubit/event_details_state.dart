import 'package:equatable/equatable.dart';
import '../../domain/entities/event_entity.dart';

abstract class EventDetailsState extends Equatable {
  const EventDetailsState();

  @override
  List<Object?> get props => [];
}

class EventDetailsLoading extends EventDetailsState {
  const EventDetailsLoading();
}

class EventDetailsLoaded extends EventDetailsState {
  final EventEntity event;

  const EventDetailsLoaded(this.event);

  @override
  List<Object?> get props => [event];
}

class EventDetailsError extends EventDetailsState {
  final String message;

  const EventDetailsError(this.message);

  @override
  List<Object?> get props => [message];
}
