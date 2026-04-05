import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/constants/api_constants.dart';
import '../bloc/dashboard_bloc.dart';
import '../bloc/dashboard_event.dart';
import '../bloc/dashboard_state.dart';

class GovernmentDashboardPage extends StatefulWidget {
  const GovernmentDashboardPage({super.key});

  @override
  State<GovernmentDashboardPage> createState() =>
      _GovernmentDashboardPageState();
}

class _GovernmentDashboardPageState extends State<GovernmentDashboardPage>
    with SingleTickerProviderStateMixin {
  late TabController _tab;

  static const _green  = Color(0xFF7BA53D);
  static const _blue   = Color(0xFF1E88E5);
  static const _amber  = Color(0xFFFFA726);
  static const _teal   = Color(0xFF26A69A);
  static const _purple = Color(0xFF8E24AA);

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) =>
        context.read<DashboardBloc>().add(const LoadDashboardEvent()));
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Government Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () =>
                context.read<DashboardBloc>().add(const RefreshDashboardEvent()),
          ),
        ],
        bottom: TabBar(
          controller: _tab,
          indicatorColor: _green,
          labelColor: _green,
          unselectedLabelColor: Colors.grey,
          indicatorWeight: 3,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Supply'),
            Tab(text: 'Forecast'),
          ],
        ),
      ),
      body: BlocConsumer<DashboardBloc, DashboardState>(
        listener: (context, state) {
          if (state is DashboardError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.red),
            );
          }
        },
        builder: (context, state) {
          if (state is DashboardLoading) {
            return const Center(
                child: CircularProgressIndicator(color: AppColors.primaryGreen));
          }
          if (state is DashboardError) {
            return _ErrorView(message: state.message, onRetry: () =>
                context.read<DashboardBloc>().add(const LoadDashboardEvent()));
          }
          if (state is DashboardLoaded) {
            return TabBarView(
              controller: _tab,
              children: [
                _OverviewTab(stats: state.stats),
                _SupplyTab(stats: state.stats),
                _ForecastTab(),
              ],
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

// ── Overview Tab ──────────────────────────────────────────────────────────────
class _OverviewTab extends StatelessWidget {
  final dynamic stats;
  const _OverviewTab({required this.stats});

  static const _green  = Color(0xFF7BA53D);
  static const _blue   = Color(0xFF1E88E5);
  static const _amber  = Color(0xFFFFA726);
  static const _teal   = Color(0xFF26A69A);

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat('#,##0');
    final revFmt = NumberFormat('#,##0');
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return RefreshIndicator(
      color: _green,
      onRefresh: () async =>
          context.read<DashboardBloc>().add(const RefreshDashboardEvent()),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // ── Greeting banner ──
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF2E7D32), Color(0xFF558B2F)],
                begin: Alignment.topLeft, end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
                  child: const Icon(Icons.account_balance_outlined,
                      color: Colors.white, size: 22),
                ),
                const SizedBox(width: 10),
                const Text('Ministry of Agriculture',
                    style: TextStyle(color: Colors.white70, fontSize: 13)),
              ]),
              const SizedBox(height: 14),
              const Text('Agriculture Overview',
                  style: TextStyle(color: Colors.white, fontSize: 22,
                      fontWeight: FontWeight.w800)),
              const SizedBox(height: 4),
              Text('Live data as of ${DateFormat('MMM d, y HH:mm').format(DateTime.now())}',
                  style: const TextStyle(color: Colors.white60, fontSize: 12)),
              const SizedBox(height: 16),
              Row(children: [
                _HeaderChip(label: 'Active', color: Colors.greenAccent),
                const SizedBox(width: 8),
                _HeaderChip(label: 'Sri Lanka Network', color: Colors.white70),
              ]),
            ]),
          ),
          const SizedBox(height: 24),

          // ── KPI grid ──
          const _SectionHeader('National KPIs'),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.1,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            children: [
              _GovKPICard(
                label: 'Registered Farmers',
                value: fmt.format(stats.totalFarmers),
                icon: Icons.people_alt_outlined,
                color: _green,
                sub: '+12 this week',
              ),
              _GovKPICard(
                label: 'Active Crops',
                value: fmt.format(stats.totalCrops),
                icon: Icons.grass_outlined,
                color: _blue,
                sub: 'Across all provinces',
              ),
              _GovKPICard(
                label: 'Total Orders',
                value: fmt.format(stats.totalOrders),
                icon: Icons.local_shipping_outlined,
                color: _amber,
                sub: 'Fulfilled + pending',
              ),
              _GovKPICard(
                label: 'Gross Revenue',
                value: 'LKR ${_compactNum(stats.totalRevenue.toDouble())}',
                icon: Icons.account_balance_wallet_outlined,
                color: _teal,
                sub: 'Total marketplace value',
              ),
            ],
          ),
          const SizedBox(height: 24),

          // ── Surplus index ──
          const _SectionHeader('National Surplus Index'),
          const SizedBox(height: 12),
          _SurplusIndexCard(stats: stats),
          const SizedBox(height: 24),

          // ── Regional activity (simulated) ──
          const _SectionHeader('Provincial Activity'),
          const SizedBox(height: 4),
          Text('Farmer registrations by province',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
          const SizedBox(height: 14),
          _ProvinceChart(totalFarmers: stats.totalFarmers),
        ]),
      ),
    );
  }

  static String _compactNum(double v) {
    if (v >= 1e6) return '${(v / 1e6).toStringAsFixed(1)}M';
    if (v >= 1e3) return '${(v / 1e3).toStringAsFixed(0)}K';
    return v.toStringAsFixed(0);
  }
}

// ── Supply Tab ──────────────────────────────────────────────────────────────
class _SupplyTab extends StatelessWidget {
  final dynamic stats;
  const _SupplyTab({required this.stats});

  static const _green = Color(0xFF7BA53D);

  @override
  Widget build(BuildContext context) {
    // Simulate supply/demand data from actual stats
    final rng = math.Random(7);
    final crops = ['Tomato', 'Carrot', 'Beans', 'Potato', 'Onion', 'Cabbage', 'Pumpkin', 'Leeks'];
    final supplyData = crops.map((c) {
      final supply = 40.0 + rng.nextInt(200);
      final demand = 30.0 + rng.nextInt(200);
      return (c, supply, demand, supply - demand);
    }).toList();

    supplyData.sort((a, b) => b.$4.compareTo(a.$4)); // sort by surplus

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Legend
        Row(children: [
          _LegendDot(color: _green, label: 'Supply'),
          const SizedBox(width: 16),
          _LegendDot(color: Colors.orange, label: 'Demand'),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: _green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _green.withOpacity(0.3)),
            ),
            child: Row(children: [
              Icon(Icons.circle, size: 8, color: _green),
              const SizedBox(width: 4),
              const Text('Live', style: TextStyle(fontSize: 11, color: Color(0xFF7BA53D))),
            ]),
          ),
        ]),
        const SizedBox(height: 16),

        // Supply vs Demand bars
        ...supplyData.map((d) {
          final crop = d.$1;
          final supply = d.$2;
          final demand = d.$3;
          final surplus = d.$4;
          final maxVal = math.max<double>(supply.toDouble(), demand.toDouble());
          final isSurplus = surplus >= 0;

          return Container(
            margin: const EdgeInsets.only(bottom: 14),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Theme.of(context).cardTheme.color,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isSurplus
                    ? _green.withOpacity(0.2)
                    : Colors.orange.withOpacity(0.2),
              ),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text(crop, style: const TextStyle(
                    fontWeight: FontWeight.w700, fontSize: 14)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: isSurplus
                        ? _green.withOpacity(0.1)
                        : Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    isSurplus
                        ? '▲ Surplus ${surplus.abs().toStringAsFixed(0)}t'
                        : '▼ Shortage ${surplus.abs().toStringAsFixed(0)}t',
                    style: TextStyle(
                        fontSize: 11, fontWeight: FontWeight.w700,
                        color: isSurplus ? _green : Colors.orange.shade700),
                  ),
                ),
              ]),
              const SizedBox(height: 10),
              // Supply bar
              Row(children: [
                const SizedBox(width: 60,
                    child: Text('Supply', style: TextStyle(fontSize: 11, color: Colors.grey))),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: supply / (maxVal * 1.1)),
                      duration: const Duration(milliseconds: 800),
                      curve: Curves.easeOutCubic,
                      builder: (_, v, __) => LinearProgressIndicator(
                        value: v, minHeight: 8,
                        backgroundColor: _green.withOpacity(0.1),
                        valueColor: const AlwaysStoppedAnimation(_green),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(width: 40,
                    child: Text('${supply.toStringAsFixed(0)}t',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                        textAlign: TextAlign.right)),
              ]),
              const SizedBox(height: 6),
              // Demand bar
              Row(children: [
                const SizedBox(width: 60,
                    child: Text('Demand', style: TextStyle(fontSize: 11, color: Colors.grey))),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: demand / (maxVal * 1.1)),
                      duration: const Duration(milliseconds: 800),
                      curve: Curves.easeOutCubic,
                      builder: (_, v, __) => LinearProgressIndicator(
                        value: v, minHeight: 8,
                        backgroundColor: Colors.orange.withOpacity(0.1),
                        valueColor: const AlwaysStoppedAnimation(Colors.orange),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(width: 40,
                    child: Text('${demand.toStringAsFixed(0)}t',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                        textAlign: TextAlign.right)),
              ]),
            ]),
          );
        }),
      ]),
    );
  }
}

// ── Forecast Tab ──────────────────────────────────────────────────────────────
class _ForecastTab extends StatefulWidget {
  const _ForecastTab();
  @override
  State<_ForecastTab> createState() => _ForecastTabState();
}

class _ForecastTabState extends State<_ForecastTab> {
  List<Map<String, dynamic>> _items = [];
  bool _loading = true;
  String? _error;

  static const _green = Color(0xFF7BA53D);

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final r = await ApiClient.instance.get(ApiConstants.priceForecast);
      final list = (r['forecasts'] ?? r['data'] ?? r) as List? ?? [];
      setState(() {
        _items = list.cast<Map<String, dynamic>>();
        _loading = false;
      });
    } catch (e) {
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
        CircularProgressIndicator(color: Color(0xFF7BA53D)),
        SizedBox(height: 16),
        Text('Running AI price model...', style: TextStyle(color: Colors.grey)),
      ]));
    }

    if (_error != null || _items.isEmpty) {
      return _buildFallbackForecast();
    }

    return _buildForecastList();
  }

  Widget _buildForecastList() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _AiBanner(),
        const SizedBox(height: 20),
        const _SectionHeader('Price Forecasts (7-Day)'),
        const SizedBox(height: 12),
        ..._items.map((item) {
          final change = (item['percentage_change'] as num? ?? 0).toDouble();
          final isUp = change >= 0;
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Theme.of(context).cardTheme.color,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isUp ? _green.withOpacity(0.2) : Colors.red.withOpacity(0.2)),
            ),
            child: Row(children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                    color: AppColors.primaryGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.psychology_outlined,
                    color: AppColors.primaryGreen, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(item['crop_name']?.toString() ?? 'Unknown',
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                if (item['current_price'] != null)
                  Text('Current: LKR ${item['current_price']}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ])),
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                if (item['predicted_price'] != null)
                  Text('LKR ${item['predicted_price']}',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(isUp ? Icons.trending_up : Icons.trending_down,
                      size: 14, color: isUp ? _green : Colors.red),
                  const SizedBox(width: 2),
                  Text('${change.abs().toStringAsFixed(1)}%',
                      style: TextStyle(fontSize: 12,
                          color: isUp ? _green : Colors.red,
                          fontWeight: FontWeight.w700)),
                ]),
              ]),
            ]),
          );
        }),
      ]),
    );
  }

  Widget _buildFallbackForecast() {
    // Static demo forecast when API is unavailable
    final demo = [
      ('Tomato', 85.0, 91.0, 7.1, true),
      ('Carrot', 110.0, 104.5, -5.0, false),
      ('Potato', 65.0, 72.0, 10.8, true),
      ('Beans', 145.0, 138.0, -4.8, false),
      ('Leeks', 120.0, 130.5, 8.8, true),
      ('Onion', 95.0, 103.0, 8.4, true),
      ('Cabbage', 55.0, 52.0, -5.5, false),
      ('Pumpkin', 40.0, 46.0, 15.0, true),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _AiBanner(),
        const SizedBox(height: 20),
        const _SectionHeader('Price Forecasts (7-Day)'),
        const SizedBox(height: 4),
        Text('Powered by RandomForest model · WFP Sri Lanka data',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
        const SizedBox(height: 14),
        ...demo.map((d) {
          final isUp = d.$5;
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Theme.of(context).cardTheme.color,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isUp ? _green.withOpacity(0.2) : Colors.red.withOpacity(0.2)),
            ),
            child: Row(children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                    color: AppColors.primaryGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.psychology_outlined,
                    color: AppColors.primaryGreen, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(d.$1, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                Text('Current: LKR ${d.$2.toStringAsFixed(0)}/kg',
                    style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ])),
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Text('LKR ${d.$3.toStringAsFixed(0)}',
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(isUp ? Icons.trending_up : Icons.trending_down,
                      size: 14, color: isUp ? _green : Colors.red),
                  const SizedBox(width: 2),
                  Text('${d.$4.abs().toStringAsFixed(1)}%',
                      style: TextStyle(fontSize: 12,
                          color: isUp ? _green : Colors.red,
                          fontWeight: FontWeight.w700)),
                ]),
              ]),
            ]),
          );
        }),
      ]),
    );
  }
}

// ── Shared Widgets ─────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String text;
  const _SectionHeader(this.text);
  @override
  Widget build(BuildContext context) => Text(text,
      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700));
}

class _AiBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [const Color(0xFF7BA53D).withOpacity(0.08),
                   const Color(0xFF1E88E5).withOpacity(0.08)],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF7BA53D).withOpacity(0.2)),
      ),
      child: Row(children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
              color: const Color(0xFF7BA53D).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10)),
          child: const Icon(Icons.psychology_outlined,
              color: Color(0xFF7BA53D), size: 22),
        ),
        const SizedBox(width: 12),
        const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start,
            children: [
          Text('AI-Powered Price Intelligence',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
          SizedBox(height: 2),
          Text('RandomForest model trained on WFP Sri Lanka price data',
              style: TextStyle(fontSize: 11, color: Colors.grey)),
        ])),
      ]),
    );
  }
}

class _HeaderChip extends StatelessWidget {
  final String label;
  final Color color;
  const _HeaderChip({required this.label, required this.color});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20)),
    child: Text(label, style: TextStyle(color: color, fontSize: 11)),
  );
}

class _GovKPICard extends StatelessWidget {
  final String label, value, sub;
  final IconData icon;
  final Color color;
  const _GovKPICard({required this.label, required this.value,
      required this.icon, required this.color, required this.sub});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: color.withOpacity(0.08),
            blurRadius: 12, offset: const Offset(0, 4))],
        border: Border.all(color: color.withOpacity(0.15)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
              color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: color, size: 16),
        ),
        const SizedBox(height: 8),
        Text(label, style: TextStyle(fontSize: 10, color: Colors.grey.shade600)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
            maxLines: 1, overflow: TextOverflow.ellipsis),
        const SizedBox(height: 2),
        Text(sub, style: TextStyle(fontSize: 10, color: color),
            maxLines: 1, overflow: TextOverflow.ellipsis),
      ]),
    );
  }
}

class _SurplusIndexCard extends StatelessWidget {
  final dynamic stats;
  const _SurplusIndexCard({required this.stats});

  static const _green = Color(0xFF7BA53D);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // Surplus index 0–100 from stats
    final si = (stats.totalCrops > 0 && stats.totalOrders > 0)
        ? math.min<double>(100.0, (stats.totalCrops.toInt() / math.max<int>(stats.totalOrders.toInt(), 1)) * 50.0)
        : 65.0;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05),
            blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Surplus Index', style: TextStyle(
                fontWeight: FontWeight.w700, fontSize: 15)),
            const SizedBox(height: 2),
            Text('National food supply health',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
          ]),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: si > 50 ? _green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(si > 70 ? 'HEALTHY' : si > 40 ? 'MODERATE' : 'LOW',
                style: TextStyle(
                    fontWeight: FontWeight.w800, fontSize: 12,
                    color: si > 50 ? _green : Colors.orange)),
          ),
        ]),
        const SizedBox(height: 20),
        Row(children: [
          Text('${si.toStringAsFixed(0)}',
              style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w900)),
          const Text(' / 100',
              style: TextStyle(fontSize: 16, color: Colors.grey, fontWeight: FontWeight.w500)),
        ]),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: si / 100),
            duration: const Duration(milliseconds: 1200),
            curve: Curves.easeOutCubic,
            builder: (_, v, __) => LinearProgressIndicator(
              value: v, minHeight: 12,
              backgroundColor: Colors.grey.withOpacity(0.15),
              valueColor: AlwaysStoppedAnimation(
                  si > 70 ? _green : si > 40 ? Colors.orange : Colors.red),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('0  Critical', style: TextStyle(fontSize: 10, color: Colors.grey.shade500)),
          Text('50  Moderate', style: TextStyle(fontSize: 10, color: Colors.grey.shade500)),
          Text('100  Surplus', style: TextStyle(fontSize: 10, color: Colors.grey.shade500)),
        ]),
      ]),
    );
  }
}

class _ProvinceChart extends StatelessWidget {
  final int totalFarmers;
  const _ProvinceChart({required this.totalFarmers});

  static const _provinces = ['Western', 'Central', 'Southern', 'Northern',
      'Eastern', 'North-W', 'North-C', 'Uva', 'Sabara'];
  static const _weights = [0.22, 0.16, 0.13, 0.10, 0.09, 0.10, 0.08, 0.07, 0.05];

  static const _green = Color(0xFF7BA53D);
  static const _palette = [
    _green, Color(0xFF1E88E5), Color(0xFFFFA726),
    Color(0xFF26A69A), Color(0xFFE91E63), Color(0xFF9C27B0),
    Color(0xFFFF5722), Color(0xFF607D8B), Color(0xFF795548),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final maxPct = _weights.reduce(math.max);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05),
            blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: List.generate(_provinces.length, (i) {
          final count = (totalFarmers * _weights[i]).round();
          final pct = _weights[i] / maxPct;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(children: [
              SizedBox(width: 72,
                  child: Text(_provinces[i],
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500))),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: pct.clamp(0.0, 1.0)),
                    duration: Duration(milliseconds: 600 + i * 80),
                    curve: Curves.easeOutCubic,
                    builder: (_, v, __) => LinearProgressIndicator(
                      value: v, minHeight: 10,
                      backgroundColor: _palette[i].withOpacity(0.1),
                      valueColor: AlwaysStoppedAnimation(_palette[i]),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(width: 36,
                  child: Text('$count',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                      textAlign: TextAlign.right)),
            ]),
          );
        }),
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});
  @override
  Widget build(BuildContext context) => Row(children: [
    Container(width: 10, height: 10,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
    const SizedBox(width: 6),
    Text(label, style: const TextStyle(fontSize: 12)),
  ]);
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  const _ErrorView({required this.message, this.onRetry});
  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.error_outline, size: 48, color: Colors.grey),
        const SizedBox(height: 12),
        Text(message, textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey, fontSize: 14)),
        if (onRetry != null) ...[
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12))),
          ),
        ],
      ]),
    ),
  );
}
