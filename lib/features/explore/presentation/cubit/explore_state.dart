import 'package:equatable/equatable.dart';
import '../../../events/domain/entities/event_entity.dart';

abstract class ExploreState extends Equatable {
  const ExploreState();

  @override
  List<Object?> get props => [];
}

class ExploreInitial extends ExploreState {
  const ExploreInitial();
}

class ExploreLoading extends ExploreState {
  const ExploreLoading();
}

class ExploreLoaded extends ExploreState {
  final List<EventEntity> allEvents;
  final List<EventEntity> filteredEvents;
  final String searchQuery;
  final String selectedCategory;

  const ExploreLoaded({
    required this.allEvents,
    required this.filteredEvents,
    this.searchQuery = '',
    this.selectedCategory = 'الكل',
  });

  ExploreLoaded copyWith({
    List<EventEntity>? allEvents,
    List<EventEntity>? filteredEvents,
    String? searchQuery,
    String? selectedCategory,
  }) {
    return ExploreLoaded(
      allEvents: allEvents ?? this.allEvents,
      filteredEvents: filteredEvents ?? this.filteredEvents,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedCategory: selectedCategory ?? this.selectedCategory,
    );
  }

  @override
  List<Object?> get props => [allEvents, filteredEvents, searchQuery, selectedCategory];
}

class ExploreError extends ExploreState {
  final String message;

  const ExploreError(this.message);

  @override
  List<Object?> get props => [message];
}
