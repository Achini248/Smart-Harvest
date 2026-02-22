import 'dart:async';
import '../models/notification_model.dart';

abstract class NotificationRemoteDataSource {
  Future<List<NotificationModel>> getNotifications();
  Future<NotificationModel> markAsRead(String id);
  Future<void> deleteNotification(String id);
  Stream<List<NotificationModel>> watchNotifications();
}

class NotificationRemoteDataSourceImpl implements NotificationRemoteDataSource {
  // In-memory storage for demo purposes
  final List<NotificationModel> _notifications = [];
  final StreamController<List<NotificationModel>> _notificationsController =
      StreamController<List<NotificationModel>>.broadcast();

  NotificationRemoteDataSourceImpl() {
    _initSampleData();
  }

  void _initSampleData() {
    _notifications.addAll([
      NotificationModel(
        id: '1',
        title: 'Price Update',
        body: 'Tomato prices increased by 15%',
        type: 'price_update',
        priority: 'high',
        isRead: false,
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        ownerId: 'user_1',
      ),
      NotificationModel(
        id: '2',
        title: 'Weather Alert',
        body: 'Heavy rain expected tomorrow',
        type: 'weather_alert',
        priority: 'medium',
        isRead: false,
        createdAt: DateTime.now().subtract(const Duration(hours: 5)),
        ownerId: 'user_1',
      ),
      NotificationModel(
        id: '3',
        title: 'New Order',
        body: 'You have a new order for 50kg of potatoes',
        type: 'order',
        priority: 'high',
        isRead: true,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        ownerId: 'user_1',
      ),
    ]);
    _notificationsController.add(_notifications);
  }

  @override
  Future<List<NotificationModel>> getNotifications() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return List.from(_notifications);
  }

  @override
  Future<NotificationModel> markAsRead(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1) {
      final updated = NotificationModel(
        id: _notifications[index].id,
        title: _notifications[index].title,
        body: _notifications[index].body,
        type: _notifications[index].type,
        priority: _notifications[index].priority,
        isRead: true,
        imageUrl: _notifications[index].imageUrl,
        actionUrl: _notifications[index].actionUrl,
        createdAt: _notifications[index].createdAt,
        ownerId: _notifications[index].ownerId,
      );
      _notifications[index] = updated;
      _notificationsController.add(_notifications);
      return updated;
    }
    throw Exception('Notification not found');
  }

  @override
  Future<void> deleteNotification(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _notifications.removeWhere((n) => n.id == id);
    _notificationsController.add(_notifications);
  }

  @override
  Stream<List<NotificationModel>> watchNotifications() {
    return _notificationsController.stream;
  }
}
