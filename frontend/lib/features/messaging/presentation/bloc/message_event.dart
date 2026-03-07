import 'package:equatable/equatable.dart';
import '../../domain/entities/message.dart';

abstract class MessageEvent extends Equatable {
  const MessageEvent();
  @override
  List<Object?> get props => [];
}

class LoadConversationsEvent extends MessageEvent {
  final String userId;
  const LoadConversationsEvent({required this.userId});
  @override
  List<Object?> get props => [userId];
}

class OpenConversationEvent extends MessageEvent {
  final String conversationId;
  final String currentUserId;
  const OpenConversationEvent({
    required this.conversationId,
    required this.currentUserId,
  });
  @override
  List<Object?> get props => [conversationId, currentUserId];
}

class SendMessageEvent extends MessageEvent {
  final MessageEntity message;
  const SendMessageEvent({required this.message});
  @override
  List<Object?> get props => [message];
}

class MessageReceivedEvent extends MessageEvent {
  final List<MessageEntity> messages;
  const MessageReceivedEvent({required this.messages});
  @override
  List<Object?> get props => [messages];
}

class MarkAsReadEvent extends MessageEvent {
  final String conversationId;
  final String userId;
  const MarkAsReadEvent(
      {required this.conversationId, required this.userId});
  @override
  List<Object?> get props => [conversationId, userId];
}

class ClearMessageErrorEvent extends MessageEvent {
  const ClearMessageErrorEvent();
}
