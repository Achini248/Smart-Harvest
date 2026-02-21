import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/crop.dart';
import '../../domain/repositories/crop_repository.dart';
import '../datasources/crop_remote_datasource.dart';
import '../models/crop_model.dart';

class CropRepositoryImpl implements CropRepository {
  final CropRemoteDataSource remoteDataSource;

  const CropRepositoryImpl({required this.remoteDataSource});

  // ── Get crops ──────────────────────────────────────────────────────────────
  @override
  Future<Either<Failure, List<Crop>>> getCrops() async {
    try {
      final crops = await remoteDataSource.getCrops();
      return Right(crops);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  // ── Get crop by ID ─────────────────────────────────────────────────────────
  @override
  Future<Either<Failure, Crop>> getCropById(String id) async {
    try {
      final crop = await remoteDataSource.getCropById(id);
      return Right(crop);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  // ── Add crop ───────────────────────────────────────────────────────────────
  @override
  Future<Either<Failure, Crop>> addCrop(Crop crop) async {
    try {
      final model = CropModel.fromEntity(crop);
      final result = await remoteDataSource.addCrop(model);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  // ── Update crop ────────────────────────────────────────────────────────────
  @override
  Future<Either<Failure, Crop>> updateCrop(Crop crop) async {
    try {
      final model = CropModel.fromEntity(crop);
      final result = await remoteDataSource.updateCrop(model);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  // ── Delete crop ────────────────────────────────────────────────────────────
  @override
  Future<Either<Failure, void>> deleteCrop(String id) async {
    try {
      await remoteDataSource.deleteCrop(id);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  // ── Watch crops (stream) ───────────────────────────────────────────────────
  @override
  Stream<Either<Failure, List<Crop>>> watchCrops() {
    return remoteDataSource.watchCrops().map<Either<Failure, List<Crop>>>(
      (crops) => Right(crops),
    ).handleError(
      (error) => Left(
        ServerFailure(
          message: error is ServerException
              ? error.message
              : error.toString(),
        ),
      ),
    );
  }
}
