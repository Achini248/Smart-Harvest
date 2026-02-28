// lib/features/market_prices/presentation/pages/daily_market_prices_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/datasources/price_remote_datasource.dart';
import '../../data/repositories/price_repository_impl.dart';
import '../../domain/usecases/get_daily_prices_usecase.dart';
import '../../domain/usecases/get_price_trends_usecase.dart';
import '../bloc/price_bloc.dart';
import '../bloc/price_event.dart';
import '../bloc/price_state.dart';
import '../widgets/price_card.dart';

class DailyMarketPricesPage extends StatelessWidget {
  const DailyMarketPricesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PriceBloc(
        getDailyPrices:
            GetDailyPricesUseCase(PriceRepositoryImpl(
          remoteDataSource: PriceRemoteDataSourceImpl(),
        )),
        getPriceTrends:
            GetPriceTrendsUseCase(PriceRepositoryImpl(
          remoteDataSource: PriceRemoteDataSourceImpl(),
        )),
      )..add(const LoadDailyPricesEvent()),
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

class _DailyMarketPricesViewState
    extends State<_DailyMarketPricesView> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _searchQuery = '';

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
          icon: const Icon(Icons.arrow_back_ios_new,
              size: 18, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          'Daily Market Prices',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 18,
            color: Colors.black87,
          ),
        ),
      ),
      body: Column(
        children: [
          // Search
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (value) {
                setState(() => _searchQuery = value.trim());
              },
              decoration: InputDecoration(
                hintText: 'Search crop',
                hintStyle: TextStyle(color: Colors.grey.shade400),
                prefixIcon: Icon(Icons.search,
                    color: Colors.grey.shade400),
                filled: true,
                fillColor: Colors.white,
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          Expanded(
            child: BlocBuilder<PriceBloc, PriceState>(
              builder: (context, state) {
                if (state.isLoading && state.prices.isEmpty) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF7BA53D),
                    ),
                  );
                }

                if (state.errorMessage != null &&
                    state.prices.isEmpty) {
                  return _ErrorView(
                    message: state.errorMessage!,
                    onRetry: () => context
                        .read<PriceBloc>()
                        .add(const LoadDailyPricesEvent()),
                  );
                }

                final filtered = _searchQuery.isEmpty
                    ? state.prices
                    : state.prices
                        .where((p) => p.productName
                            .toLowerCase()
                            .contains(_searchQuery.toLowerCase()))
                        .toList();

                if (filtered.isEmpty) {
                  return const _EmptyView();
                }

                return RefreshIndicator(
                  color: const Color(0xFF7BA53D),
                  onRefresh: () async {
                    context
                        .read<PriceBloc>()
                        .add(const LoadDailyPricesEvent());
                    await Future.delayed(
                        const Duration(milliseconds: 400));
                  },
                  child: ListView.builder(
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final price = filtered[index];
                      return PriceCard(
                        price: price,
                        onTap: () {
                          // Load trends for this product (optional)
                          context.read<PriceBloc>().add(
                                LoadPriceTrendsEvent(
                                    price.productName),
                              );
                          // You could show bottom sheet with trends chart.
                        },
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

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({
    required this.message,
    required this.onRetry,
  });

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
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7BA53D),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              icon: const Icon(Icons.refresh,
                  color: Colors.white, size: 18),
              label: const Text(
                'Retry',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: const Color(0xFF7BA53D).withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.storefront_outlined,
                size: 40,
                color: Color(0xFF7BA53D),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'No market prices available.',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
