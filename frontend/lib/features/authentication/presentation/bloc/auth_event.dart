import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object?> get props => [];
}

class LoginEvent extends AuthEvent {
  final String email;
  final String password;
  const LoginEvent({required this.email, required this.password});
  @override
  List<Object?> get props => [email, password];
}

class RegisterEvent extends AuthEvent {
  final String email;
  final String password;
  final String? displayName;
  const RegisterEvent({
    required this.email,
    required this.password,
    this.displayName,
  });
  @override
  List<Object?> get props => [email, password, displayName];
}

/// Step 1 of OTP registration: request a code be sent to [email].
class SendOtpEvent extends AuthEvent {
  final String email;
  const SendOtpEvent({required this.email});
  @override
  List<Object?> get props => [email];
}

/// Step 2 of OTP registration: verify the code, then create the Firebase
/// account with the stored [email] / [password] / [displayName].
class VerifyOtpAndRegisterEvent extends AuthEvent {
  final String email;
  final String otp;
  final String password;
  final String? displayName;
  const VerifyOtpAndRegisterEvent({
    required this.email,
    required this.otp,
    required this.password,
    this.displayName,
  });
  @override
  List<Object?> get props => [email, otp, password, displayName];
}

class LogoutEvent extends AuthEvent {
  const LogoutEvent();
}

class GoogleSignInEvent extends AuthEvent {
  const GoogleSignInEvent();
}

class ForgotPasswordEvent extends AuthEvent {
  final String email;
  const ForgotPasswordEvent({required this.email});
  @override
  List<Object?> get props => [email];
}
