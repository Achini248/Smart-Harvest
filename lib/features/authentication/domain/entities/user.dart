// lib/features/authentication/domain/entities/user.dart

import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String email;
  final String? phone;

  const User({
    required this.id,
    required this.email,
    this.phone,
  });

  @override
  List<Object?> get props => [id, email, phone];
}
