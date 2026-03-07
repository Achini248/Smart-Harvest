import 'package:equatable/equatable.dart';

abstract class NotificationEvent extends Equatable {
  const NotificationEvent();

  @override
  List<Object?> get props => [];
}

class LoadNotificationsEvent extends NotificationEvent {
  const LoadNotificationsEvent();
}

class RefreshNotificationsEvent extends NotificationEvent {
  const RefreshNotificationsEvent();
}

class MarkAsReadEvent extends NotificationEvent {
  final String notificationId;
  const MarkAsReadEvent({required this.notificationId});

  @override
  List<Object?> get props => [notificationId];
}

class DeleteNotificationEvent extends NotificationEvent {
  final String notificationId;
  const DeleteNotificationEvent({required this.notificationId});

  @override
  List<Object?> get props => [notificationId];
}

class ClearNotificationErrorEvent extends NotificationEvent {
  const ClearNotificationErrorEvent();
}
