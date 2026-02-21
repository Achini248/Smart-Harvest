// lib/features/authentication/data/repositories/auth_repository_impl.dart

import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  AuthRepositoryImpl({required this.remoteDataSource});

  @override
  Future<User?> getCurrentUser() => remoteDataSource.getCurrentUser();

  @override
  Future<User> login(String email, String password) =>
      remoteDataSource.login(email, password);

  @override
  Future<User> register(String email, String password, String phone) =>
      remoteDataSource.register(email, password, phone);

  @override
  Future<void> logout() => remoteDataSource.logout();

  @override
  Future<String> sendOtp(String phoneNumber) =>
      remoteDataSource.sendOtp(phoneNumber);

  @override
  Future<User> verifyOtp(String verificationId, String otpCode) =>
      remoteDataSource.verifyOtp(verificationId, otpCode);
}
