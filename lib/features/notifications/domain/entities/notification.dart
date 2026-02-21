import 'package:equatable/equatable.dart';

class NotificationEntity extends Equatable {
  final String id;
  final String title;
  final String body;
  final String type; // 'order', 'price_update', 'weather_alert', 'system'
  final String priority;
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
    String? type,
    String? priority,
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
