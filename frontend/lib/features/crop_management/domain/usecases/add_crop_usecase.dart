import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../entities/crop.dart';
import '../repositories/crop_repository.dart';

class AddCropUseCase {
  final CropRepository repository;
  const AddCropUseCase(this.repository);

  Future<Either<Failure, Crop>> call(AddCropParams params) =>
      repository.addCrop(params.crop);
}

class AddCropParams extends Equatable {
  final Crop crop;
  const AddCropParams({required this.crop});

  @override
  List<Object?> get props => [crop];
}
