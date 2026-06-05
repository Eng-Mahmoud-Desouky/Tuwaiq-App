import 'package:equatable/equatable.dart';
import '../../domain/entities/profile_social_stats.dart';

abstract class ProfileSocialState extends Equatable {
  const ProfileSocialState();

  @override
  List<Object?> get props => [];
}

class ProfileSocialInitial extends ProfileSocialState {}

class ProfileSocialLoading extends ProfileSocialState {}

class ProfileSocialLoaded extends ProfileSocialState {
  final ProfileSocialStats stats;

  const ProfileSocialLoaded(this.stats);

  @override
  List<Object?> get props => [stats];
}

class ProfileSocialError extends ProfileSocialState {
  final String message;
  final ProfileSocialStats rollbackStats;

  const ProfileSocialError({
    required this.message,
    required this.rollbackStats,
  });

  @override
  List<Object?> get props => [message, rollbackStats];
}
