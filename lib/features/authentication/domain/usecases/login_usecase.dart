// lib/features/authentication/domain/usecases/login_usecase.dart
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository repository;
  LoginUseCase(this.repository);

  Future<User> call(String email, String password) =>
      repository.login(email, password);
}
