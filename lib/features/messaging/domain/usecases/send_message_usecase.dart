import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../entities/message.dart';
import '../repositories/message_repository.dart';

class SendMessageUseCase {
  final MessageRepository repository;
  const SendMessageUseCase(this.repository);

  Future<Either<Failure, MessageEntity>> call(
          SendMessageParams params) =>
      repository.sendMessage(params.message);
}

class SendMessageParams extends Equatable {
  final MessageEntity message;
  const SendMessageParams({required this.message});

  @override
  List<Object?> get props => [message];
}
