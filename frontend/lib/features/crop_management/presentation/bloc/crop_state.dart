import 'package:equatable/equatable.dart';
import '../../domain/entities/crop.dart';

abstract class CropState extends Equatable {
  const CropState();

  @override
  List<Object?> get props => [];
}

/// Initial state before anything loads.
class CropInitialState extends CropState {
  const CropInitialState();
}

/// Loading all crops.
class CropLoadingState extends CropState {
  const CropLoadingState();
}

/// Crops loaded successfully.
class CropLoadedState extends CropState {
  final List<Crop> crops;
  const CropLoadedState({required this.crops});

  @override
  List<Object?> get props => [crops];
}

/// A crop operation (add/update/delete) is in progress.
class CropOperationLoadingState extends CropState {
  final List<Crop> crops; // keep showing current list during operation
  const CropOperationLoadingState({required this.crops});

  @override
  List<Object?> get props => [crops];
}

/// Add crop succeeded.
class CropAddedState extends CropState {
  final Crop addedCrop;
  final List<Crop> crops;
  const CropAddedState({required this.addedCrop, required this.crops});

  @override
  List<Object?> get props => [addedCrop, crops];
}

/// Update crop succeeded.
class CropUpdatedState extends CropState {
  final Crop updatedCrop;
  final List<Crop> crops;
  const CropUpdatedState({required this.updatedCrop, required this.crops});

  @override
  List<Object?> get props => [updatedCrop, crops];
}

/// Delete crop succeeded.
class CropDeletedState extends CropState {
  final List<Crop> crops;
  const CropDeletedState({required this.crops});

  @override
  List<Object?> get props => [crops];
}

/// An error occurred.
class CropErrorState extends CropState {
  final String message;
  final List<Crop> previousCrops; // keep current list visible
  const CropErrorState({
    required this.message,
    this.previousCrops = const [],
  });

  @override
  List<Object?> get props => [message, previousCrops];
}

/// No crops exist yet.
class CropEmptyState extends CropState {
  const CropEmptyState();
}
