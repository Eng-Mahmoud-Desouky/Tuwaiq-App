import 'package:equatable/equatable.dart';

abstract class UpdatePasswordState extends Equatable {
  const UpdatePasswordState();

  @override
  List<Object?> get props => [];
}

class UpdatePasswordInitial extends UpdatePasswordState {
  const UpdatePasswordInitial();
}

class UpdatePasswordLoading extends UpdatePasswordState {
  const UpdatePasswordLoading();
}

class UpdatePasswordSuccess extends UpdatePasswordState {
  const UpdatePasswordSuccess();
}

class UpdatePasswordError extends UpdatePasswordState {
  final String message;

  const UpdatePasswordError(this.message);

  @override
  List<Object?> get props => [message];
}
