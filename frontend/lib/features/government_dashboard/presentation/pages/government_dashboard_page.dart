// lib/features/government_dashboard/presentation/pages/government_dashboard_page.dart
// MODIFIED: Added AI price forecasting section + live CropSurplusShortageWidget.
// All existing StatsCards and DashboardBloc wiring preserved unchanged.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/constants/api_constants.dart';
import '../../domain/entities/dashboard_stats.dart';
import '../bloc/dashboard_bloc.dart';
import '../bloc/dashboard_event.dart';
import '../bloc/dashboard_state.dart';
import '../widgets/stats_card.dart';
import '../widgets/surplus_shortage_map.dart';
import '../widgets/crop_surplus_shortage.dart';

class GovernmentDashboardPage extends StatefulWidget {
  const GovernmentDashboardPage({super.key});

  @override
  State<GovernmentDashboardPage> createState() =>
      _GovernmentDashboardPageState();
}

class _GovernmentDashboardPageState extends State<GovernmentDashboardPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardBloc>().add(const LoadDashboardEvent());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F5F7),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF4F5F7),
        elevation: 0,
        title: const Text('Government Dashboard',
            style: TextStyle(fontWeight: FontWeight.w700)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context
                .read<DashboardBloc>()
                .add(const RefreshDashboardEvent()),
          ),
        ],
      ),
      body: BlocConsumer<DashboardBloc, DashboardState>(
        listener: (context, state) {
          if (state is DashboardError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red),
            );
          }
        },
        builder: (context, state) {
          if (state is DashboardLoading) {
            return const Center(
              child: CircularProgressIndicator(
                  color: AppColors.primaryGreen),
            );
          }

          if (state is DashboardError) {
            return _buildError(state.message);
          }

          if (state is DashboardLoaded) {
            return RefreshIndicator(
              onRefresh: () async {
                context
                    .read<DashboardBloc>()
                    .add(const RefreshDashboardEvent());
              },
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Header ──────────────────────────────────────────
                    const Text(
                      'Agriculture Overview',
                      style: TextStyle(
                          fontSize: 26, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Live data from Smart Harvest network',
                      style: TextStyle(
                          fontSize: 13, color: Colors.grey.shade600),
                    ),
                    const SizedBox(height: 20),

                    // ── Stats cards ──────────────────────────────────────
                    Row(children: [
                      Expanded(
                          child: StatsCard(
                              title: 'Farmers',
                              value: state.stats.totalFarmers.toString(),
                              icon: Icons.people_outline)),
                      const SizedBox(width: 16),
                      Expanded(
                          child: StatsCard(
                              title: 'Crops',
                              value: state.stats.totalCrops.toString(),
                              icon: Icons.agriculture_outlined)),
                    ]),
                    const SizedBox(height: 16),
                    Row(children: [
                      Expanded(
                          child: StatsCard(
                              title: 'Orders',
                              value: state.stats.totalOrders.toString(),
                              icon: Icons.shopping_cart_outlined)),
                      const SizedBox(width: 16),
                      Expanded(
                          child: StatsCard(
                              title: 'Revenue',
                              value:
                                  'LKR ${_fmt(state.stats.totalRevenue)}',
                              icon: Icons.attach_money)),
                    ]),
                    const SizedBox(height: 20),

                    // ── Surplus index card ────────────────────────────────
                    _buildSurplusCard(state.stats),
                    const SizedBox(height: 24),

                    // ── AI Price Forecasting ──────────────────────────────
                    const Text(
                      'AI Price Forecast',
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Powered by RandomForest model trained on WFP data',
                      style: TextStyle(
                          fontSize: 12, color: Colors.grey.shade600),
                    ),
                    const SizedBox(height: 12),
                    _AIPriceForecastSection(),
                    const SizedBox(height: 24),

                    // ── Live Surplus/Shortage ────────────────────────────
                    const Text(
                      'Live Supply Status',
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'supply > demand → surplus  |  demand > supply → shortage',
                      style: TextStyle(
                          fontSize: 12, color: Colors.grey.shade600),
                    ),
                    const SizedBox(height: 12),

                    // Uses the REQUIRED crop_surplus_shortage.dart widget
                    const CropSurplusShortageWidget(
                      showMax: 6,
                      showSummary: true,
                    ),
                    const SizedBox(height: 16),

                    // ── Full map button ──────────────────────────────────
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const SurplusShortageMap()),
                        ),
                        icon: const Icon(Icons.map),
                        label: const Text('View Full Surplus / Shortage Map'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryGreen,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // ── Crop distribution ────────────────────────────────
                    if (state.stats.cropDistribution.isNotEmpty) ...[
                      const Text(
                        'Crop Distribution',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 12),
                      _CropDistributionCard(
                          data: state.stats.cropDistribution),
                    ],
                  ],
                ),
              ),
            );
          }

          return const Center(
              child: Text('No dashboard data available'));
        },
      ),
    );
  }

  Widget _buildError(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline,
              size: 64, color: AppColors.error),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(message, textAlign: TextAlign.center),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => context
                .read<DashboardBloc>()
                .add(const LoadDashboardEvent()),
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildSurplusCard(DashboardStats stats) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [
          AppColors.primaryGreen.withValues(alpha: 0.1),
          Colors.transparent
        ]),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: AppColors.primaryGreen.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.analytics_outlined,
              color: AppColors.primaryGreen, size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('National Surplus Index',
                    style: TextStyle(
                        fontSize: 13, color: AppColors.textSecondary)),
                Text(
                  '${stats.nationalSurplusIndex.toStringAsFixed(1)}%',
                  style: const TextStyle(
                      fontSize: 26, fontWeight: FontWeight.bold),
                ),
                Text(
                  '${stats.surplusRegions} Surplus  ·  '
                  '${stats.shortageRegions} Shortage',
                  style: const TextStyle(
                      color: AppColors.primaryGreen, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _fmt(double value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(0)}K';
    }
    return value.toStringAsFixed(0);
  }
}

// ── AI Price Forecast Section ─────────────────────────────────────────────────
// Calls GET /api/prices/forecast which uses the existing RandomForest model.

class _AIPriceForecastSection extends StatefulWidget {
  @override
  State<_AIPriceForecastSection> createState() =>
      _AIPriceForecastSectionState();
}

class _AIPriceForecastSectionState extends State<_AIPriceForecastSection> {
  bool _loading = true;
  List<_ForecastSummary> _items = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final data = await ApiClient.instance.get(
        ApiConstants.forecastList,
        queryParams: {'top': '6'},
      );
      final forecasts = data['forecasts'] as List<dynamic>? ?? [];
      setState(() {
        _items = forecasts
            .map((e) => _ForecastSummary.fromJson(e as Map<String, dynamic>))
            .where((f) => f.cropName.isNotEmpty)
            .toList();
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const SizedBox(
        height: 80,
        child: Center(
            child: CircularProgressIndicator(
                strokeWidth: 2, color: AppColors.primaryGreen)),
      );
    }

    if (_error != null || _items.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(Icons.info_outline,
                size: 16, color: AppColors.textSecondary),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                'AI forecast unavailable — insufficient historical data.',
                style: TextStyle(
                    fontSize: 12, color: AppColors.textSecondary),
              ),
            ),
            TextButton(
              onPressed: _load,
              child: const Text('Retry',
                  style: TextStyle(
                      color: AppColors.primaryGreen, fontSize: 12)),
            ),
          ],
        ),
      );
    }

    return Column(
      children: _items.map((f) => _ForecastRow(forecast: f)).toList(),
    );
  }
}

class _ForecastSummary {
  final String cropName;
  final double? currentPrice;
  final double? predictedPrice;
  final double percentageChange;

  const _ForecastSummary({
    required this.cropName,
    this.currentPrice,
    this.predictedPrice,
    required this.percentageChange,
  });

  factory _ForecastSummary.fromJson(Map<String, dynamic> j) =>
      _ForecastSummary(
        cropName:         j['crop_name']       as String? ?? '',
        currentPrice:     (j['current_price']  as num?)?.toDouble(),
        predictedPrice:   (j['predicted_price'] as num?)?.toDouble(),
        percentageChange: (j['percentage_change'] as num? ?? 0).toDouble(),
      );

  bool get isRising => percentageChange >= 0;
}

class _ForecastRow extends StatelessWidget {
  final _ForecastSummary forecast;
  const _ForecastRow({required this.forecast});

  @override
  Widget build(BuildContext context) {
    final isRising = forecast.isRising;
    final color    = isRising ? AppColors.success : AppColors.error;
    final arrow    = isRising ? Icons.arrow_upward : Icons.arrow_downward;
    final pct      = forecast.percentageChange.abs();

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
      child: Row(
        children: [
          // AI badge
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: AppColors.primaryGreen.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.psychology_outlined,
                size: 18, color: AppColors.primaryGreen),
          ),
          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(forecast.cropName,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 13)),
                if (forecast.currentPrice != null)
                  Text(
                    'Current: LKR ${forecast.currentPrice!.toStringAsFixed(0)}/kg',
                    style: const TextStyle(
                        fontSize: 11, color: AppColors.textSecondary),
                  ),
              ],
            ),
          ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (forecast.predictedPrice != null)
                Text(
                  'LKR ${forecast.predictedPrice!.toStringAsFixed(0)}',
                  style: const TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 13),
                ),
              Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(arrow, size: 12, color: color),
                Text(
                  '${pct.toStringAsFixed(1)}% (7d)',
                  style: TextStyle(fontSize: 11, color: color),
                ),
              ]),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Crop Distribution Card ────────────────────────────────────────────────────

class _CropDistributionCard extends StatelessWidget {
  final Map<String, dynamic> data;
  const _CropDistributionCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final sorted = data.entries.toList()
      ..sort((a, b) =>
          (b.value as num).compareTo(a.value as num));
    final total =
        sorted.fold<num>(0, (sum, e) => sum + (e.value as num));

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 3))
        ],
      ),
      child: Column(
        children: sorted.take(6).map((e) {
          final pct = total > 0
              ? (e.value as num) / total
              : 0.0;
          return _DistRow(
              label: e.key,
              count: (e.value as num).toInt(),
              pct: pct.toDouble());
        }).toList(),
      ),
    );
  }
}

class _DistRow extends StatelessWidget {
  final String label;
  final int count;
  final double pct;
  const _DistRow(
      {required this.label, required this.count, required this.pct});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 13)),
              Text('$count  (${(pct * 100).toStringAsFixed(0)}%)',
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.textSecondary)),
            ],
          ),
          const SizedBox(height: 5),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: pct.clamp(0.0, 1.0),
              minHeight: 7,
              backgroundColor: Colors.grey.shade200,
              valueColor: const AlwaysStoppedAnimation<Color>(
                  AppColors.primaryGreen),
            ),
          ),
        ],
      ),
    );
  }
}
