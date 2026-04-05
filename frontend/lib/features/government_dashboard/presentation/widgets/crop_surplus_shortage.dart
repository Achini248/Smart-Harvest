// lib/features/government_dashboard/presentation/widgets/crop_surplus_shortage.dart
//
// ⚠️  REQUIRED FILE — DO NOT REMOVE (Growise spec §"Surplus / Shortage")
//
// This widget fetches live surplus/shortage data from the Flask backend
// endpoint GET /api/surplus-status, which uses the EXISTING PriceService
// supply/demand logic:
//
//   supply > demand → surplus
//   supply < demand → shortage
//
// It is used both inside GovernmentDashboardPage and as a standalone widget
// anywhere surplus/shortage context is needed.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/constants/api_constants.dart';

// ── State ─────────────────────────────────────────────────────────────────────

class SurplusShortageItem {
  final String crop;
  final String region;
  final String status; // 'surplus' | 'shortage' | 'normal'
  final double totalSupply;
  final double totalDemand;
  final double avgPrice;
  final String market;

  const SurplusShortageItem({
    required this.crop,
    required this.region,
    required this.status,
    required this.totalSupply,
    required this.totalDemand,
    required this.avgPrice,
    required this.market,
  });

  factory SurplusShortageItem.fromJson(Map<String, dynamic> j) =>
      SurplusShortageItem(
        crop:        j['crop']         as String? ?? '',
        region:      j['region']       as String? ?? 'National',
        status:      j['status']       as String? ?? 'normal',
        totalSupply: (j['total_supply'] as num? ?? 0).toDouble(),
        totalDemand: (j['total_demand'] as num? ?? 0).toDouble(),
        avgPrice:    (j['avg_price']   as num? ?? 0).toDouble(),
        market:      j['market']       as String? ?? '',
      );

  bool get isSurplus  => status == 'surplus';
  bool get isShortage => status == 'shortage';

  Color get statusColor {
    if (isSurplus)  return AppColors.success;
    if (isShortage) return AppColors.error;
    return AppColors.warning;
  }

  IconData get statusIcon {
    if (isSurplus)  return Icons.trending_up;
    if (isShortage) return Icons.trending_down;
    return Icons.trending_flat;
  }

  String get statusLabel {
    if (isSurplus)  return 'Surplus';
    if (isShortage) return 'Shortage';
    return 'Normal';
  }

  /// Percentage difference between supply and demand
  double get imbalancePct {
    final base = totalDemand > 0 ? totalDemand : totalSupply;
    if (base == 0) return 0;
    return ((totalSupply - totalDemand) / base * 100).abs();
  }
}

class _SurplusState {
  final bool isLoading;
  final List<SurplusShortageItem> items;
  final int surplusCount;
  final int shortageCount;
  final int normalCount;
  final String? error;

  const _SurplusState({
    this.isLoading = false,
    this.items = const [],
    this.surplusCount = 0,
    this.shortageCount = 0,
    this.normalCount = 0,
    this.error,
  });
}

// ── Widget ────────────────────────────────────────────────────────────────────

/// Displays a live surplus/shortage breakdown fetched from the Flask backend.
///
/// Usage:
///   ```dart
///   const CropSurplusShortageWidget()
///   // or with a filter:
///   const CropSurplusShortageWidget(showMax: 5, filterStatus: 'shortage')
///   ```
class CropSurplusShortageWidget extends StatefulWidget {
  /// Maximum rows to display (0 = all)
  final int showMax;

  /// Optional: 'surplus' | 'shortage' | 'normal' | '' (all)
  final String filterStatus;

  /// Show the summary chip bar at the top
  final bool showSummary;

  const CropSurplusShortageWidget({
    super.key,
    this.showMax = 0,
    this.filterStatus = '',
    this.showSummary = true,
  });

  @override
  State<CropSurplusShortageWidget> createState() =>
      _CropSurplusShortageWidgetState();
}

class _CropSurplusShortageWidgetState
    extends State<CropSurplusShortageWidget> {
  _SurplusState _state = const _SurplusState(isLoading: true);

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _state = const _SurplusState(isLoading: true));
    try {
      final data =
          await ApiClient.instance.get(ApiConstants.surplusStatus);

      final rawItems =
          (data['items'] as List<dynamic>? ?? [])
              .map((e) =>
                  SurplusShortageItem.fromJson(e as Map<String, dynamic>))
              .toList();

      final summary = data['summary'] as Map<String, dynamic>? ?? {};

      // Apply status filter
      final filtered = widget.filterStatus.isEmpty
          ? rawItems
          : rawItems
              .where((i) => i.status == widget.filterStatus)
              .toList();

      // Apply max limit
      final displayed = widget.showMax > 0 && filtered.length > widget.showMax
          ? filtered.sublist(0, widget.showMax)
          : filtered;

      setState(() => _state = _SurplusState(
            isLoading:     false,
            items:         displayed,
            surplusCount:  (summary['total_surplus']  as num? ?? 0).toInt(),
            shortageCount: (summary['total_shortage'] as num? ?? 0).toInt(),
            normalCount:   (summary['total_normal']   as num? ?? 0).toInt(),
          ));
    } catch (e) {
      setState(() => _state =
          _SurplusState(isLoading: false, error: e.toString()));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_state.isLoading) {
      return const SizedBox(
        height: 80,
        child: Center(
          child: CircularProgressIndicator(
              strokeWidth: 2, color: AppColors.primaryGreen),
        ),
      );
    }

    if (_state.error != null) {
      return _ErrorChip(
        message: 'Could not load supply data',
        onRetry: _load,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Summary chips ────────────────────────────────────────────────
        if (widget.showSummary) ...[
          _SummaryRow(
            surplusCount:  _state.surplusCount,
            shortageCount: _state.shortageCount,
            normalCount:   _state.normalCount,
            onRefresh:     _load,
          ),
          const SizedBox(height: 12),
        ],

        // ── Item list ────────────────────────────────────────────────────
        if (_state.items.isEmpty)
          _EmptyState(filterStatus: widget.filterStatus)
        else
          ...(_state.items.map((item) => _SurplusRow(item: item))),
      ],
    );
  }
}

// ── Sub-widgets ───────────────────────────────────────────────────────────────

class _SummaryRow extends StatelessWidget {
  final int surplusCount;
  final int shortageCount;
  final int normalCount;
  final VoidCallback onRefresh;

  const _SummaryRow({
    required this.surplusCount,
    required this.shortageCount,
    required this.normalCount,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _Chip(
          label: '$surplusCount Surplus',
          color: AppColors.success,
          icon: Icons.trending_up,
        ),
        const SizedBox(width: 8),
        _Chip(
          label: '$shortageCount Shortage',
          color: AppColors.error,
          icon: Icons.trending_down,
        ),
        const SizedBox(width: 8),
        _Chip(
          label: '$normalCount Normal',
          color: AppColors.warning,
          icon: Icons.trending_flat,
        ),
        const Spacer(),
        GestureDetector(
          onTap: onRefresh,
          child: const Icon(Icons.refresh,
              size: 18, color: AppColors.textSecondary),
        ),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;

  const _Chip({
    required this.label,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(label,
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: color)),
        ],
      ),
    );
  }
}

class _SurplusRow extends StatelessWidget {
  final SurplusShortageItem item;
  const _SurplusRow({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: item.statusColor.withValues(alpha: 0.2), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Status icon circle
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: item.statusColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(item.statusIcon,
                size: 18, color: item.statusColor),
          ),
          const SizedBox(width: 12),

          // Crop & region
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.crop,
                  style: const TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 13),
                ),
                Text(
                  item.region.isEmpty ? 'National' : item.region,
                  style: const TextStyle(
                      fontSize: 11, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),

          // Status badge + price
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: item.statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  item.statusLabel,
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: item.statusColor),
                ),
              ),
              const SizedBox(height: 4),
              if (item.avgPrice > 0)
                Text(
                  'LKR ${item.avgPrice.toStringAsFixed(0)}/kg',
                  style: const TextStyle(
                      fontSize: 11, color: AppColors.textSecondary),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String filterStatus;
  const _EmptyState({required this.filterStatus});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24),
      alignment: Alignment.center,
      child: Text(
        filterStatus.isEmpty
            ? 'No supply data available today'
            : 'No ${filterStatus} crops found today',
        style: const TextStyle(
            color: AppColors.textSecondary, fontSize: 13),
      ),
    );
  }
}

class _ErrorChip extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorChip({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.error_outline, size: 16, color: AppColors.error),
        const SizedBox(width: 8),
        Expanded(
          child: Text(message,
              style: const TextStyle(
                  color: AppColors.error, fontSize: 12)),
        ),
        TextButton(
          onPressed: onRetry,
          child: const Text('Retry',
              style: TextStyle(
                  color: AppColors.primaryGreen, fontSize: 12)),
        ),
      ],
    );
  }
}
