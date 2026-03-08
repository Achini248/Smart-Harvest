import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class RegisterUseCase {
  final AuthRepository repository;
  const RegisterUseCase(this.repository);

  
  Future<Either<Failure, UserEntity>> call(RegisterParams params) =>
      repository.register(params.email, params.password, params.phoneNumber);
}

class RegisterParams extends Equatable {
  final String email;
  final String password;
  final String displayName;
  final String phoneNumber; 

  const RegisterParams({
    required this.email,
    required this.password,
    required this.displayName,
    required this.phoneNumber, 
  });

  @override
  List<Object?> get props => [email, password, displayName, phoneNumber];
}