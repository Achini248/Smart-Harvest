// lib/features/crop_management/presentation/pages/crops_list_page.dart
// FIX: Firestore index error → graceful dialog instead of red screen
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<CropBloc>().add(const LoadCropsEvent());
    });
  }

  void _confirmDelete(BuildContext context, Crop crop) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Crop'),
        content: Text('Delete "${crop.name}"? This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            onPressed: () {
              Navigator.pop(context);
              context.read<CropBloc>().add(DeleteCropEvent(cropId: crop.id));
            },
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(BuildContext context, String message) {
    final isIndex = message.toLowerCase().contains('index') || message.toLowerCase().contains('failed_precondition');
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(children: [
          Icon(isIndex ? Icons.build_outlined : Icons.error_outline,
              color: isIndex ? Colors.orange : Colors.red),
          const SizedBox(width: 8),
          Expanded(child: Text(isIndex ? 'Database setup needed' : 'Error',
              style: const TextStyle(fontSize: 16))),
        ]),
        content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(isIndex
              ? 'The database needs a one-time index. Takes ~1 minute to set up in Firebase Console.'
              : message, style: const TextStyle(fontSize: 14)),
          if (isIndex) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.shade200)),
              child: const Text(
                'Firebase Console → Firestore → Indexes\nCollection: crops\nFields: ownerId ASC, createdAt DESC',
                style: TextStyle(fontSize: 11)),
            ),
          ],
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Dismiss')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryGreen),
            onPressed: () {
              Navigator.pop(context);
              context.read<CropBloc>().add(const LoadCropsEvent());
            },
            child: const Text('Try Again', style: TextStyle(color: Colors.white)),
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
        title: const Text('My Crops', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 20)),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_outlined),
            onPressed: () => context.read<CropBloc>().add(const RefreshCropsEvent()),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, RouteNames.addCrop),
        backgroundColor: AppColors.primaryGreen,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add Crop', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
      body: BlocConsumer<CropBloc, CropState>(
        listener: (context, state) {
          if (state is CropAddedState) _snack(context, '${state.addedCrop.name} added!', false);
          else if (state is CropUpdatedState) _snack(context, '${state.updatedCrop.name} updated!', false);
          else if (state is CropDeletedState) _snack(context, 'Crop deleted.', false);
          else if (state is CropErrorState) {
            WidgetsBinding.instance.addPostFrameCallback((_) => _showErrorDialog(context, state.message));
          }
        },
        builder: (context, state) {
          if (state is CropLoadingState) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primaryGreen));
          }
          if (state is CropEmptyState) return _buildEmpty(context);
          final crops = switch (state) {
            CropLoadedState s => s.crops,
            CropOperationLoadingState s => s.crops,
            CropAddedState s => s.crops,
            CropUpdatedState s => s.crops,
            CropDeletedState s => s.crops,
            _ => <Crop>[],
          };
          if (crops.isEmpty && state is! CropLoadingState) return _buildEmpty(context);
          return Stack(children: [
            ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
              itemCount: crops.length,
              itemBuilder: (context, i) {
                final crop = crops[i];
                return CropCard(
                  crop: crop,
                  onTap: () => Navigator.pushNamed(context, RouteNames.cropDetail, arguments: crop),
                  onEdit: () => Navigator.pushNamed(context, RouteNames.editCrop, arguments: crop),
                  onDelete: () => _confirmDelete(context, crop),
                );
              },
            ),
            if (state is CropOperationLoadingState)
              const Positioned.fill(child: ColoredBox(color: Color(0x33000000),
                  child: Center(child: CircularProgressIndicator(color: AppColors.primaryGreen)))),
          ]);
        },
      ),
    );
  }

  Widget _buildEmpty(BuildContext context) => Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 100, height: 100,
              decoration: BoxDecoration(color: AppColors.primaryGreen.withOpacity(0.1), shape: BoxShape.circle),
              child: const Icon(Icons.agriculture_outlined, size: 50, color: AppColors.primaryGreen)),
          const SizedBox(height: 16),
          const Text('No Crops Yet', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          const Text('Tap "+ Add Crop" to get started.', style: TextStyle(color: AppColors.textSecondary)),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryGreen,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12)),
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text('Add Crop', style: TextStyle(color: Colors.white)),
            onPressed: () => Navigator.pushNamed(context, RouteNames.addCrop),
          ),
        ]),
      );

  void _snack(BuildContext ctx, String msg, bool isError) {
    ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: isError ? AppColors.error : AppColors.primaryGreen,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }
}
