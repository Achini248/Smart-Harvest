// lib/features/government_dashboard/presentation/widgets/surplus_shortage_map.dart
// MODIFIED: replaced hardcoded region data with live /api/surplus-status data.
// Reuses CropSurplusShortageWidget for the detail list.

import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/constants/api_constants.dart';
import 'crop_surplus_shortage.dart';

class SurplusShortageMap extends StatelessWidget {
  const SurplusShortageMap({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F5F7),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF4F5F7),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              size: 18, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Surplus & Shortage Map',
          style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 18,
              color: Colors.black87),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Live overview cards ────────────────────────────────────
            _LiveOverviewCards(),
            const SizedBox(height: 24),

            // ── Shortage items ────────────────────────────────────────
            const Text(
              'Shortage Crops',
              style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: Colors.black87),
            ),
            const SizedBox(height: 10),
            const CropSurplusShortageWidget(
              filterStatus: 'shortage',
              showSummary: false,
              showMax: 8,
            ),
            const SizedBox(height: 24),

            // ── Surplus items ─────────────────────────────────────────
            const Text(
              'Surplus Crops',
              style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: Colors.black87),
            ),
            const SizedBox(height: 10),
            const CropSurplusShortageWidget(
              filterStatus: 'surplus',
              showSummary: false,
              showMax: 8,
            ),
            const SizedBox(height: 24),

            // ── All crops ────────────────────────────────────────────
            const Text(
              'All Crops — Supply Status',
              style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: Colors.black87),
            ),
            const SizedBox(height: 10),
            const CropSurplusShortageWidget(
              showSummary: true,
              showMax: 20,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Live overview cards ───────────────────────────────────────────────────────

class _LiveOverviewCards extends StatefulWidget {
  @override
  State<_LiveOverviewCards> createState() => _LiveOverviewCardsState();
}

class _LiveOverviewCardsState extends State<_LiveOverviewCards> {
  bool _loading = true;
  int _surplus = 0;
  int _shortage = 0;
  int _normal = 0;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    try {
      final data = await ApiClient.instance.get(ApiConstants.surplusStatus);
      final summary = data['summary'] as Map<String, dynamic>? ?? {};
      setState(() {
        _surplus  = (summary['total_surplus']  as num? ?? 0).toInt();
        _shortage = (summary['total_shortage'] as num? ?? 0).toInt();
        _normal   = (summary['total_normal']   as num? ?? 0).toInt();
        _loading  = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const SizedBox(
        height: 90,
        child: Center(
          child: CircularProgressIndicator(
              strokeWidth: 2, color: AppColors.primaryGreen),
        ),
      );
    }
    return Row(
      children: [
        Expanded(
            child: _OverviewCard(
                label: 'Surplus',
                count: _surplus,
                color: AppColors.success,
                icon: Icons.trending_up)),
        const SizedBox(width: 10),
        Expanded(
            child: _OverviewCard(
                label: 'Shortage',
                count: _shortage,
                color: AppColors.error,
                icon: Icons.trending_down)),
        const SizedBox(width: 10),
        Expanded(
            child: _OverviewCard(
                label: 'Normal',
                count: _normal,
                color: AppColors.warning,
                icon: Icons.trending_flat)),
      ],
    );
  }
}

class _OverviewCard extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  final IconData icon;

  const _OverviewCard({
    required this.label,
    required this.count,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 6,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 6),
          Text(
            count.toString(),
            style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: color),
          ),
          Text(label,
              style: const TextStyle(
                  fontSize: 11, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}
