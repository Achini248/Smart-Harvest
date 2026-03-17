import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_notifications_usecase.dart';
import 'notification_event.dart';
import 'notification_state.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final GetNotificationsUseCase getNotificationsUseCase;

  NotificationBloc({required this.getNotificationsUseCase})
      : super(const NotificationInitialState()) {
    on<LoadNotificationsEvent>(_onLoadNotifications);
    on<RefreshNotificationsEvent>(_onRefreshNotifications);
    on<MarkAsReadEvent>(_onMarkAsRead);
    on<DeleteNotificationEvent>(_onDeleteNotification);
    on<ClearNotificationErrorEvent>(_onClearError);
  }

  Future<void> _onLoadNotifications(
    LoadNotificationsEvent event,
    Emitter<NotificationState> emit,
  ) async {
    emit(const NotificationLoadingState());
    try {
      final notifications = await getNotificationsUseCase();
      if (notifications == null || notifications.isEmpty) {
        emit(const NotificationEmptyState());
      } else {
        emit(NotificationLoadedState(notifications: notifications));
      }
    } catch (e) {
      emit(NotificationErrorState(message: e.toString()));
    }
  }

  Future<void> _onRefreshNotifications(
    RefreshNotificationsEvent event,
    Emitter<NotificationState> emit,
  ) async {
    emit(const NotificationLoadingState());
    try {
      final notifications = await getNotificationsUseCase();
      if (notifications == null || notifications.isEmpty) {
        emit(const NotificationEmptyState());
      } else {
        emit(NotificationLoadedState(notifications: notifications));
      }
    } catch (e) {
      emit(NotificationErrorState(message: e.toString()));
    }
  }

  Future<void> _onMarkAsRead(
    MarkAsReadEvent event,
    Emitter<NotificationState> emit,
  ) async {
    final currentState = state;
    if (currentState is NotificationLoadedState) {
      final updatedNotifications = currentState.notifications.map((n) {
        if (n.id == event.notificationId) {
          return n.copyWith(isRead: true);
        }
        return n;
      }).toList();
      emit(NotificationLoadedState(notifications: updatedNotifications));
    }
  }

  Future<void> _onDeleteNotification(
    DeleteNotificationEvent event,
    Emitter<NotificationState> emit,
  ) async {
    final currentState = state;
    if (currentState is NotificationLoadedState) {
      final updatedNotifications = currentState.notifications
          .where((n) => n.id != event.notificationId)
          .toList();
      if (updatedNotifications.isEmpty) {
        emit(const NotificationEmptyState());
      } else {
        emit(NotificationLoadedState(notifications: updatedNotifications));
      }
    }
  }

  Future<void> _onClearError(
    ClearNotificationErrorEvent event,
    Emitter<NotificationState> emit,
  ) async {
    emit(const NotificationInitialState());
  }
}
