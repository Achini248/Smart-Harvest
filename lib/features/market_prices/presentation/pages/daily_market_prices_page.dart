import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Import නිවැරදිව ඇති බව සහතික කරගන්න
import '../../data/datasources/price_remote_datasource.dart';
import '../../data/repositories/price_repository_impl.dart';
import '../../domain/usecases/get_daily_prices_usecase.dart';
import '../../domain/usecases/get_price_trends_usecase.dart';
import '../bloc/price_bloc.dart';
import '../bloc/price_event.dart';
import '../bloc/price_state.dart';
import '../widgets/price_card.dart';

class DailyMarketPricesPage extends StatefulWidget {
  const DailyMarketPricesPage({super.key});

  @override
  State<DailyMarketPricesPage> createState() => _DailyMarketPricesPageState();
}

class _DailyMarketPricesPageState extends State<DailyMarketPricesPage> {
  late final PriceBloc _bloc;
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Repository සහ UseCases initialize කිරීම
    final repo = PriceRepositoryImpl(
      remoteDataSource: PriceRemoteDataSourceImpl(),
    );
    
    _bloc = PriceBloc(
      getDailyPrices: GetDailyPricesUseCase(repo),
      getPriceTrends: GetPriceTrendsUseCase(repo),
    )..add(const LoadDailyPricesEvent()); // මෙහි 'const' වැඩ කරන්නේ PriceEvent එකේ constructor එක 'const' නම් පමණි
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<PriceBloc>.value(
      value: _bloc,
      child: Scaffold(
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
            // Search Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: TextField(
                controller: _searchCtrl,
                onChanged: (value) => _bloc.add(
                  SearchPricesEvent(query: value),
                ),
                decoration: InputDecoration(
                  hintText: 'Search crop',
                  hintStyle: TextStyle(color: Colors.grey.shade400),
                  prefixIcon: Icon(
                    Icons.search,
                    color: Colors.grey.shade400,
                  ),
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
            Expanded(
              child: BlocBuilder<PriceBloc, PriceState>(
                builder: (context, state) {
                  if (state.isLoading && state.filteredPrices.isEmpty) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF7BA53D),
                      ),
                    );
                  }

                  if (state.errorMessage != null && state.filteredPrices.isEmpty) {
                    return _ErrorView(
                      message: state.errorMessage!,
                      onRetry: () => _bloc.add(const LoadDailyPricesEvent()),
                    );
                  }

                  if (state.filteredPrices.isEmpty) {
                    return const _EmptyView();
                  }

                  return RefreshIndicator(
                    color: const Color(0xFF7BA53D),
                    onRefresh: () async {
                      _bloc.add(const LoadDailyPricesEvent());
                      await Future.delayed(const Duration(milliseconds: 400));
                    },
                    child: ListView.builder(
                      itemCount: state.filteredPrices.length,
                      padding: const EdgeInsets.only(bottom: 16),
                      itemBuilder: (context, index) {
                        final price = state.filteredPrices[index];
                        return PriceCard(
                          price: price,
                          onTap: () {
                            _bloc.add(
                              LoadPriceTrendsEvent(price.productName),
                            );
                            // අවශ්‍ය නම් මෙතනදී BottomSheet එකක් පෙන්විය හැක
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
      ),
    );
  }
}

// Error View Widget
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
          Text(message, textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey)),
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

// Empty View Widget
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
          Text('No market prices available.', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}