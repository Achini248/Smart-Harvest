// lib/features/authentication/domain/usecases/register_usecase.dart
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class RegisterUseCase {
  final AuthRepository repository;
  RegisterUseCase(this.repository);

  Future<User> call(String email, String password, String phone) =>
      repository.register(email, password, phone);
}
