import 'package:equatable/equatable.dart';

class MessageEntity extends Equatable {
  final String id;
  final String conversationId;
  final String senderId;
  final String senderName;
  final String receiverId;
  final String receiverName;
  final String content;
  final bool isRead;
  final DateTime createdAt;

  const MessageEntity({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.senderName,
    required this.receiverId,
    required this.receiverName,
    required this.content,
    required this.isRead,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id, conversationId, senderId, senderName,
        receiverId, receiverName, content, isRead, createdAt,
      ];
}

/// Lightweight summary shown in the messages list screen
class ConversationEntity extends Equatable {
  final String conversationId;
  final String otherUserId;
  final String otherUserName;
  final String? otherUserAvatar;
  final String lastMessage;
  final bool isOnline;
  final DateTime lastMessageAt;
  final int unreadCount;

  const ConversationEntity({
    required this.conversationId,
    required this.otherUserId,
    required this.otherUserName,
    this.otherUserAvatar,
    required this.lastMessage,
    this.isOnline = false,
    required this.lastMessageAt,
    this.unreadCount = 0,
  });

  @override
  List<Object?> get props => [
        conversationId, otherUserId, otherUserName,
        otherUserAvatar, lastMessage, isOnline,
        lastMessageAt, unreadCount,
      ];
}
