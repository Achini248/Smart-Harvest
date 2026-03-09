import 'package:equatable/equatable.dart';

/// Base class for all failures
abstract class Failure extends Equatable {
  final String message;
  
  const Failure({required this.message});
  
  @override
  List<Object?> get props => [message];
}

/// Failure when server error occurs
class ServerFailure extends Failure {
  const ServerFailure({required super.message});
}

/// Failure when there is no internet connection
class NetworkFailure extends Failure {
  const NetworkFailure({required super.message});
}

/// Failure when cache error occurs
class CacheFailure extends Failure {
  const CacheFailure({required super.message});
}

/// Failure when authentication error occurs
class AuthFailure extends Failure {
  const AuthFailure({required super.message});
}
