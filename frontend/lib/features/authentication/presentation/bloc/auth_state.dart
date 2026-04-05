import 'package:equatable/equatable.dart';

abstract class AuthState extends Equatable {
  const AuthState();
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class Authenticated extends AuthState {
  final String uid;
  final String? email;
  final String? displayName;
  const Authenticated({
    required this.uid,
    this.email,
    this.displayName,
  });
  @override
  List<Object?> get props => [uid, email, displayName];
}

class Unauthenticated extends AuthState {
  const Unauthenticated();
}

class AuthError extends AuthState {
  final String message;
  const AuthError({required this.message});
  @override
  List<Object?> get props => [message];
}

class PasswordResetSent extends AuthState {
  const PasswordResetSent();
}

/// Emitted when the backend has successfully sent an OTP to the email.
/// The UI should navigate to the OTP verification page.
class OtpSent extends AuthState {
  final String email;
  const OtpSent({required this.email});
  @override
  List<Object?> get props => [email];
}

/// Emitted when the OTP has been verified AND the Firebase account has been
/// created.  The auth-state listener will subsequently emit [Authenticated].
class OtpVerifiedAndRegistered extends AuthState {
  const OtpVerifiedAndRegistered();
}
