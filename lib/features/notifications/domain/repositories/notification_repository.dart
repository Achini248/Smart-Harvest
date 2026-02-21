import '../entities/notification.dart';

/// Abstract repository interface for notification operations
/// Pure domain layer - no external dependencies
abstract class NotificationRepository {
  /// Get all notifications for current user
  Future<List<NotificationEntity>> getNotifications();
  
  /// Mark single notification as read
  Future<void> markAsRead(String id);
  
  /// Mark all notifications as read
  Future<void> markAllAsRead();
  
  /// Get count of unread notifications
  Future<int> getUnreadCount();
  
  /// Real-time stream of notifications (optional)
  Stream<List<NotificationEntity>>? watchNotifications();
}
