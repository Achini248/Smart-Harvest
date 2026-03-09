import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../config/routes/route_names.dart';
import '../bloc/crop_bloc.dart';
import '../bloc/crop_event.dart';
import '../bloc/crop_state.dart';
import '../../domain/entities/crop.dart';

class CropDetailPage extends StatelessWidget {
  final Crop crop;

  const CropDetailPage({super.key, required this.crop});

  @override
  Widget build(BuildContext context) {
    final status = CropStatusExtension.fromString(crop.status);
    final type = CropTypeExtension.fromString(crop.type);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocListener<CropBloc, CropState>(
        listener: (context, state) {
          if (state is CropDeletedState) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Crop deleted.'),
                backgroundColor: AppColors.primaryGreen,
                behavior: SnackBarBehavior.floating,
              ),
            );
            Navigator.pop(context);
          } else if (state is CropErrorState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        child: CustomScrollView(
          slivers: [
            // ── Green header ─────────────────────────────────────────────
            SliverAppBar(
              expandedHeight: 200,
              pinned: true,
              backgroundColor: AppColors.primaryGreen,
              foregroundColor: Colors.white,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                onPressed: () => Navigator.pop(context),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  onPressed: () => Navigator.pushNamed(
                    context,
                    RouteNames.editCrop,
                    arguments: crop,
                  ),
                  tooltip: 'Edit',
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => _confirmDelete(context),
                  tooltip: 'Delete',
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primaryGreen,
                        AppColors.primaryGreenDark
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 60),
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _typeIcon(type),
                          size: 40,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        crop.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      _StatusBadge(status: status),
                    ],
                  ),
                ),
              ),
            ),

            // ── Details ──────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Info cards grid
                    GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      childAspectRatio: 1.5,
                      children: [
                        _DetailCard(
                          icon: Icons.category_outlined,
                          label: 'Type',
                          value: type.label,
                        ),
                        _DetailCard(
                          icon: Icons.straighten,
                          label: 'Quantity',
                          value: '${crop.quantity} ${crop.unit}',
                        ),
                        _DetailCard(
                          icon: Icons.location_on_outlined,
                          label: 'Location',
                          value: crop.location,
                        ),
                        _DetailCard(
                          icon: Icons.calendar_today_outlined,
                          label: 'Planted',
                          value: DateFormat('dd MMM yyyy')
                              .format(crop.plantedDate),
                        ),
                      ],
                    ),

                    if (crop.harvestDate != null) ...[
                      const SizedBox(height: 12),
                      _DetailCard(
                        icon: Icons.event_available_outlined,
                        label: 'Expected Harvest',
                        value: DateFormat('dd MMMM yyyy')
                            .format(crop.harvestDate!),
                        fullWidth: true,
                      ),
                    ],

                    if (crop.notes != null && crop.notes!.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      const Text(
                        'Notes',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: Colors.grey.shade200),
                        ),
                        child: Text(
                          crop.notes!,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                            height: 1.6,
                          ),
                        ),
                      ),
                    ],

                    const SizedBox(height: 16),

                    // Timestamps
                    _TimestampRow(
                      label: 'Added',
                      value: DateFormat('dd MMM yyyy, hh:mm a')
                          .format(crop.createdAt),
                    ),
                    const SizedBox(height: 4),
                    _TimestampRow(
                      label: 'Last updated',
                      value: DateFormat('dd MMM yyyy, hh:mm a')
                          .format(crop.updatedAt),
                    ),

                    const SizedBox(height: 24),

                    // Edit button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryGreen,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                        ),
                        onPressed: () => Navigator.pushNamed(
                          context,
                          RouteNames.editCrop,
                          arguments: crop,
                        ),
                        icon: const Icon(Icons.edit_outlined,
                            color: Colors.white),
                        label: const Text(
                          'Edit Crop',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.error,
                          side:
                              const BorderSide(color: AppColors.error),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () => _confirmDelete(context),
                        icon: const Icon(Icons.delete_outline),
                        label: const Text('Delete Crop',
                            style: TextStyle(
                                fontWeight: FontWeight.w600)),
                      ),
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
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

  IconData _typeIcon(CropType type) {
    switch (type) {
      case CropType.vegetable: return Icons.eco_outlined;
      case CropType.fruit:     return Icons.apple_outlined;
      case CropType.grain:     return Icons.grass;
      case CropType.legume:    return Icons.spa_outlined;
      case CropType.root:      return Icons.park_outlined;
      case CropType.herb:      return Icons.local_florist_outlined;
      case CropType.other:     return Icons.agriculture;
    }
  }
}

// ── Status badge ──────────────────────────────────────────────────────────────
class _StatusBadge extends StatelessWidget {
  final CropStatus status;
  const _StatusBadge({required this.status});

  Color get _color {
    switch (status) {
      case CropStatus.planted:         return Colors.blue;
      case CropStatus.growing:         return AppColors.primaryGreen;
      case CropStatus.readyToHarvest:  return Colors.orange;
      case CropStatus.harvested:       return Colors.purple;
      case CropStatus.failed:          return AppColors.error;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.5)),
      ),
      child: Text(
        status.label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// ── Detail card ───────────────────────────────────────────────────────────────
class _DetailCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool fullWidth;

  const _DetailCard({
    required this.icon,
    required this.label,
    required this.value,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: fullWidth ? double.infinity : null,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: AppColors.primaryGreen),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// ── Timestamp row ─────────────────────────────────────────────────────────────
class _TimestampRow extends StatelessWidget {
  final String label;
  final String value;
  const _TimestampRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          '$label: ',
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
