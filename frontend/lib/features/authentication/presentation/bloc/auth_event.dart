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
  const RegisterEvent({required this.email, required this.password, this.displayName});
  @override
  List<Object?> get props => [email, password, displayName];
}

class LogoutEvent extends AuthEvent {
  const LogoutEvent();
}
