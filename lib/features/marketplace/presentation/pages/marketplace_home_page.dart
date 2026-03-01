import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/order.dart'; // Entity නම නිවැරදි කළා
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
    // මුලින්ම products load කරගන්නවා
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
                      subtitle: Text('Rs. ${product.price}'),
                      trailing: ElevatedButton(
                        onPressed: () {
                          // Order එකක් ප්ලේස් කරන ආකාරය
                          // මෙහි Order class එකේ parameters ඔබේ Entity එකට අනුව වෙනස් විය හැක
                          /*
                          final newOrder = Order(
                            id: DateTime.now().toString(),
                            productName: product.name,
                            price: product.price,
                          );
                          context.read<MarketplaceBloc>().add(PlaceOrderEvent(newOrder));
                          */
                        },
                        child: const Text('Buy'),
                      ),
                    ),
                  );
                },
              ),
            );
          }

          if (state is MarketplaceEmptyState) {
            return Center(child: Text(state.message));
          }

          return const Center(child: Text('Start exploring the marketplace!'));
        },
      ),
    );
  }
}