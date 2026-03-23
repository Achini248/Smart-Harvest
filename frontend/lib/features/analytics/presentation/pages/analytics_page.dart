// lib/features/analytics/presentation/pages/analytics_page.dart
// MODIFIED: uses DI-injected AnalyticsBloc (real API) instead of inline instances.
// All UI code preserved. Removed Random() simulation.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../config/dependency_injection/injection_container.dart';
import '../bloc/analytics_bloc.dart';
import '../bloc/analytics_event.dart';
import '../bloc/analytics_state.dart';
import '../widgets/chart_widget.dart';

class AnalyticsPage extends StatelessWidget {
  const AnalyticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<AnalyticsBloc>()..add(const LoadAnalyticsEvent()),
      child: const _AnalyticsView(),
    );
  }
}

class _AnalyticsView extends StatelessWidget {
  const _AnalyticsView();

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
        centerTitle: true,
        title: const Text(
          'Analytics',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 18,
            color: Colors.black87,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black54),
            onPressed: () =>
                context.read<AnalyticsBloc>().add(const LoadAnalyticsEvent()),
          ),
        ],
      ),
      body: BlocBuilder<AnalyticsBloc, AnalyticsState>(
        builder: (context, state) {
          if (state.isLoading && state.analytics == null) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF7BA53D)),
            );
          }

          if (state.errorMessage != null && state.analytics == null) {
            return _ErrorView(
              message: state.errorMessage!,
              onRetry: () => context
                  .read<AnalyticsBloc>()
                  .add(const LoadAnalyticsEvent()),
            );
          }

          final analytics = state.analytics;
          if (analytics == null) {
            return const _ErrorView(message: 'Analytics not available.');
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Summary cards ──────────────────────────────────────
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isWide = constraints.maxWidth >= 600;
                    return GridView.count(
                      crossAxisCount: isWide ? 3 : 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      childAspectRatio: 1.5,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      children: [
                        _StatCard(
                          title: 'Total Crops',
                          value: analytics.totalCrops.toString(),
                          icon: Icons.agriculture_outlined,
                          color: const Color(0xFF7BA53D),
                        ),
                        _StatCard(
                          title: 'Total Orders',
                          value: analytics.totalOrders.toString(),
                          icon: Icons.receipt_long_outlined,
                          color: const Color(0xFF2196F3),
                        ),
                        _StatCard(
                          title: 'Total Revenue',
                          value:
                              'Rs. ${analytics.totalRevenue.toStringAsFixed(0)}',
                          icon: Icons.attach_money_outlined,
                          color: const Color(0xFFFFA726),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 24),

                // ── Crop distribution chart ────────────────────────────
                if (analytics.cropDistribution.isNotEmpty) ...[
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Crop Distribution',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: Colors.grey.shade900,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: ChartWidget(
                      data: analytics.cropDistribution,
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                // ── Raw breakdown ─────────────────────────────────────
                if (analytics.cropDistribution.isNotEmpty) ...[
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'By Crop',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: Colors.grey.shade900,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  ...analytics.cropDistribution.entries
                      .toList()
                    ..sort((a, b) => b.value.compareTo(a.value))
                    ..take(10).map((e) => _CropRow(
                          name: e.key,
                          quantity: e.value,
                          maxQty: analytics.cropDistribution.values
                              .reduce((a, b) => a > b ? a : b),
                        )),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

// ── Sub-widgets ───────────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 10),
            Text(title,
                style: TextStyle(
                    fontSize: 12, color: Colors.grey.shade600)),
            const SizedBox(height: 4),
            Text(value,
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w800)),
          ],
        ),
      ),
    );
  }
}

class _CropRow extends StatelessWidget {
  final String name;
  final double quantity;
  final double maxQty;

  const _CropRow({
    required this.name,
    required this.quantity,
    required this.maxQty,
  });

  @override
  Widget build(BuildContext context) {
    final pct = maxQty > 0 ? quantity / maxQty : 0.0;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 4,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(name,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 13)),
              Text('${quantity.toStringAsFixed(0)} kg',
                  style: const TextStyle(
                      fontSize: 12, color: Colors.grey)),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: pct.clamp(0.0, 1.0),
              minHeight: 6,
              backgroundColor: Colors.grey.shade200,
              valueColor: const AlwaysStoppedAnimation<Color>(
                  Color(0xFF7BA53D)),
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  const _ErrorView({required this.message, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline,
                size: 48, color: Colors.redAccent),
            const SizedBox(height: 12),
            Text(message,
                textAlign: TextAlign.center,
                style:
                    const TextStyle(color: Colors.grey, fontSize: 14)),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7BA53D),
                    foregroundColor: Colors.white),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
