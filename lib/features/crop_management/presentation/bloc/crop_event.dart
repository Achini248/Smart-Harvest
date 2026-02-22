import 'package:equatable/equatable.dart';
import '../../domain/entities/crop.dart';

abstract class CropEvent extends Equatable {
  const CropEvent();

  @override
  List<Object?> get props => [];
}

/// Load all crops from Firestore.
class LoadCropsEvent extends CropEvent {
  const LoadCropsEvent();
}

/// Refresh crops (same as load but triggered explicitly by user).
class RefreshCropsEvent extends CropEvent {
  const RefreshCropsEvent();
}

/// Add a new crop.
class AddCropEvent extends CropEvent {
  final Crop crop;
  const AddCropEvent({required this.crop});

  @override
  List<Object?> get props => [crop];
}

/// Update an existing crop.
class UpdateCropEvent extends CropEvent {
  final Crop crop;
  const UpdateCropEvent({required this.crop});

  @override
  List<Object?> get props => [crop];
}

/// Delete a crop.
class DeleteCropEvent extends CropEvent {
  final String cropId;
  const DeleteCropEvent({required this.cropId});

  @override
  List<Object?> get props => [cropId];
}

/// Select a crop for detail view.
class SelectCropEvent extends CropEvent {
  final Crop crop;
  const SelectCropEvent({required this.crop});

  @override
  List<Object?> get props => [crop];
}

/// Clear any error state.
class ClearCropErrorEvent extends CropEvent {
  const ClearCropErrorEvent();
}
