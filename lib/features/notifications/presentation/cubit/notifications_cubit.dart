import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/notification_entity.dart';
import '../../domain/usecases/get_notifications_usecase.dart';
import '../../domain/usecases/mark_notification_as_read_usecase.dart';

part 'notifications_state.dart';

class NotificationsCubit extends Cubit<NotificationsState> {
  final GetNotificationsUseCase getNotificationsUseCase;
  final MarkNotificationAsReadUseCase markNotificationAsReadUseCase;
  final String userId;

  static const int _pageSize = 15;

  NotificationsCubit({
    required this.getNotificationsUseCase,
    required this.markNotificationAsReadUseCase,
    required this.userId,
  }) : super(const NotificationsInitial());

  Future<void> loadNotifications() async {
    emit(const NotificationsLoading());
    try {
      final list = await getNotificationsUseCase(
        userId: userId,
        limit: _pageSize,
        offset: 0,
      );
      emit(NotificationsLoaded(
        notifications: list,
        hasReachedMax: list.length < _pageSize,
      ));
    } catch (e) {
      emit(NotificationsError(e.toString()));
    }
  }

  Future<void> loadMoreNotifications() async {
    final currentState = state;
    if (currentState is! NotificationsLoaded || currentState.hasReachedMax) return;

    try {
      final offset = currentState.notifications.length;
      final list = await getNotificationsUseCase(
        userId: userId,
        limit: _pageSize,
        offset: offset,
      );

      emit(NotificationsLoaded(
        notifications: [...currentState.notifications, ...list],
        hasReachedMax: list.length < _pageSize,
      ));
    } catch (e) {
      // Keep existing list but set error or just ignore to not disrupt UI
    }
  }

  Future<void> markAsRead(String notificationId) async {
    final currentState = state;
    if (currentState is! NotificationsLoaded) return;

    try {
      // Optimistic Update
      final updatedList = currentState.notifications.map((n) {
        if (n.id == notificationId) {
          return n.copyWith(isRead: true);
        }
        return n;
      }).toList();

      emit(NotificationsLoaded(
        notifications: updatedList,
        hasReachedMax: currentState.hasReachedMax,
      ));

      await markNotificationAsReadUseCase(id: notificationId);
    } catch (e) {
      // Revert if error occurs
      loadNotifications();
    }
  }
}
