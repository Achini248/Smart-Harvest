import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/crop.dart';

abstract class CropRepository {
  /// Fetch all crops for the current user.
  Future<Either<Failure, List<Crop>>> getCrops();

  /// Fetch a single crop by ID.
  Future<Either<Failure, Crop>> getCropById(String id);

  /// Add a new crop to Firestore.
  Future<Either<Failure, Crop>> addCrop(Crop crop);

  /// Update an existing crop.
  Future<Either<Failure, Crop>> updateCrop(Crop crop);

  /// Delete a crop by ID.
  Future<Either<Failure, void>> deleteCrop(String id);

  /// Real-time stream of crops.
  Stream<Either<Failure, List<Crop>>> watchCrops();
}
