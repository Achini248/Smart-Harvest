import '../../../../core/errors/failures.dart';
import '../entities/notification.dart';

abstract class NotificationRepository {
  /// Returns List<NotificationEntity> or null if error occurs
  Future<List<NotificationEntity>?> getNotifications();
  
  /// Returns updated notification or null if error
  Future<NotificationEntity?> markAsRead(String id);
  
  /// Returns true if deleted successfully, false otherwise
  Future<bool> deleteNotification(String id);
  
  /// Stream that emits List<NotificationEntity> or null
  Stream<List<NotificationEntity>?> watchNotifications();
}
