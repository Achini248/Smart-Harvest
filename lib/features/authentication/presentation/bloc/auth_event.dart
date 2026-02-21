// lib/features/authentication/presentation/bloc/auth_event.dart

import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class AuthCheckStatusEvent extends AuthEvent {}

class AuthLoginEvent extends AuthEvent {
  final String email;
  final String password;
  AuthLoginEvent(this.email, this.password);

  @override
  List<Object?> get props => [email, password];
}

class AuthRegisterEvent extends AuthEvent {
  final String email;
  final String password;
  final String phone;
  AuthRegisterEvent(this.email, this.password, this.phone);

  @override
  List<Object?> get props => [email, password, phone];
}

class AuthLogoutEvent extends AuthEvent {}

class AuthSendOtpEvent extends AuthEvent {
  final String phoneNumber;
  AuthSendOtpEvent(this.phoneNumber);

  @override
  List<Object?> get props => [phoneNumber];
}

class AuthVerifyOtpEvent extends AuthEvent {
  final String verificationId;
  final String otpCode;
  AuthVerifyOtpEvent(this.verificationId, this.otpCode);

  @override
  List<Object?> get props => [verificationId, otpCode];
}

class AuthResendOtpEvent extends AuthEvent {
  final String phoneNumber;
  AuthResendOtpEvent(this.phoneNumber);

  @override
  List<Object?> get props => [phoneNumber];
}

class AuthTimerTickEvent extends AuthEvent {
  final String verificationId;
  final String phoneNumber;
  final int secondsLeft;
  AuthTimerTickEvent(this.verificationId, this.phoneNumber, this.secondsLeft);

  @override
  List<Object?> get props => [verificationId, phoneNumber, secondsLeft];
}

class AuthUpdateProfileEvent extends AuthEvent {
  final String displayName;
  final String phone;
  final String role;
  AuthUpdateProfileEvent({
    required this.displayName,
    required this.phone,
    required this.role,
  });

  @override
  List<Object?> get props => [displayName, phone, role];
}
