// lib/features/authentication/presentation/bloc/auth_state.dart

import 'package:equatable/equatable.dart';
import '../../domain/entities/user.dart';

abstract class AuthState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthUnauthenticated extends AuthState {}

class AuthAuthenticated extends AuthState {
  final User user;
  AuthAuthenticated(this.user);

  @override
  List<Object?> get props => [user];
}

class AuthOtpSent extends AuthState {
  final String verificationId;
  final String phoneNumber;

  AuthOtpSent({
    required this.verificationId,
    required this.phoneNumber,
  });

  @override
  List<Object?> get props => [verificationId, phoneNumber];
}

class AuthOtpTimerTick extends AuthState {
  final String verificationId;
  final String phoneNumber;
  final int secondsLeft;

  AuthOtpTimerTick({
    required this.verificationId,
    required this.phoneNumber,
    required this.secondsLeft,
  });

  @override
  List<Object?> get props => [verificationId, phoneNumber, secondsLeft];
}

class AuthProfileUpdated extends AuthState {
  final User user;
  AuthProfileUpdated(this.user);

  @override
  List<Object?> get props => [user];
}

// FIXED: positional constructor — AuthError('message')
class AuthError extends AuthState {
  final String message;
  AuthError(this.message);

  @override
  List<Object?> get props => [message];
}
