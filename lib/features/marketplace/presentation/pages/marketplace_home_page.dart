import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/order.dart'; 
import '../bloc/marketplace_bloc.dart';
import '../bloc/marketplace_event.dart';
import '../bloc/marketplace_state.dart';

class MarketplaceHomePage extends StatefulWidget {
  const MarketplaceHomePage({super.key});

  @override
  State<MarketplaceHomePage> createState() => _MarketplaceHomePageState();
}

class _MarketplaceHomePageState extends State<MarketplaceHomePage> {
  @override
  void initState() {
    super.initState();
    context.read<MarketplaceBloc>().add(const LoadProductsEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Marketplace'),
        centerTitle: true,
      ),
      body: BlocConsumer<MarketplaceBloc, MarketplaceState>(
        listener: (context, state) {
          if (state is OrderPlacedState) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Order placed successfully!')),
            );
          }
          if (state is MarketplaceErrorState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          if (state is MarketplaceLoadingState) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ProductsLoadedState) {
            if (state.products.isEmpty) {
              return const Center(child: Text('No products found.'));
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<MarketplaceBloc>().add(const LoadProductsEvent());
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.products.length,
                itemBuilder: (context, index) {
                  final product = state.products[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      title: Text(product.name),
                      // මෙතන 'price' වෙනුවට 'unitPrice' ලෙස නිවැරදි කළා
                      subtitle: Text('Rs. ${product.unitPrice}'), 
                      trailing: ElevatedButton(
                        onPressed: () {
                          // Order logic goes here
                        },
                        child: const Text('Buy'),
                      ),
                    ),
                  );
                },
              ),
            );
          }
          return const Center(child: Text('Start exploring!'));
        },
      ),
    );
  }
}