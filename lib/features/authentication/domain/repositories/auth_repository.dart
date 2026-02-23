

import '../entities/user.dart';

abstract class AuthRepository {
  Future<User?> getCurrentUser();
  Future<User> login(String email, String password);
  Future<User> register(String email, String password, String phone);
  Future<void> logout();
  Future<String> sendOtp(String phoneNumber);
  Future<User> verifyOtp(String verificationId, String otpCode);
}
