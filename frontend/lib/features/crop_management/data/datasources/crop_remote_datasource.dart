// lib/features/crop_management/data/datasources/crop_remote_datasource.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/crop_model.dart';

abstract class CropRemoteDataSource {
  Future<List<CropModel>> getCrops();
  Future<CropModel>       getCropById(String id);
  Future<CropModel>       addCrop(CropModel crop);
  Future<CropModel>       updateCrop(CropModel crop);
  Future<void>            deleteCrop(String id);
  Stream<List<CropModel>> watchCrops();
}

class CropRemoteDataSourceImpl implements CropRemoteDataSource {
  final FirebaseFirestore _firestore;

  CropRemoteDataSourceImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  String get _uid => FirebaseAuth.instance.currentUser?.uid ?? '';

  CollectionReference<Map<String, dynamic>> get _col =>
      _firestore.collection('crops');

  @override
  Future<List<CropModel>> getCrops() async {
    try {
      final snap = await _col
          .where('ownerId', isEqualTo: _uid)
          .orderBy('createdAt', descending: true)
          .get();
      return snap.docs.map(CropModel.fromFirestore).toList();
    } on FirebaseException catch (e) {
      throw ServerException(message: e.message ?? 'Failed to fetch crops.');
    }
  }

  @override
  Future<CropModel> getCropById(String id) async {
    try {
      final doc = await _col.doc(id).get();
      if (!doc.exists) throw const ServerException(message: 'Crop not found.');
      return CropModel.fromFirestore(doc);
    } on FirebaseException catch (e) {
      throw ServerException(message: e.message ?? 'Failed to fetch crop.');
    }
  }

  @override
  Future<CropModel> addCrop(CropModel crop) async {
    try {
      final ref = _col.doc();
      final now = DateTime.now();
      final newCrop = CropModel(
        id: ref.id, name: crop.name, type: crop.type,
        quantity: crop.quantity, unit: crop.unit,
        location: crop.location, plantedDate: crop.plantedDate,
        harvestDate: crop.harvestDate, status: crop.status,
        notes: crop.notes, ownerId: _uid,
        createdAt: now, updatedAt: now,
      );
      await ref.set(newCrop.toFirestore());
      return newCrop;
    } on FirebaseException catch (e) {
      throw ServerException(message: e.message ?? 'Failed to add crop.');
    }
  }

  @override
  Future<CropModel> updateCrop(CropModel crop) async {
    try {
      final updated = CropModel(
        id: crop.id, name: crop.name, type: crop.type,
        quantity: crop.quantity, unit: crop.unit,
        location: crop.location, plantedDate: crop.plantedDate,
        harvestDate: crop.harvestDate, status: crop.status,
        notes: crop.notes, ownerId: crop.ownerId,
        createdAt: crop.createdAt, updatedAt: DateTime.now(),
      );
      await _col.doc(crop.id).update(updated.toFirestore());
      return updated;
    } on FirebaseException catch (e) {
      throw ServerException(message: e.message ?? 'Failed to update crop.');
    }
  }

  @override
  Future<void> deleteCrop(String id) async {
    try {
      await _col.doc(id).delete();
    } on FirebaseException catch (e) {
      throw ServerException(message: e.message ?? 'Failed to delete crop.');
    }
  }

  @override
  Stream<List<CropModel>> watchCrops() {
    return _col
        .where('ownerId', isEqualTo: _uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map(CropModel.fromFirestore).toList())
        .handleError((e) {
      throw ServerException(
          message: e is FirebaseException ? e.message ?? 'Stream error.' : e.toString());
    });
  }
}
