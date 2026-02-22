import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../entities/crop.dart';
import '../repositories/crop_repository.dart';

class UpdateCropUseCase {
  final CropRepository repository;
  const UpdateCropUseCase(this.repository);

  Future<Either<Failure, Crop>> call(UpdateCropParams params) =>
      repository.updateCrop(params.crop);
}

class UpdateCropParams extends Equatable {
  final Crop crop;
  const UpdateCropParams({required this.crop});

  @override
  List<Object?> get props => [crop];
}
