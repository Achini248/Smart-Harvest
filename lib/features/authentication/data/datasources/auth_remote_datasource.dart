// lib/features/authentication/data/datasources/auth_remote_datasource.dart

import '../../domain/entities/user.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<User?> getCurrentUser();
  Future<User> login(String email, String password);
  Future<User> register(String email, String password, String phone);
  Future<void> logout();
  Future<String> sendOtp(String phoneNumber);
  Future<User> verifyOtp(String verificationId, String otpCode);
}

// DUMMY implementation — replace with real Firebase calls later
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  @override
  Future<User?> getCurrentUser() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return null; // No user logged in initially
  }

  @override
  Future<User> login(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 800));
    // Dummy validation
    if (email.isEmpty || password.isEmpty) {
      throw Exception('Email and password are required');
    }
    if (password.length < 6) {
      throw Exception('wrong-password');
    }
    return UserModel(
      id: 'user_${email.hashCode}',
      email: email,
      phone: '',
    );
  }

  @override
  Future<User> register(String email, String password, String phone) async {
    await Future.delayed(const Duration(milliseconds: 800));
    if (email.isEmpty || password.isEmpty) {
      throw Exception('All fields are required');
    }
    return UserModel(
      id: 'user_${email.hashCode}',
      email: email,
      phone: phone,
    );
  }

  @override
  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 300));
  }

  @override
  Future<String> sendOtp(String phoneNumber) async {
    await Future.delayed(const Duration(milliseconds: 1000));
    if (phoneNumber.isEmpty) {
      throw Exception('invalid-phone-number');
    }
    // Return a dummy verificationId
    return 'dummy_verification_id_${phoneNumber.hashCode}';
  }

  @override
  Future<User> verifyOtp(String verificationId, String otpCode) async {
    await Future.delayed(const Duration(milliseconds: 800));
    // Dummy: accept "123456" as the valid OTP
    if (otpCode != '123456') {
      throw Exception('invalid-verification-code');
    }
    return UserModel(
      id: 'verified_user',
      email: 'user@smartharvest.lk',
      phone: '',
    );
  }
}
