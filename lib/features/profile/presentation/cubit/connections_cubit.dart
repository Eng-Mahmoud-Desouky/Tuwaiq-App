import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_followers_usecase.dart';
import '../../domain/usecases/get_following_usecase.dart';
import '../../domain/usecases/follow_user_usecase.dart';
import '../../domain/usecases/unfollow_user_usecase.dart';
import 'connections_state.dart';

class ConnectionsCubit extends Cubit<ConnectionsState> {
  final GetFollowersUseCase getFollowersUseCase;
  final GetFollowingUseCase getFollowingUseCase;
  final FollowUserUseCase followUserUseCase;
  final UnfollowUserUseCase unfollowUserUseCase;

  ConnectionsCubit({
    required this.getFollowersUseCase,
    required this.getFollowingUseCase,
    required this.followUserUseCase,
    required this.unfollowUserUseCase,
  }) : super(ConnectionsInitial());

  Future<void> loadConnections({
    required String targetUserId,
    required String currentUserId,
  }) async {
    emit(ConnectionsLoading());
    try {
      final followers = await getFollowersUseCase(targetUserId);
      final following = await getFollowingUseCase(targetUserId);

      // Fetch who the current user follows to toggle follow buttons correctly
      final currentUserFollowing = currentUserId == targetUserId
          ? following
          : await getFollowingUseCase(currentUserId);

      final followedUserIds = currentUserFollowing.map((u) => u.id).toSet();

      emit(
        ConnectionsLoaded(
          followers: followers,
          following: following,
          followedUserIds: followedUserIds,
        ),
      );
    } catch (e) {
      emit(
        ConnectionsError(
          e
              .toString()
              .replaceAll('Failure:', '')
              .replaceAll('ServerFailure:', '')
              .replaceAll('Exception:', '')
              .trim(),
        ),
      );
    }
  }

  Future<void> toggleFollowUser({
    required String targetUserId,
    required String currentUserId,
  }) async {
    final currentState = state;
    if (currentState is! ConnectionsLoaded) return;

    final wasFollowing = currentState.followedUserIds.contains(targetUserId);
    final updatedFollowedUserIds = Set<String>.from(
      currentState.followedUserIds,
    );

    // Optimistic Update
    if (wasFollowing) {
      updatedFollowedUserIds.remove(targetUserId);
    } else {
      updatedFollowedUserIds.add(targetUserId);
    }

    emit(currentState.copyWith(followedUserIds: updatedFollowedUserIds));

    try {
      if (wasFollowing) {
        await unfollowUserUseCase(
          followerId: currentUserId,
          followedId: targetUserId,
        );
      } else {
        await followUserUseCase(
          followerId: currentUserId,
          followedId: targetUserId,
        );
      }
    } catch (_) {
      // Rollback on failure
      final rollbackFollowedUserIds = Set<String>.from(
        currentState.followedUserIds,
      );
      emit(currentState.copyWith(followedUserIds: rollbackFollowedUserIds));
    }
  }
}
