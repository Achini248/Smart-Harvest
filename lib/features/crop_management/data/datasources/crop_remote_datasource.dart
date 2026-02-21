import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/crop_model.dart';

abstract class CropRemoteDataSource {
  Future<List<CropModel>> getCrops();
  Future<CropModel> getCropById(String id);
  Future<CropModel> addCrop(CropModel crop);
  Future<CropModel> updateCrop(CropModel crop);
  Future<void> deleteCrop(String id);
  Stream<List<CropModel>> watchCrops();
}

class CropRemoteDataSourceImpl implements CropRemoteDataSource {
  final FirebaseFirestore _firestore;

  static const String _collection = 'crops';

  CropRemoteDataSourceImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _cropsRef =>
      _firestore.collection(_collection);

  // ── Get all crops ──────────────────────────────────────────────────────────
  @override
  Future<List<CropModel>> getCrops() async {
    try {
      final snapshot = await _cropsRef
          .orderBy('createdAt', descending: true)
          .get();
      return snapshot.docs
          .map((doc) => CropModel.fromFirestore(doc))
          .toList();
    } on FirebaseException catch (e) {
      throw ServerException(message: e.message ?? 'Failed to fetch crops.');
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  // ── Get crop by ID ─────────────────────────────────────────────────────────
  @override
  Future<CropModel> getCropById(String id) async {
    try {
      final doc = await _cropsRef.doc(id).get();
      if (!doc.exists) {
        throw const ServerException(message: 'Crop not found.');
      }
      return CropModel.fromFirestore(doc);
    } on FirebaseException catch (e) {
      throw ServerException(message: e.message ?? 'Failed to fetch crop.');
    }
  }

  // ── Add crop ───────────────────────────────────────────────────────────────
  @override
  Future<CropModel> addCrop(CropModel crop) async {
    try {
      final docRef = _cropsRef.doc(); // auto-generate ID
      final newCrop = CropModel(
        id: docRef.id,
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
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await docRef.set(newCrop.toFirestore());
      return newCrop;
    } on FirebaseException catch (e) {
      throw ServerException(message: e.message ?? 'Failed to add crop.');
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  // ── Update crop ────────────────────────────────────────────────────────────
  @override
  Future<CropModel> updateCrop(CropModel crop) async {
    try {
      final updatedCrop = CropModel(
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
        updatedAt: DateTime.now(),
      );
      await _cropsRef.doc(crop.id).update(updatedCrop.toFirestore());
      return updatedCrop;
    } on FirebaseException catch (e) {
      throw ServerException(message: e.message ?? 'Failed to update crop.');
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  // ── Delete crop ────────────────────────────────────────────────────────────
  @override
  Future<void> deleteCrop(String id) async {
    try {
      await _cropsRef.doc(id).delete();
    } on FirebaseException catch (e) {
      throw ServerException(message: e.message ?? 'Failed to delete crop.');
    }
  }

  // ── Watch crops (real-time stream) ─────────────────────────────────────────
  @override
  Stream<List<CropModel>> watchCrops() {
    return _cropsRef
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => CropModel.fromFirestore(doc)).toList())
        .handleError((error) {
      throw ServerException(
          message: error is FirebaseException
              ? error.message ?? 'Stream error.'
              : error.toString());
    });
  }
}
