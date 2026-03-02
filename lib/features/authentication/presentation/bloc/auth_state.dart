import 'package:equatable/equatable.dart';
import '../../domain/entities/user.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {
  const AuthInitial(); // const එකතු කළා
}

class AuthLoading extends AuthState {
  const AuthLoading(); // const එකතු කළා
}

class Authenticated extends AuthState {
  final UserEntity user; // 'User' වෙනුවට 'UserEntity' ලෙස වෙනස් කළා

  const Authenticated({required this.user});

  @override
  List<Object?> get props => [user];
}

class Unauthenticated extends AuthState {
  const Unauthenticated(); // const එකතු කළා
}

class AuthError extends AuthState {
  final String message;

  const AuthError({required this.message});

  @override
  List<Object?> get props => [message];
}