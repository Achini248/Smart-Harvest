import 'package:equatable/equatable.dart';
import '../../domain/entities/notification.dart';

abstract class NotificationState extends Equatable {
  const NotificationState();

  @override
  List<Object?> get props => [];
}

class NotificationInitialState extends NotificationState {
  const NotificationInitialState();
}

class NotificationLoadingState extends NotificationState {
  const NotificationLoadingState();
}

class NotificationLoadedState extends NotificationState {
  final List<NotificationEntity> notifications;
  const NotificationLoadedState({required this.notifications});

  @override
  List<Object?> get props => [notifications];
}

class NotificationOperationLoadingState extends NotificationState {
  final List<NotificationEntity> notifications;
  const NotificationOperationLoadingState({required this.notifications});

  @override
  List<Object?> get props => [notifications];
}

class NotificationEmptyState extends NotificationState {
  const NotificationEmptyState();
}

class NotificationErrorState extends NotificationState {
  final String message;
  final List<NotificationEntity> previousNotifications;
  const NotificationErrorState({
    required this.message,
    this.previousNotifications = const [],
  });

  @override
  List<Object?> get props => [message, previousNotifications];
}
