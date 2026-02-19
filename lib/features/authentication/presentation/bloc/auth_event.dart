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
  final String phoneNo;

  const RegisterEvent({
    required this.email,
    required this.password,
    required this.phoneNo,
  });

  @override
  List<Object?> get props => [email, password, phoneNo];
}

// NEW: Google Sign-In Event
class GoogleSignInEvent extends AuthEvent {}

class LogoutEvent extends AuthEvent {}

class CheckAuthStatusEvent extends AuthEvent {}
