// lib/features/notifications/data/models/notification_model.dart
import '../../domain/entities/notification.dart';

class NotificationModel extends NotificationEntity {
  const NotificationModel({
    required super.id,
    required super.title,
    required super.body,
    required super.type,
    required super.priority,
    super.isRead = false,
    super.imageUrl,
    super.actionUrl,
    required super.createdAt,
    required super.ownerId,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id:        json['id']       as String? ?? '',
      title:     json['title']    as String? ?? '',
      body:      json['body']     as String? ?? '',
      type:      json['type']     as String? ?? 'system',
      priority:  json['priority'] as String? ?? 'low',
      isRead:    json['isRead']   as bool?   ?? false,
      imageUrl:  json['imageUrl'] as String?,
      actionUrl: json['actionUrl'] as String?,
      ownerId:   json['ownerId']  as String? ?? '',
      createdAt: _parseDate(json['createdAt']),
    );
  }

  static DateTime _parseDate(dynamic v) {
    if (v == null) return DateTime.now();
    if (v is String) {
      // Handle both ISO strings and Firestore Timestamp maps
      return DateTime.tryParse(v) ?? DateTime.now();
    }
    // Firestore Timestamp object (from Dart SDK) has a toDate() but we
    // receive it as a map when deserialised from JSON: {_seconds, _nanoseconds}
    if (v is Map) {
      final secs = (v['_seconds'] as num?)?.toInt() ?? 0;
      return DateTime.fromMillisecondsSinceEpoch(secs * 1000);
    }
    return DateTime.now();
  }

  Map<String, dynamic> toJson() => {
        'id':        id,
        'title':     title,
        'body':      body,
        'type':      type,
        'priority':  priority,
        'isRead':    isRead,
        'imageUrl':  imageUrl,
        'actionUrl': actionUrl,
        'createdAt': createdAt.toIso8601String(),
        'ownerId':   ownerId,
      };
}
