import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String id;
  final String email;
  final String? name;
  final String? phoneNo;
  final String? location;
  final String? profilePhotoUrl;
  final String role; // 'farmer', 'buyer', 'officer'

  const UserEntity({
    required this.id,
    required this.email,
    this.name,
    this.phoneNo,
    this.location,
    this.profilePhotoUrl,
    this.role = 'farmer',
  });

  @override
  List<Object?> get props => [id, email, name, phoneNo, location, profilePhotoUrl, role];
}