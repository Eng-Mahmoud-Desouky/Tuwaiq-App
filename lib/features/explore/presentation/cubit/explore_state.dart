import 'package:equatable/equatable.dart';

abstract class ExploreState extends Equatable {
  const ExploreState();

  @override
  List<Object?> get props => [];
}

class ExploreInitial extends ExploreState {
  const ExploreInitial();
}

class ExploreSearchQueryChanged extends ExploreState {
  final String query;

  const ExploreSearchQueryChanged(this.query);

  @override
  List<Object?> get props => [query];
}
