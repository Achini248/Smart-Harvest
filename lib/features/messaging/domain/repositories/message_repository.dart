import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/message.dart';

abstract class MessageRepository {
  /// Send a new message.
  Future<Either<Failure, MessageEntity>> sendMessage(MessageEntity message);

  /// Get all messages in a conversation (one-time fetch).
  Future<Either<Failure, List<MessageEntity>>> getMessages(
      String conversationId);

  /// Real-time stream of messages for a conversation.
  Stream<Either<Failure, List<MessageEntity>>> watchMessages(
      String conversationId);

  /// Get all conversation summaries for a user.
  Future<Either<Failure, List<ConversationEntity>>> getConversations(
      String userId);

  /// Mark all messages in a conversation as read.
  Future<Either<Failure, void>> markAsRead(
      String conversationId, String userId);
}
