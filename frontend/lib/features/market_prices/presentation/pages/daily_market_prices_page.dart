import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../config/dependency_injection/injection_container.dart';
import '../bloc/price_bloc.dart';
import '../bloc/price_event.dart';
import '../bloc/price_state.dart';
import '../widgets/price_card.dart';

class DailyMarketPricesPage extends StatelessWidget {
  const DailyMarketPricesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          sl<PriceBloc>()..add(const LoadDailyPricesEvent()),
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
  final TextEditingController _searchCtrl =
      TextEditingController();

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
          icon: const Icon(
            Icons.arrow_back_ios_new,
            size: 18,
            color: Colors.black87,
          ),
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
          Padding(
            padding:
                const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (value) {
                context.read<PriceBloc>().add(
                      SearchPricesEvent(query: value),
                    );
              },
              decoration: InputDecoration(
                hintText: 'Search crop',
                hintStyle:
                    TextStyle(color: Colors.grey.shade400),
                prefixIcon: Icon(
                  Icons.search,
                  color: Colors.grey.shade400,
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 12),
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: BlocBuilder<PriceBloc, PriceState>(
              builder: (context, state) {
                if (state.isLoading &&
                    state.filteredPrices.isEmpty) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF7BA53D),
                    ),
                  );
                }

                if (state.errorMessage != null &&
                    state.filteredPrices.isEmpty) {
                  return _ErrorView(
                    message: state.errorMessage!,
                    onRetry: () => context
                        .read<PriceBloc>()
                        .add(
                          const LoadDailyPricesEvent(),
                        ),
                  );
                }

                if (state.filteredPrices.isEmpty) {
                  return const _EmptyView();
                }

                return RefreshIndicator(
                  color: const Color(0xFF7BA53D),
                  onRefresh: () async {
                    context.read<PriceBloc>().add(
                          const LoadDailyPricesEvent(),
                        );
                  },
                  child: ListView.builder(
                    itemCount:
                        state.filteredPrices.length,
                    padding:
                        const EdgeInsets.only(bottom: 16),
                    itemBuilder: (context, index) {
                      final price =
                          state.filteredPrices[index];

                      return PriceCard(
                        price: price,
                        onTap: () {
                          context.read<PriceBloc>().add(
                                LoadPriceTrendsEvent(
                                  price.productName,
                                ),
                              );
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline,
              size: 48, color: Colors.redAccent),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style:
                const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onRetry,
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  const Color(0xFF7BA53D),
            ),
            child: const Text(
              'Retry',
              style:
                  TextStyle(color: Colors.white),
            ),
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
          Icon(Icons.storefront_outlined,
              size: 48,
              color: Color(0xFF7BA53D)),
          SizedBox(height: 12),
          Text(
            'No market prices available.',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}