import '../../domain/entities/notification.dart';
import '../../domain/repositories/notification_repository.dart';
import '../datasources/notification_remote_datasource.dart';
import '../models/notification_model.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationRemoteDataSource remoteDataSource;

  const NotificationRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<NotificationEntity>?> getNotifications() async {
    try {
      final notifications = await remoteDataSource.getNotifications();
      return notifications;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<NotificationEntity?> markAsRead(String id) async {
    try {
      final notification = await remoteDataSource.markAsRead(id);
      return notification;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<bool> deleteNotification(String id) async {
    try {
      await remoteDataSource.deleteNotification(id);
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Stream<List<NotificationEntity>?> watchNotifications() {
    return remoteDataSource.watchNotifications().map<List<NotificationEntity>?>(
      (notifications) => notifications,
    ).handleError(
      (error) => null,
    );
  }
}
