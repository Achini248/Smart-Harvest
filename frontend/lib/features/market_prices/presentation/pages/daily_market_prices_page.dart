// lib/features/market_prices/presentation/pages/daily_market_prices_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../config/dependency_injection/injection_container.dart';
import '../../domain/entities/price.dart';
import '../bloc/price_bloc.dart';
import '../bloc/price_event.dart';
import '../bloc/price_state.dart';
import '../widgets/price_card.dart';

class DailyMarketPricesPage extends StatelessWidget {
  const DailyMarketPricesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<PriceBloc>()
        ..add(const LoadDailyPricesEvent())
        ..add(const LoadSupplyStatusEvent()),
      child: const _DailyMarketPricesView(),
    );
  }
}

class _DailyMarketPricesView extends StatefulWidget {
  const _DailyMarketPricesView();

  @override
  State<_DailyMarketPricesView> createState() =>
      _DailyMarketPricesViewState();
}

class _DailyMarketPricesViewState extends State<_DailyMarketPricesView> {
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F5F7),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF4F5F7),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          'Market Prices',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18, color: Colors.black87),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black87),
            onPressed: () =>
                context.read<PriceBloc>().add(const RefreshAllPricesEvent()),
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Supply analytics summary bar ──────────────────────────────────
          BlocBuilder<PriceBloc, PriceState>(
            buildWhen: (p, c) => p.supplyAnalytics != c.supplyAnalytics,
            builder: (context, state) {
              final sa = state.supplyAnalytics;
              if (sa == null) return const SizedBox.shrink();
              return Container(
                margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [BoxShadow(color: Color(0x0A000000), blurRadius: 6)],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _AnalyticStat('📈', '${sa.totalSurplus}', 'Surplus',   const Color(0xFF2E7D32)),
                    _AnalyticStat('📉', '${sa.totalShortage}', 'Shortage', const Color(0xFFD84315)),
                    _AnalyticStat('⚖️', '${sa.totalNormal}', 'Normal',    const Color(0xFF1565C0)),
                    _AnalyticStat('📦', '${sa.total}', 'Total',           const Color(0xFF757575)),
                  ],
                ),
              );
            },
          ),
          // ── Search ────────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (v) =>
                  context.read<PriceBloc>().add(SearchPricesEvent(query: v)),
              decoration: InputDecoration(
                hintText: 'Search crops, markets or districts…',
                hintStyle: TextStyle(color: Colors.grey.shade400),
                prefixIcon: Icon(Icons.search, color: Colors.grey.shade400),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          // ── District chips ────────────────────────────────────────────────
          BlocBuilder<PriceBloc, PriceState>(
            buildWhen: (p, c) =>
                p.allPrices != c.allPrices ||
                p.selectedDistrict != c.selectedDistrict,
            builder: (context, state) {
              if (state.districts.length <= 1) return const SizedBox.shrink();
              return SizedBox(
                height: 40,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: state.districts.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, i) {
                    final d = state.districts[i];
                    final selected = d == state.selectedDistrict;
                    return ChoiceChip(
                      label: Text(d),
                      selected: selected,
                      selectedColor: const Color(0xFF7BA53D),
                      onSelected: (_) => context
                          .read<PriceBloc>()
                          .add(FilterByDistrictEvent(d)),
                    );
                  },
                ),
              );
            },
          ),
          // ── Price list ────────────────────────────────────────────────────
          Expanded(
            child: BlocBuilder<PriceBloc, PriceState>(
              builder: (context, state) {
                if (state.isLoadingPrices && state.filteredPrices.isEmpty) {
                  return const Center(
                    child: CircularProgressIndicator(color: Color(0xFF7BA53D)),
                  );
                }
                if (state.errorMessage != null && state.filteredPrices.isEmpty) {
                  return _ErrorView(
                    message: state.errorMessage!,
                    onRetry: () => context
                        .read<PriceBloc>()
                        .add(const LoadDailyPricesEvent()),
                  );
                }
                if (state.filteredPrices.isEmpty) {
                  return const _EmptyView();
                }
                return RefreshIndicator(
                  color: const Color(0xFF7BA53D),
                  onRefresh: () async => context
                      .read<PriceBloc>()
                      .add(const RefreshAllPricesEvent()),
                  child: ListView.builder(
                    padding: const EdgeInsets.only(bottom: 16),
                    itemCount: state.filteredPrices.length,
                    itemBuilder: (context, i) {
                      final price = state.filteredPrices[i];
                      return PriceCard(
                        price: price,
                        onTap: () => context
                            .read<PriceBloc>()
                            .add(LoadForecastEvent(price.cropName)),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _AnalyticStat extends StatelessWidget {
  final String emoji, value, label;
  final Color color;
  const _AnalyticStat(this.emoji, this.value, this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(emoji),
        const SizedBox(height: 2),
        Text(value,
            style: TextStyle(
                fontWeight: FontWeight.w800, fontSize: 16, color: color)),
        Text(label,
            style: const TextStyle(fontSize: 10, color: Color(0xFF757575))),
      ],
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey)),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onRetry,
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF7BA53D)),
            child: const Text('Retry', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.storefront_outlined, size: 48, color: Color(0xFF7BA53D)),
          SizedBox(height: 12),
          Text('No market prices found.', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}
