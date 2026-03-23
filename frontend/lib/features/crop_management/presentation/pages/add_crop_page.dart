// lib/features/crop_management/presentation/pages/add_crop_page.dart
// FIX: Added existingCrop param for edit mode; graceful error dialogs
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/crop.dart';
import '../bloc/crop_bloc.dart';
import '../bloc/crop_event.dart';
import '../bloc/crop_state.dart';
import '../widgets/crop_form.dart';

class AddCropPage extends StatelessWidget {
  final Crop? existingCrop;
  const AddCropPage({super.key, this.existingCrop});
  bool get _isEdit => existingCrop != null;

  @override
  Widget build(BuildContext context) {
    final ownerId = existingCrop?.ownerId ?? FirebaseAuth.instance.currentUser?.uid ?? '';
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(_isEdit ? 'Edit Crop' : 'Add New Crop',
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 20)),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 20),
            onPressed: () => Navigator.pop(context)),
      ),
      body: BlocConsumer<CropBloc, CropState>(
        listener: (context, state) {
          if (state is CropAddedState) {
            _snack(context, '${state.addedCrop.name} added successfully!', false);
            Navigator.pop(context);
          } else if (state is CropUpdatedState) {
            _snack(context, '${state.updatedCrop.name} updated!', false);
            Navigator.pop(context);
          } else if (state is CropErrorState) {
            _errorDialog(context, state.message);
          }
        },
        builder: (context, state) {
          final isLoading = state is CropOperationLoadingState;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primaryGreen.withOpacity(0.2)),
                ),
                child: Row(children: [
                  const Icon(Icons.info_outline, color: AppColors.primaryGreen, size: 18),
                  const SizedBox(width: 10),
                  Expanded(child: Text(
                    _isEdit ? 'Update the crop details below.' : 'Fill in the details below to add a new crop.',
                    style: const TextStyle(fontSize: 13, color: AppColors.primaryGreen))),
                ]),
              ),
              const SizedBox(height: 24),
              CropForm(
                ownerId: ownerId,
                initialCrop: existingCrop,
                isLoading: isLoading,
                onSubmit: (crop) {
                  if (_isEdit) {
                    context.read<CropBloc>().add(UpdateCropEvent(crop: crop));
                  } else {
                    context.read<CropBloc>().add(AddCropEvent(crop: crop));
                  }
                },
              ),
              const SizedBox(height: 24),
            ]),
          );
        },
      ),
    );
  }

  void _snack(BuildContext ctx, String msg, bool isError) {
    ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: isError ? AppColors.error : AppColors.primaryGreen,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }

  void _errorDialog(BuildContext ctx, String msg) {
    showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(children: [
          Icon(Icons.error_outline, color: Colors.red), SizedBox(width: 8), Text('Error'),
        ]),
        content: Text(msg),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('OK'))],
      ),
    );
  }
}
