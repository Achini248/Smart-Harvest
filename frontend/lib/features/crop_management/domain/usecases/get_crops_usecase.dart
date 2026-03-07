import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/crop.dart';
import '../repositories/crop_repository.dart';

class GetCropsUseCase {
  final CropRepository repository;
  const GetCropsUseCase(this.repository);

  Future<Either<Failure, List<Crop>>> call() => repository.getCrops();
}
