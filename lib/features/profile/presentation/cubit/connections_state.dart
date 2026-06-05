import 'package:equatable/equatable.dart';
import '../../domain/entities/user_profile.dart';

abstract class ConnectionsState extends Equatable {
  const ConnectionsState();

  @override
  List<Object?> get props => [];
}

class ConnectionsInitial extends ConnectionsState {}

class ConnectionsLoading extends ConnectionsState {}

class ConnectionsLoaded extends ConnectionsState {
  final List<UserProfile> followers;
  final List<UserProfile> following;
  final Set<String> followedUserIds; // Set of user IDs that the current logged-in user follows

  const ConnectionsLoaded({
    required this.followers,
    required this.following,
    required this.followedUserIds,
  });

  ConnectionsLoaded copyWith({
    List<UserProfile>? followers,
    List<UserProfile>? following,
    Set<String>? followedUserIds,
  }) {
    return ConnectionsLoaded(
      followers: followers ?? this.followers,
      following: following ?? this.following,
      followedUserIds: followedUserIds ?? this.followedUserIds,
    );
  }

  @override
  List<Object?> get props => [followers, following, followedUserIds];
}

class ConnectionsError extends ConnectionsState {
  final String message;

  const ConnectionsError(this.message);

  @override
  List<Object?> get props => [message];
}
