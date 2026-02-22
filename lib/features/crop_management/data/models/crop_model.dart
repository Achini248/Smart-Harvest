import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/crop.dart';

class CropModel extends Crop {
  const CropModel({
    required super.id,
    required super.name,
    required super.type,
    required super.quantity,
    required super.unit,
    required super.location,
    required super.plantedDate,
    super.harvestDate,
    required super.status,
    super.notes,
    required super.ownerId,
    required super.createdAt,
    required super.updatedAt,
  });

  // ── From Firestore document ────────────────────────────────────────────────
  factory CropModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CropModel(
      id: doc.id,
      name: data['name'] as String? ?? '',
      type: data['type'] as String? ?? 'other',
      quantity: (data['quantity'] as num?)?.toDouble() ?? 0.0,
      unit: data['unit'] as String? ?? 'kg',
      location: data['location'] as String? ?? '',
      plantedDate: _toDateTime(data['plantedDate']),
      harvestDate: data['harvestDate'] != null
          ? _toDateTime(data['harvestDate'])
          : null,
      status: data['status'] as String? ?? 'planted',
      notes: data['notes'] as String?,
      ownerId: data['ownerId'] as String? ?? '',
      createdAt: _toDateTime(data['createdAt']),
      updatedAt: _toDateTime(data['updatedAt']),
    );
  }

  // ── From JSON (for local/testing) ──────────────────────────────────────────
  factory CropModel.fromJson(Map<String, dynamic> json) {
    return CropModel(
      id: json['id'] as String,
      name: json['name'] as String,
      type: json['type'] as String,
      quantity: (json['quantity'] as num).toDouble(),
      unit: json['unit'] as String? ?? 'kg',
      location: json['location'] as String,
      plantedDate: DateTime.parse(json['plantedDate'] as String),
      harvestDate: json['harvestDate'] != null
          ? DateTime.parse(json['harvestDate'] as String)
          : null,
      status: json['status'] as String,
      notes: json['notes'] as String?,
      ownerId: json['ownerId'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  // ── To Firestore map ───────────────────────────────────────────────────────
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'type': type,
      'quantity': quantity,
      'unit': unit,
      'location': location,
      'plantedDate': Timestamp.fromDate(plantedDate),
      'harvestDate':
          harvestDate != null ? Timestamp.fromDate(harvestDate!) : null,
      'status': status,
      'notes': notes,
      'ownerId': ownerId,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  // ── To JSON map ────────────────────────────────────────────────────────────
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'quantity': quantity,
      'unit': unit,
      'location': location,
      'plantedDate': plantedDate.toIso8601String(),
      'harvestDate': harvestDate?.toIso8601String(),
      'status': status,
      'notes': notes,
      'ownerId': ownerId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // ── Create a CropModel from domain Crop entity ─────────────────────────────
  factory CropModel.fromEntity(Crop crop) {
    return CropModel(
      id: crop.id,
      name: crop.name,
      type: crop.type,
      quantity: crop.quantity,
      unit: crop.unit,
      location: crop.location,
      plantedDate: crop.plantedDate,
      harvestDate: crop.harvestDate,
      status: crop.status,
      notes: crop.notes,
      ownerId: crop.ownerId,
      createdAt: crop.createdAt,
      updatedAt: crop.updatedAt,
    );
  }

  // ── Helper: safely parse Firestore Timestamp or DateTime ──────────────────
  static DateTime _toDateTime(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) return DateTime.parse(value);
    return DateTime.now();
  }
}
