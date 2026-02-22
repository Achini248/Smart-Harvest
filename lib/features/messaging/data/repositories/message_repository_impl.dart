import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/message.dart';
import '../../domain/repositories/message_repository.dart';
import '../datasources/message_remote_datasource.dart';
import '../models/message_model.dart';

class MessageRepositoryImpl implements MessageRepository {
  final MessageRemoteDataSource remoteDataSource;
  const MessageRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, MessageEntity>> sendMessage(
      MessageEntity message) async {
    try {
      final r = await remoteDataSource
          .sendMessage(MessageModel.fromEntity(message));
      return Right(r);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<MessageEntity>>> getMessages(
      String conversationId) async {
    try {
      final r =
          await remoteDataSource.getMessages(conversationId);
      return Right(r);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Stream<Either<Failure, List<MessageEntity>>> watchMessages(
      String conversationId) {
    return remoteDataSource
        .watchMessages(conversationId)
        .map<Either<Failure, List<MessageEntity>>>(
            (msgs) => Right(msgs))
        .handleError((e) => Left(ServerFailure(
            message: e is ServerException
                ? e.message
                : e.toString())));
  }

  @override
  Future<Either<Failure, List<ConversationEntity>>>
      getConversations(String userId) async {
    try {
      final r =
          await remoteDataSource.getConversations(userId);
      return Right(r);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> markAsRead(
      String conversationId, String userId) async {
    try {
      await remoteDataSource.markAsRead(conversationId, userId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
