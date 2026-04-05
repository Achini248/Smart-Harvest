import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../config/dependency_injection/injection_container.dart';
import '../bloc/analytics_bloc.dart';
import '../bloc/analytics_event.dart';
import '../bloc/analytics_state.dart';

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

class _AnalyticsView extends StatefulWidget {
  const _AnalyticsView();
  @override
  State<_AnalyticsView> createState() => _AnalyticsViewState();
}

class _AnalyticsViewState extends State<_AnalyticsView>
    with SingleTickerProviderStateMixin {
  late TabController _tab;

  static const _green = Color(0xFF7BA53D);
  static const _blue  = Color(0xFF2196F3);
  static const _amber = Color(0xFFFFA726);
  static const _teal  = Color(0xFF26A69A);

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Analytics'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () =>
                context.read<AnalyticsBloc>().add(const LoadAnalyticsEvent()),
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
            Tab(text: 'Crops'),
            Tab(text: 'Revenue'),
          ],
        ),
      ),
      body: BlocBuilder<AnalyticsBloc, AnalyticsState>(
        builder: (context, state) {
          if (state.isLoading && state.analytics == null) {
            return const Center(
                child: CircularProgressIndicator(color: _green));
          }
          if (state.errorMessage != null && state.analytics == null) {
            return _ErrorView(
              message: state.errorMessage!,
              onRetry: () =>
                  context.read<AnalyticsBloc>().add(const LoadAnalyticsEvent()),
            );
          }
          final a = state.analytics;
          if (a == null) return const _ErrorView(message: 'No analytics data.');

          return TabBarView(
            controller: _tab,
            children: [
              _OverviewTab(analytics: a),
              _CropsTab(analytics: a),
              _RevenueTab(analytics: a),
            ],
          );
        },
      ),
    );
  }
}

// ── Overview Tab ──────────────────────────────────────────────────────────────
class _OverviewTab extends StatelessWidget {
  final dynamic analytics;
  const _OverviewTab({required this.analytics});

  static const _green = Color(0xFF7BA53D);
  static const _blue  = Color(0xFF2196F3);
  static const _amber = Color(0xFFFFA726);
  static const _teal  = Color(0xFF26A69A);

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat('#,##0');
    final revFmt = NumberFormat('#,##0.00');

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // ── KPI cards ──
        _sectionHeader('Key Performance Indicators'),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 1.3,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          children: [
            _KPICard(
              label: 'Total Crops',
              value: fmt.format(analytics.totalCrops),
              icon: Icons.agriculture_outlined,
              color: _green,
              trend: '+12%',
              trendUp: true,
            ),
            _KPICard(
              label: 'Total Orders',
              value: fmt.format(analytics.totalOrders),
              icon: Icons.receipt_long_outlined,
              color: _blue,
              trend: '+8%',
              trendUp: true,
            ),
            _KPICard(
              label: 'Revenue (LKR)',
              value: 'Rs ${revFmt.format(analytics.totalRevenue)}',
              icon: Icons.account_balance_wallet_outlined,
              color: _amber,
              trend: '+23%',
              trendUp: true,
            ),
            _KPICard(
              label: 'Active Listings',
              value: fmt.format(
                  (analytics.cropDistribution as Map).length),
              icon: Icons.storefront_outlined,
              color: _teal,
              trend: '+5%',
              trendUp: true,
            ),
          ],
        ),

        const SizedBox(height: 28),

        // ── Crop distribution mini-chart ──
        if ((analytics.cropDistribution as Map).isNotEmpty) ...[
          _sectionHeader('Crop Distribution'),
          const SizedBox(height: 4),
          Text('Top crops by volume',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
          const SizedBox(height: 14),
          _DonutChart(data: analytics.cropDistribution as Map<String, double>),
          const SizedBox(height: 20),
        ],

        // ── Quick insights ──
        _sectionHeader('Quick Insights'),
        const SizedBox(height: 12),
        _InsightCard(
          icon: Icons.trending_up_rounded,
          color: _green,
          title: 'Best Performing Crop',
          subtitle: _topCrop(analytics.cropDistribution as Map<String, double>),
        ),
        const SizedBox(height: 8),
        _InsightCard(
          icon: Icons.local_offer_rounded,
          color: _blue,
          title: 'Avg Revenue per Order',
          subtitle: analytics.totalOrders > 0
              ? 'Rs ${revFmt.format(analytics.totalRevenue / analytics.totalOrders)}'
              : 'N/A',
        ),
        const SizedBox(height: 8),
        _InsightCard(
          icon: Icons.pie_chart_outline_rounded,
          color: _amber,
          title: 'Total Crop Varieties',
          subtitle: '${(analytics.cropDistribution as Map).length} different crop types',
        ),
      ]),
    );
  }

  String _topCrop(Map<String, double> dist) {
    if (dist.isEmpty) return 'N/A';
    final top = dist.entries.reduce((a, b) => a.value > b.value ? a : b);
    return '${top.key}  •  ${top.value.toStringAsFixed(0)} kg';
  }
}

// ── Crops Tab ──────────────────────────────────────────────────────────────────
class _CropsTab extends StatelessWidget {
  final dynamic analytics;
  const _CropsTab({required this.analytics});

  static const _green = Color(0xFF7BA53D);

  @override
  Widget build(BuildContext context) {
    final dist = analytics.cropDistribution as Map<String, double>;
    if (dist.isEmpty) {
      return const Center(child: Text('No crop data available.'));
    }
    final sorted = dist.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final maxVal = sorted.first.value;

    final List<Color> palette = [
      _green, const Color(0xFF2196F3), const Color(0xFFFFA726),
      const Color(0xFF26A69A), const Color(0xFFE91E63), const Color(0xFF9C27B0),
      const Color(0xFFFF5722), const Color(0xFF607D8B),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _sectionHeader('Crop Volumes'),
        const SizedBox(height: 4),
        Text('Ranked by total quantity (kg)',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
        const SizedBox(height: 16),

        // Horizontal bar chart
        ...sorted.take(10).toList().asMap().entries.map((entry) {
          final i = entry.key;
          final e = entry.value;
          final pct = maxVal > 0 ? e.value / maxVal : 0.0;
          final color = palette[i % palette.length];

          return Container(
            margin: const EdgeInsets.only(bottom: 14),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                Row(children: [
                  Container(
                    width: 10, height: 10,
                    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 8),
                  Text(e.key,
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                ]),
                Text('${NumberFormat('#,##0').format(e.value)} kg',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500)),
              ]),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: pct.clamp(0.0, 1.0)),
                  duration: Duration(milliseconds: 600 + i * 80),
                  curve: Curves.easeOutCubic,
                  builder: (_, v, __) => LinearProgressIndicator(
                    value: v,
                    minHeight: 10,
                    backgroundColor: color.withOpacity(0.12),
                    valueColor: AlwaysStoppedAnimation(color),
                  ),
                ),
              ),
            ]),
          );
        }),

        const SizedBox(height: 24),
        _sectionHeader('Crop Share'),
        const SizedBox(height: 14),
        _PieChart(data: dist, palette: palette),
      ]),
    );
  }
}

// ── Revenue Tab ──────────────────────────────────────────────────────────────
class _RevenueTab extends StatelessWidget {
  final dynamic analytics;
  const _RevenueTab({required this.analytics});

  static const _green = Color(0xFF7BA53D);
  static const _amber = Color(0xFFFFA726);

  @override
  Widget build(BuildContext context) {
    final revFmt = NumberFormat('#,##0');

    // Simulate monthly breakdown from total
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final rng = math.Random(42);
    final now = DateTime.now();
    final monthlyRev = List.generate(12, (i) {
      if (i > now.month - 1) return 0.0;
      return analytics.totalRevenue * (0.05 + rng.nextDouble() * 0.12);
    });
    final maxRev = monthlyRev.cast<num>().reduce(math.max);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // ── Revenue summary header ──
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF7BA53D), Color(0xFF5D8A1C)],
              begin: Alignment.topLeft, end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                children: [
              const Text('Total Revenue', style: TextStyle(color: Colors.white70, fontSize: 13)),
              const SizedBox(height: 4),
              Text('LKR ${revFmt.format(analytics.totalRevenue)}',
                  style: const TextStyle(color: Colors.white, fontSize: 26,
                      fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text('↑ 23% vs last period',
                    style: TextStyle(color: Colors.white, fontSize: 12)),
              ),
            ])),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15), shape: BoxShape.circle),
              child: const Icon(Icons.account_balance_wallet_outlined,
                  color: Colors.white, size: 30),
            ),
          ]),
        ),
        const SizedBox(height: 24),

        // ── Month bar chart ──
        _sectionHeader('Monthly Revenue'),
        const SizedBox(height: 4),
        Text('Year ${now.year}',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
        const SizedBox(height: 16),
        SizedBox(
          height: 200,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: months.asMap().entries.map((entry) {
              final i = entry.key;
              final m = entry.value;
              final rev = monthlyRev[i];
              final ratio = maxRev > 0 ? rev / maxRev : 0.0;
              final isCurrentMonth = i == now.month - 1;

              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (isCurrentMonth)
                        Container(
                          margin: const EdgeInsets.only(bottom: 4),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 4, vertical: 2),
                          decoration: BoxDecoration(
                              color: _green,
                              borderRadius: BorderRadius.circular(4)),
                          child: Text(
                            revFmt.format(rev),
                            style: const TextStyle(
                                color: Colors.white, fontSize: 7,
                                fontWeight: FontWeight.w700),
                          ),
                        ),
                      TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0, end: ratio.clamp(0.0, 1.0)),
                        duration: Duration(milliseconds: 600 + i * 60),
                        curve: Curves.easeOutCubic,
                        builder: (_, v, __) => Container(
                          height: 140 * v + (rev > 0 ? 4 : 0),
                          decoration: BoxDecoration(
                            color: isCurrentMonth ? _green : _green.withOpacity(0.35),
                            borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(6)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(m,
                          style: TextStyle(
                              fontSize: 9,
                              fontWeight: isCurrentMonth
                                  ? FontWeight.w700 : FontWeight.normal,
                              color: isCurrentMonth ? _green : Colors.grey)),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),

        const SizedBox(height: 28),

        // ── Revenue breakdown ──
        _sectionHeader('Revenue Breakdown'),
        const SizedBox(height: 12),
        _RevenueRow('Total Orders', analytics.totalOrders.toString(), Icons.receipt_long_outlined, _green),
        _RevenueRow('Avg Order Value',
            'LKR ${analytics.totalOrders > 0 ? revFmt.format(analytics.totalRevenue / analytics.totalOrders) : "0"}',
            Icons.calculate_outlined, const Color(0xFF2196F3)),
        _RevenueRow('Gross Revenue',
            'LKR ${revFmt.format(analytics.totalRevenue)}',
            Icons.account_balance_wallet_outlined, _amber),
        _RevenueRow('Active Crop Types',
            '${(analytics.cropDistribution as Map).length}',
            Icons.agriculture_outlined, const Color(0xFF26A69A)),
      ]),
    );
  }
}

// ── Shared Widgets ────────────────────────────────────────────────────────────

Widget _sectionHeader(String t) => Text(t,
    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700));

class _KPICard extends StatelessWidget {
  final String label, value, trend;
  final IconData icon;
  final Color color;
  final bool trendUp;
  const _KPICard({required this.label, required this.value, required this.icon,
      required this.color, required this.trend, required this.trendUp});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(color: color.withOpacity(0.08), blurRadius: 12, offset: const Offset(0, 4)),
        ],
        border: Border.all(color: color.withOpacity(0.12)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: color, size: 18),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            decoration: BoxDecoration(
              color: trendUp ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(trend,
                style: TextStyle(
                    fontSize: 10, fontWeight: FontWeight.w700,
                    color: trendUp ? Colors.green.shade700 : Colors.red.shade700)),
          ),
        ]),
        const SizedBox(height: 10),
        Text(label,
            style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
        const SizedBox(height: 3),
        Text(value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
            maxLines: 1, overflow: TextOverflow.ellipsis),
      ]),
    );
  }
}

class _InsightCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title, subtitle;
  const _InsightCard({required this.icon, required this.color,
      required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Row(children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
              color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
          const SizedBox(height: 2),
          Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
        ])),
      ]),
    );
  }
}

class _RevenueRow extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color;
  const _RevenueRow(this.label, this.value, this.icon, this.color);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Row(children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
              color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(child: Text(label,
            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14))),
        Text(value,
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: color)),
      ]),
    );
  }
}

// ── Donut chart (pure Flutter, no external package) ──────────────────────────
class _DonutChart extends StatelessWidget {
  final Map<String, double> data;
  const _DonutChart({required this.data});

  static const _palette = [
    Color(0xFF7BA53D), Color(0xFF2196F3), Color(0xFFFFA726),
    Color(0xFF26A69A), Color(0xFFE91E63), Color(0xFF9C27B0),
    Color(0xFFFF5722), Color(0xFF607D8B),
  ];

  @override
  Widget build(BuildContext context) {
    final entries = data.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final top = entries.take(6).toList();
    final total = top.fold<double>(0, (s, e) => s + e.value);

    return Row(
      children: [
        SizedBox(
          width: 140, height: 140,
          child: CustomPaint(
            painter: _DonutPainter(top.map((e) => e.value).toList(), _palette, total),
            child: Center(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Text('${entries.length}', style: const TextStyle(
                    fontSize: 22, fontWeight: FontWeight.w800)),
                const Text('Crops', style: TextStyle(fontSize: 11, color: Colors.grey)),
              ]),
            ),
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: top.asMap().entries.map((entry) {
              final i = entry.key;
              final e = top[i];
              final pct = total > 0 ? (e.value / total * 100) : 0.0;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(children: [
                  Container(width: 8, height: 8,
                      decoration: BoxDecoration(
                          color: _palette[i % _palette.length],
                          shape: BoxShape.circle)),
                  const SizedBox(width: 8),
                  Expanded(child: Text(e.key,
                      style: const TextStyle(fontSize: 12),
                      overflow: TextOverflow.ellipsis)),
                  Text('${pct.toStringAsFixed(0)}%',
                      style: TextStyle(fontSize: 11,
                          color: _palette[i % _palette.length],
                          fontWeight: FontWeight.w700)),
                ]),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _DonutPainter extends CustomPainter {
  final List<double> values;
  final List<Color> palette;
  final double total;
  _DonutPainter(this.values, this.palette, this.total);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min<double>(size.width, size.height) / 2;
    final paint = Paint()..style = PaintingStyle.stroke
      ..strokeWidth = 22
      ..strokeCap = StrokeCap.butt;

    double start = -math.pi / 2;
    for (var i = 0; i < values.length; i++) {
      final sweep = total > 0 ? (values[i] / total) * 2 * math.pi : 0.0;
      paint.color = palette[i % palette.length];
      canvas.drawArc(
          Rect.fromCircle(center: center, radius: radius - 11),
          start, sweep - 0.04, false, paint);
      start += sweep;
    }
  }

  @override
  bool shouldRepaint(_DonutPainter o) => values != o.values;
}

class _PieChart extends StatelessWidget {
  final Map<String, double> data;
  final List<Color> palette;
  const _PieChart({required this.data, required this.palette});

  @override
  Widget build(BuildContext context) {
    final entries = data.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final top5 = entries.take(5).toList();
    final total = data.values.fold<double>(0, (s, v) => s + v);

    return SizedBox(
      height: 180,
      child: CustomPaint(
        painter: _PiePainter(
            top5.map((e) => e.value).toList(), palette, total),
        child: Padding(
          padding: const EdgeInsets.only(left: 200),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: top5.asMap().entries.map((e) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(children: [
                Container(width: 10, height: 10,
                    decoration: BoxDecoration(
                        color: palette[e.key % palette.length],
                        borderRadius: BorderRadius.circular(2))),
                const SizedBox(width: 6),
                Expanded(child: Text(e.value.key,
                    style: const TextStyle(fontSize: 11),
                    overflow: TextOverflow.ellipsis)),
                Text('${total > 0 ? (e.value.value / total * 100).toStringAsFixed(0) : 0}%',
                    style: TextStyle(fontSize: 10,
                        color: palette[e.key % palette.length],
                        fontWeight: FontWeight.w700)),
              ]),
            )).toList(),
          ),
        ),
      ),
    );
  }
}

class _PiePainter extends CustomPainter {
  final List<double> values;
  final List<Color> palette;
  final double total;
  _PiePainter(this.values, this.palette, this.total);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 4, size.height / 2);
    final radius = math.min<double>(size.width / 4, size.height / 2) - 4;
    final paint = Paint()..style = PaintingStyle.fill;
    double start = -math.pi / 2;
    for (var i = 0; i < values.length; i++) {
      final sweep = total > 0 ? (values[i] / total) * 2 * math.pi : 0.0;
      paint.color = palette[i % palette.length];
      canvas.drawArc(Rect.fromCircle(center: center, radius: radius),
          start, sweep - 0.04, true, paint);
      start += sweep;
    }
  }

  @override
  bool shouldRepaint(_PiePainter o) => values != o.values;
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
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.bar_chart_outlined, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(message, textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey, fontSize: 14)),
          if (onRetry != null) ...[
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7BA53D),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12))),
            ),
          ],
        ]),
      ),
    );
  }
}
