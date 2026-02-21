import 'package:equatable/equatable.dart';

class NotificationEntity extends Equatable {
  final String id;
  final String title;
  final String body;
  final NotificationType type;
  final NotificationPriority priority;
  final bool isRead;
  final String? imageUrl;
  final String? actionUrl;
  final DateTime createdAt;
  final String ownerId;

  const NotificationEntity({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.priority,
    this.isRead = false,
    this.imageUrl,
    this.actionUrl,
    required this.createdAt,
    required this.ownerId,
  });

  NotificationEntity copyWith({
    String? id,
    String? title,
    String? body,
    NotificationType? type,
    NotificationPriority? priority,
    bool? isRead,
    String? imageUrl,
    String? actionUrl,
    DateTime? createdAt,
    String? ownerId,
  }) {
    return NotificationEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      type: type ?? this.type,
      priority: priority ?? this.priority,
      isRead: isRead ?? this.isRead,
      imageUrl: imageUrl ?? this.imageUrl,
      actionUrl: actionUrl ?? this.actionUrl,
      createdAt: createdAt ?? this.createdAt,
      ownerId: ownerId ?? this.ownerId,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        body,
        type,
        priority,
        isRead,
        imageUrl,
        actionUrl,
        createdAt,
        ownerId,
      ];
}

// Enums for type safety
enum NotificationType {
  priceAlert('Price Alert'),
  weather('Weather'),
  harvestReminder('Harvest Reminder'),
  marketUpdate('Market Update'),
  system('System'),
  promotional('Promotional');

  const NotificationType(this.label);
  final String label;
}

enum NotificationPriority {
  low('Low'),
  medium('Medium'),
  high('High'),
  urgent('Urgent');

  const NotificationPriority(this.label);
  final String label;
}

extension NotificationTypeExtension on NotificationType {
  static NotificationType fromString(String value) {
    return NotificationType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => NotificationType.system,
    );
  }
}

extension NotificationPriorityExtension on NotificationPriority {
  static NotificationPriority fromString(String value) {
    return NotificationPriority.values.firstWhere(
      (e) => e.name == value,
      orElse: () => NotificationPriority.medium,
    );
  }
}
