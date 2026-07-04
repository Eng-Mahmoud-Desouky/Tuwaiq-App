import 'package:flutter_bloc/flutter_bloc.dart';
import 'explore_state.dart';

class ExploreCubit extends Cubit<ExploreState> {
  ExploreCubit() : super(const ExploreInitial());

  void search(String query) {
    emit(ExploreSearchQueryChanged(query));
  }
}
