import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/message.dart';

class MessageModel extends MessageEntity {
  const MessageModel({
    required super.id,
    required super.conversationId,
    required super.senderId,
    required super.senderName,
    required super.receiverId,
    required super.receiverName,
    required super.content,
    required super.isRead,
    required super.createdAt,
  });

  factory MessageModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return MessageModel(
      id: doc.id,
      conversationId: d['conversationId'] ?? '',
      senderId: d['senderId'] ?? '',
      senderName: d['senderName'] ?? '',
      receiverId: d['receiverId'] ?? '',
      receiverName: d['receiverName'] ?? '',
      content: d['content'] ?? '',
      isRead: d['isRead'] ?? false,
      createdAt: _ts(d['createdAt']),
    );
  }

  factory MessageModel.fromEntity(MessageEntity e) => MessageModel(
        id: e.id,
        conversationId: e.conversationId,
        senderId: e.senderId,
        senderName: e.senderName,
        receiverId: e.receiverId,
        receiverName: e.receiverName,
        content: e.content,
        isRead: e.isRead,
        createdAt: e.createdAt,
      );

  Map<String, dynamic> toFirestore() => {
        'conversationId': conversationId,
        'senderId': senderId,
        'senderName': senderName,
        'receiverId': receiverId,
        'receiverName': receiverName,
        'content': content,
        'isRead': isRead,
        'createdAt': Timestamp.fromDate(createdAt),
      };

  static DateTime _ts(dynamic v) {
    if (v is Timestamp) return v.toDate();
    if (v is DateTime) return v;
    return DateTime.now();
  }
}

class ConversationModel extends ConversationEntity {
  const ConversationModel({
    required super.conversationId,
    required super.otherUserId,
    required super.otherUserName,
    super.otherUserAvatar,
    required super.lastMessage,
    super.isOnline,
    required super.lastMessageAt,
    super.unreadCount,
  });

  factory ConversationModel.fromFirestore(
      DocumentSnapshot doc, String currentUserId) {
    final d = doc.data() as Map<String, dynamic>;
    final participants =
        List<String>.from(d['participants'] ?? []);
    final otherUid = participants
        .firstWhere((p) => p != currentUserId, orElse: () => '');
    final names =
        Map<String, dynamic>.from(d['participantNames'] ?? {});
    final avatars =
        Map<String, dynamic>.from(d['participantAvatars'] ?? {});
    final unread = Map<String, dynamic>.from(d['unreadCount'] ?? {});

    return ConversationModel(
      conversationId: doc.id,
      otherUserId: otherUid,
      otherUserName: names[otherUid] ?? 'Unknown',
      otherUserAvatar: avatars[otherUid],
      lastMessage: d['lastMessage'] ?? '',
      isOnline: d['online_$otherUid'] ?? false,
      lastMessageAt: _ts(d['lastMessageAt']),
      unreadCount: (unread[currentUserId] as num?)?.toInt() ?? 0,
    );
  }

  static DateTime _ts(dynamic v) {
    if (v is Timestamp) return v.toDate();
    if (v is DateTime) return v;
    return DateTime.now();
  }
}
