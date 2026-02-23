//usermodel.dart
import '../../domain/entities/user.dart';

class UserModel extends User {
  const UserModel({
    required super.id,
    required super.email,
    super.name,
    super.phoneNo,
    super.location,
    super.profilePhotoUrl,
    super.role,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      name: json['name'],
      phoneNo: json['phoneNo'],
      location: json['location'],
      profilePhotoUrl: json['profilePhotoUrl'],
      role: json['role'] ?? 'farmer',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'phoneNo': phoneNo,
      'location': location,
      'profilePhotoUrl': profilePhotoUrl,
      'role': role,
    };
  }

  User toEntity() {
    return User(
      id: id,
      email: email,
      name: name,
      phoneNo: phoneNo,
      location: location,
      profilePhotoUrl: profilePhotoUrl,
      role: role,
    );
  }
}
