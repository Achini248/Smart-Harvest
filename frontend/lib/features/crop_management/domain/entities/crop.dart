import 'package:equatable/equatable.dart';

class Crop extends Equatable {
  final String id;
  final String name;
  final String type;
  final double quantity;
  final String unit;
  final String location;
  final DateTime plantedDate;
  final DateTime? harvestDate;
  final String status;
  final String? notes;
  final String ownerId;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Crop({
    required this.id,
    required this.name,
    required this.type,
    required this.quantity,
    required this.unit,
    required this.location,
    required this.plantedDate,
    this.harvestDate,
    required this.status,
    this.notes,
    required this.ownerId,
    required this.createdAt,
    required this.updatedAt,
  });

  Crop copyWith({
    String? id,
    String? name,
    String? type,
    double? quantity,
    String? unit,
    String? location,
    DateTime? plantedDate,
    DateTime? harvestDate,
    String? status,
    String? notes,
    String? ownerId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Crop(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      location: location ?? this.location,
      plantedDate: plantedDate ?? this.plantedDate,
      harvestDate: harvestDate ?? this.harvestDate,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      ownerId: ownerId ?? this.ownerId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        type,
        quantity,
        unit,
        location,
        plantedDate,
        harvestDate,
        status,
        notes,
        ownerId,
        createdAt,
        updatedAt,
      ];
}

// Enums for type safety — domain layer only
enum CropStatus { planted, growing, readyToHarvest, harvested, failed }

enum CropType {
  vegetable,
  fruit,
  grain,
  legume,
  root,
  herb,
  other,
}

extension CropStatusExtension on CropStatus {
  String get label {
    switch (this) {
      case CropStatus.planted:          return 'Planted';
      case CropStatus.growing:          return 'Growing';
      case CropStatus.readyToHarvest:   return 'Ready to Harvest';
      case CropStatus.harvested:        return 'Harvested';
      case CropStatus.failed:           return 'Failed';
    }
  }

  static CropStatus fromString(String value) {
    return CropStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => CropStatus.planted,
    );
  }
}

extension CropTypeExtension on CropType {
  String get label {
    switch (this) {
      case CropType.vegetable: return 'Vegetable';
      case CropType.fruit:     return 'Fruit';
      case CropType.grain:     return 'Grain';
      case CropType.legume:    return 'Legume';
      case CropType.root:      return 'Root';
      case CropType.herb:      return 'Herb';
      case CropType.other:     return 'Other';
    }
  }

  static CropType fromString(String value) {
    return CropType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => CropType.other,
    );
  }
}
