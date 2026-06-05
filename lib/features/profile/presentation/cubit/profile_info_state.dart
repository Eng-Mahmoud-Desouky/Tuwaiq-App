import 'package:equatable/equatable.dart';
import '../../domain/entities/user_profile.dart';

abstract class ProfileInfoState extends Equatable {
  const ProfileInfoState();

  @override
  List<Object?> get props => [];
}

class ProfileInfoInitial extends ProfileInfoState {}

class ProfileInfoLoading extends ProfileInfoState {}

class ProfileInfoLoaded extends ProfileInfoState {
  final UserProfile profile;

  const ProfileInfoLoaded(this.profile);

  @override
  List<Object?> get props => [profile];
}

class ProfileInfoUpdating extends ProfileInfoState {
  final UserProfile currentProfile;

  const ProfileInfoUpdating(this.currentProfile);

  @override
  List<Object?> get props => [currentProfile];
}

class ProfileInfoUpdateSuccess extends ProfileInfoState {
  final UserProfile profile;

  const ProfileInfoUpdateSuccess(this.profile);

  @override
  List<Object?> get props => [profile];
}

class ProfileInfoError extends ProfileInfoState {
  final String message;

  const ProfileInfoError(this.message);

  @override
  List<Object?> get props => [message];
}
