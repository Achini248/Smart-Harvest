//crop_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/crop.dart';
import '../../domain/usecases/add_crop_usecase.dart';
import '../../domain/usecases/get_crops_usecase.dart';
import '../../domain/usecases/update_crop_usecase.dart';
import '../../domain/repositories/crop_repository.dart';
import 'crop_event.dart';
import 'crop_state.dart';

class CropBloc extends Bloc<CropEvent, CropState> {
  final GetCropsUseCase _getCropsUseCase;
  final AddCropUseCase _addCropUseCase;
  final UpdateCropUseCase _updateCropUseCase;
  final CropRepository _cropRepository;

  // Hold current crops in memory for operations
  List<Crop> _currentCrops = [];

  CropBloc({
    required GetCropsUseCase getCropsUseCase,
    required AddCropUseCase addCropUseCase,
    required UpdateCropUseCase updateCropUseCase,
    required CropRepository cropRepository,
  })  : _getCropsUseCase = getCropsUseCase,
        _addCropUseCase = addCropUseCase,
        _updateCropUseCase = updateCropUseCase,
        _cropRepository = cropRepository,
        super(const CropInitialState()) {
    on<LoadCropsEvent>(_onLoadCrops);
    on<RefreshCropsEvent>(_onRefreshCrops);
    on<AddCropEvent>(_onAddCrop);
    on<UpdateCropEvent>(_onUpdateCrop);
    on<DeleteCropEvent>(_onDeleteCrop);
    on<ClearCropErrorEvent>(_onClearError);
  }

  // ── Load crops ─────────────────────────────────────────────────────────────
  Future<void> _onLoadCrops(
    LoadCropsEvent event,
    Emitter<CropState> emit,
  ) async {
    emit(const CropLoadingState());
    final result = await _getCropsUseCase();
    result.fold(
      (failure) => emit(CropErrorState(message: failure.message)),
      (crops) {
        _currentCrops = crops;
        if (crops.isEmpty) {
          emit(const CropEmptyState());
        } else {
          emit(CropLoadedState(crops: crops));
        }
      },
    );
  }

  // ── Refresh crops ──────────────────────────────────────────────────────────
  Future<void> _onRefreshCrops(
    RefreshCropsEvent event,
    Emitter<CropState> emit,
  ) async {
    // Show current list while refreshing (no full loading spinner)
    if (_currentCrops.isNotEmpty) {
      emit(CropLoadedState(crops: _currentCrops));
    }
    final result = await _getCropsUseCase();
    result.fold(
      (failure) => emit(
          CropErrorState(message: failure.message, previousCrops: _currentCrops)),
      (crops) {
        _currentCrops = crops;
        if (crops.isEmpty) {
          emit(const CropEmptyState());
        } else {
          emit(CropLoadedState(crops: crops));
        }
      },
    );
  }

  // ── Add crop ───────────────────────────────────────────────────────────────
  Future<void> _onAddCrop(
    AddCropEvent event,
    Emitter<CropState> emit,
  ) async {
    emit(CropOperationLoadingState(crops: _currentCrops));
    final result = await _addCropUseCase(AddCropParams(crop: event.crop));
    result.fold(
      (failure) => emit(
          CropErrorState(message: failure.message, previousCrops: _currentCrops)),
      (addedCrop) {
        _currentCrops = [addedCrop, ..._currentCrops];
        emit(CropAddedState(addedCrop: addedCrop, crops: _currentCrops));
      },
    );
  }

  // ── Update crop ────────────────────────────────────────────────────────────
  Future<void> _onUpdateCrop(
    UpdateCropEvent event,
    Emitter<CropState> emit,
  ) async {
    emit(CropOperationLoadingState(crops: _currentCrops));
    final result =
        await _updateCropUseCase(UpdateCropParams(crop: event.crop));
    result.fold(
      (failure) => emit(
          CropErrorState(message: failure.message, previousCrops: _currentCrops)),
      (updatedCrop) {
        _currentCrops = _currentCrops
            .map((c) => c.id == updatedCrop.id ? updatedCrop : c)
            .toList();
        emit(CropUpdatedState(updatedCrop: updatedCrop, crops: _currentCrops));
      },
    );
  }

  // ── Delete crop ────────────────────────────────────────────────────────────
  Future<void> _onDeleteCrop(
    DeleteCropEvent event,
    Emitter<CropState> emit,
  ) async {
    emit(CropOperationLoadingState(crops: _currentCrops));
    final result = await _cropRepository.deleteCrop(event.cropId);
    result.fold(
      (failure) => emit(
          CropErrorState(message: failure.message, previousCrops: _currentCrops)),
      (_) {
        _currentCrops =
            _currentCrops.where((c) => c.id != event.cropId).toList();
        if (_currentCrops.isEmpty) {
          emit(const CropEmptyState());
        } else {
          emit(CropDeletedState(crops: _currentCrops));
        }
      },
    );
  }

  // ── Clear error ────────────────────────────────────────────────────────────
  void _onClearError(ClearCropErrorEvent event, Emitter<CropState> emit) {
    if (_currentCrops.isEmpty) {
      emit(const CropEmptyState());
    } else {
      emit(CropLoadedState(crops: _currentCrops));
    }
  }
}
