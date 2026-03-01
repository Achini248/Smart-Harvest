import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/user.dart';

abstract class AuthRepository {
  Future<Either<Failure, UserEntity>> login(
    String email,
    String password,
  );

  Future<Either<Failure, UserEntity>> register(
    String email,
    String password,
    String phoneNo,
  );

  Future<Either<Failure, void>> logout();

  Future<UserEntity?> getCurrentUser();
}
