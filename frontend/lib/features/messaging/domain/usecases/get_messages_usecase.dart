import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../entities/message.dart';
import '../repositories/message_repository.dart';

class GetMessagesUseCase {
  final MessageRepository repository;
  const GetMessagesUseCase(this.repository);

  Stream<Either<Failure, List<MessageEntity>>> call(
          GetMessagesParams params) =>
      repository.watchMessages(params.conversationId);
}

class GetMessagesParams extends Equatable {
  final String conversationId;
  const GetMessagesParams({required this.conversationId});

  @override
  List<Object?> get props => [conversationId];
}
