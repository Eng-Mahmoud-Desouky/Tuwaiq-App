import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../events/domain/entities/event_entity.dart';
import '../../../events/domain/usecases/get_all_events_usecase.dart';
import 'explore_state.dart';

class ExploreCubit extends Cubit<ExploreState> {
  final GetAllEventsUseCase getAllEventsUseCase;

  ExploreCubit({required this.getAllEventsUseCase}) : super(const ExploreInitial());

  Future<void> loadEvents() async {
    emit(const ExploreLoading());
    try {
      final events = await getAllEventsUseCase();
      emit(ExploreLoaded(
        allEvents: events,
        filteredEvents: events,
      ));
    } catch (e) {
      emit(ExploreError('حدث خطأ أثناء تحميل الفعاليات: $e'));
    }
  }

  void searchEvents(String query) {
    final currentState = state;
    if (currentState is ExploreLoaded) {
      final filtered = _applyFilters(
        currentState.allEvents,
        query,
        currentState.selectedCategory,
      );
      emit(currentState.copyWith(
        searchQuery: query,
        filteredEvents: filtered,
      ));
    }
  }

  void selectCategory(String category) {
    final currentState = state;
    if (currentState is ExploreLoaded) {
      final filtered = _applyFilters(
        currentState.allEvents,
        currentState.searchQuery,
        category,
      );
      emit(currentState.copyWith(
        selectedCategory: category,
        filteredEvents: filtered,
      ));
    }
  }

  List<EventEntity> _applyFilters(
    List<EventEntity> events,
    String query,
    String category,
  ) {
    return events.where((event) {
      final matchesCategory = category == 'الكل' || event.category == category;
      
      // Clean normalized comparison for Arabic/English search
      final queryLower = query.trim().toLowerCase();
      final matchesQuery = queryLower.isEmpty ||
          event.title.toLowerCase().contains(queryLower) ||
          event.description.toLowerCase().contains(queryLower) ||
          event.city.toLowerCase().contains(queryLower) ||
          event.region.toLowerCase().contains(queryLower) ||
          event.locationName.toLowerCase().contains(queryLower);
          
      return matchesCategory && matchesQuery;
    }).toList();
  }
}
