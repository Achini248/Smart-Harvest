import 'package:equatable/equatable.dart';
import '../../domain/entities/message.dart';

abstract class MessageState extends Equatable {
  const MessageState();
  @override
  List<Object?> get props => [];
}

class MessageInitialState extends MessageState {
  const MessageInitialState();
}

class MessageLoadingState extends MessageState {
  const MessageLoadingState();
}

class ConversationsLoadedState extends MessageState {
  final List<ConversationEntity> conversations;
  const ConversationsLoadedState({required this.conversations});
  @override
  List<Object?> get props => [conversations];
}

class ChatOpenState extends MessageState {
  final String conversationId;
  final List<MessageEntity> messages;
  final bool isSending;

  const ChatOpenState({
    required this.conversationId,
    required this.messages,
    this.isSending = false,
  });

  ChatOpenState copyWith({
    String? conversationId,
    List<MessageEntity>? messages,
    bool? isSending,
  }) {
    return ChatOpenState(
      conversationId: conversationId ?? this.conversationId,
      messages: messages ?? this.messages,
      isSending: isSending ?? this.isSending,
    );
  }

  @override
  List<Object?> get props => [conversationId, messages, isSending];
}

class MessageEmptyState extends MessageState {
  final String message;
  const MessageEmptyState({required this.message});
  @override
  List<Object?> get props => [message];
}

class MessageErrorState extends MessageState {
  final String message;
  const MessageErrorState({required this.message});
  @override
  List<Object?> get props => [message];
}
