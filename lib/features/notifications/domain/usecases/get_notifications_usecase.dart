import '../../../../core/errors/failures.dart';
import '../entities/notification.dart';
import '../repositories/notification_repository.dart';

class GetNotificationsUseCase {
  final NotificationRepository repository;
  const GetNotificationsUseCase(this.repository);

  Future<List<NotificationEntity>?> call() async {
    try {
      final result = await repository.getNotifications();
      return result;
    } catch (e) {
      // Handle error locally without Either
      return null;
    }
  }
}
