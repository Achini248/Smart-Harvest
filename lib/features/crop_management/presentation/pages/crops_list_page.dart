import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../config/routes/route_names.dart';
import '../bloc/crop_bloc.dart';
import '../bloc/crop_event.dart';
import '../bloc/crop_state.dart';
import '../widgets/crop_card.dart';
import '../../domain/entities/crop.dart';

class CropsListPage extends StatefulWidget {
  const CropsListPage({super.key});

  @override
  State<CropsListPage> createState() => _CropsListPageState();
}

class _CropsListPageState extends State<CropsListPage> {
  @override
  void initState() {
    super.initState();
    context.read<CropBloc>().add(const LoadCropsEvent());
  }

  void _showSnack(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor:
            isError ? AppColors.error : AppColors.primaryGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _confirmDelete(BuildContext context, Crop crop) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Crop'),
        content: Text(
            'Are you sure you want to delete "${crop.name}"? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel',
                style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              Navigator.pop(context);
              context
                  .read<CropBloc>()
                  .add(DeleteCropEvent(cropId: crop.id));
            },
            child: const Text('Delete',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'My Crops',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 20),
        ),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        actions: [
          // Refresh button
          IconButton(
            icon: const Icon(Icons.refresh_outlined),
            onPressed: () =>
                context.read<CropBloc>().add(const RefreshCropsEvent()),
            tooltip: 'Refresh',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, RouteNames.addCrop),
        backgroundColor: AppColors.primaryGreen,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Add Crop',
          style:
              TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
      body: BlocConsumer<CropBloc, CropState>(
        listener: (context, state) {
          if (state is CropAddedState) {
            _showSnack('${state.addedCrop.name} added successfully!');
          } else if (state is CropUpdatedState) {
            _showSnack('${state.updatedCrop.name} updated successfully!');
          } else if (state is CropDeletedState) {
            _showSnack('Crop deleted.');
          } else if (state is CropErrorState) {
            _showSnack(state.message, isError: true);
          }
        },
        builder: (context, state) {
          // ── Loading ────────────────────────────────────────────────
          if (state is CropLoadingState) {
            return const Center(
              child: CircularProgressIndicator(
                  color: AppColors.primaryGreen),
            );
          }

          // ── Empty ──────────────────────────────────────────────────
          if (state is CropEmptyState) {
            return _EmptyState(
              onAddCrop: () =>
                  Navigator.pushNamed(context, RouteNames.addCrop),
            );
          }

          // ── Error (no existing data) ───────────────────────────────
          if (state is CropErrorState && state.previousCrops.isEmpty) {
            return _ErrorState(
              message: state.message,
              onRetry: () =>
                  context.read<CropBloc>().add(const LoadCropsEvent()),
            );
          }

          // ── Get crops list ─────────────────────────────────────────
          List<Crop> crops = [];
          bool isOperationLoading = false;

          if (state is CropLoadedState) {
            crops = state.crops;
          } else if (state is CropAddedState) {
            crops = state.crops;
          } else if (state is CropUpdatedState) {
            crops = state.crops;
          } else if (state is CropDeletedState) {
            crops = state.crops;
          } else if (state is CropOperationLoadingState) {
            crops = state.crops;
            isOperationLoading = true;
          } else if (state is CropErrorState) {
            crops = state.previousCrops;
          }

          return RefreshIndicator(
            color: AppColors.primaryGreen,
            onRefresh: () async {
              context.read<CropBloc>().add(const RefreshCropsEvent());
              await Future.delayed(const Duration(milliseconds: 500));
            },
            child: Stack(
              children: [
                ListView.builder(
                  padding: const EdgeInsets.only(
                      top: 12, bottom: 100),
                  itemCount: crops.length,
                  itemBuilder: (context, index) {
                    final crop = crops[index];
                    return CropCard(
                      crop: crop,
                      onTap: () => Navigator.pushNamed(
                        context,
                        RouteNames.cropDetail,
                        arguments: crop,
                      ),
                      onEdit: () => Navigator.pushNamed(
                        context,
                        RouteNames.editCrop,
                        arguments: crop,
                      ),
                      onDelete: () => _confirmDelete(context, crop),
                    );
                  },
                ),

                // Operation loading overlay
                if (isOperationLoading)
                  Container(
                    color: Colors.black.withOpacity(0.1),
                    child: const Center(
                      child: CircularProgressIndicator(
                          color: AppColors.primaryGreen),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ── Empty state widget ────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  final VoidCallback onAddCrop;
  const _EmptyState({required this.onAddCrop});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.primaryGreen.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.grass_outlined,
                size: 60,
                color: AppColors.primaryGreen,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'No Crops Yet',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Start by adding your first crop to track your farm progress.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 28),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: onAddCrop,
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text(
                'Add Your First Crop',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Error state widget ────────────────────────────────────────────────────────
class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.error_outline,
                  size: 50, color: AppColors.error),
            ),
            const SizedBox(height: 20),
            const Text(
              'Something went wrong',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 14, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: onRetry,
              icon: const Icon(Icons.refresh, color: Colors.white),
              label: const Text('Try Again',
                  style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
