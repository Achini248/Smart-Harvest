// lib/features/crop_management/data/datasources/crop_remote_datasource.dart
// All CRUD goes directly to Firestore — works on all platforms, no Flask needed.

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
  final FirebaseFirestore _db;

  CropRemoteDataSourceImpl({
    dynamic apiClient,            // kept for DI compat — no longer used
    FirebaseFirestore? firestore,
  }) : _db = firestore ?? FirebaseFirestore.instance;

  String get _uid {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null || uid.isEmpty) {
      throw const AuthException(message: 'User is not authenticated.');
    }
    return uid;
  }

  @override
  Future<List<CropModel>> getCrops() async {
    try {
      final snap = await _db.collection('crops')
          .where('ownerId', isEqualTo: _uid)
          .orderBy('createdAt', descending: true)
          .get();
      return snap.docs.map(CropModel.fromFirestore).toList();
    } on AuthException {
      rethrow;
    } catch (e) {
      throw ServerException(message: 'Failed to fetch crops: $e');
    }
  }

  @override
  Future<CropModel> getCropById(String id) async {
    try {
      final doc = await _db.collection('crops').doc(id).get();
      if (!doc.exists) throw const ServerException(message: 'Crop not found.');
      return CropModel.fromFirestore(doc);
    } catch (e) {
      throw ServerException(message: 'Failed to fetch crop: $e');
    }
  }

  @override
  Future<CropModel> addCrop(CropModel crop) async {
    try {
      final uid = _uid;
      final ref = _db.collection('crops').doc();
      final data = {
        ...crop.toFirestore(),
        'id':        ref.id,
        'ownerId':   uid,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };
      await ref.set(data);
      final doc = await ref.get();
      return CropModel.fromFirestore(doc);
    } on AuthException {
      rethrow;
    } catch (e) {
      throw ServerException(message: 'Failed to add crop: $e');
    }
  }

  @override
  Future<CropModel> updateCrop(CropModel crop) async {
    try {
      final data = {
        ...crop.toFirestore(),
        'updatedAt': FieldValue.serverTimestamp(),
      };
      await _db.collection('crops').doc(crop.id).update(data);
      final doc = await _db.collection('crops').doc(crop.id).get();
      return CropModel.fromFirestore(doc);
    } catch (e) {
      throw ServerException(message: 'Failed to update crop: $e');
    }
  }

  @override
  Future<void> deleteCrop(String id) async {
    try {
      await _db.collection('crops').doc(id).delete();
    } catch (e) {
      throw ServerException(message: 'Failed to delete crop: $e');
    }
  }

  @override
  Stream<List<CropModel>> watchCrops() {
    final uid = _uid;
    return _db.collection('crops')
        .where('ownerId', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map(CropModel.fromFirestore).toList())
        .handleError((e) {
      throw ServerException(
        message: e is FirebaseException
            ? (e.message ?? 'Stream error.')
            : e.toString(),
      );
    });
  }
}
