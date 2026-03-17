/// Exception thrown when a server error occurs
class ServerException implements Exception {
  final String message;
  
  const ServerException({required this.message});
  
  @override
  String toString() => message;
}

/// Exception thrown when there is no internet connection
class NetworkException implements Exception {
  final String message;
  
  const NetworkException({required this.message});
  
  @override
  String toString() => message;
}

/// Exception thrown when cache error occurs
class CacheException implements Exception {
  final String message;
  
  const CacheException({required this.message});
  
  @override
  String toString() => message;
}

/// Exception thrown when there is an authentication error
class AuthException implements Exception {
  final String message;
  
  const AuthException({required this.message});
  
  @override
  String toString() => message;
}
