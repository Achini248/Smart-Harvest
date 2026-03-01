import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/product.dart';
import '../bloc/marketplace_bloc.dart';
import '../bloc/marketplace_event.dart';
import '../bloc/marketplace_state.dart';
import '../widgets/product_card.dart';

class MarketplaceHomePage extends StatefulWidget {
  const MarketplaceHomePage({super.key});

  @override
  State<MarketplaceHomePage> createState() =>
      _MarketplaceHomePageState();
}

class _MarketplaceHomePageState extends State<MarketplaceHomePage> {
  final _orderFormKey = GlobalKey<FormState>();
  final TextEditingController _quantityCtrl = TextEditingController();
  final TextEditingController _notesCtrl = TextEditingController();

  @override
  void dispose() {
    _quantityCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  void _showOrderDialog(BuildContext context, ProductEntity product) {
    _quantityCtrl.clear();
    _notesCtrl.clear();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16,
          right: 16,
          top: 16,
        ),
        child: Form(
          key: _orderFormKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 4,
                width: 40,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Text(
                'Order ${product.name}',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _quantityCtrl,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: _dec(
                  label: 'Quantity (${product.unit})',
                  icon: Icons.production_quantity_limits,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Quantity is required';
                  }
                  final parsed = double.tryParse(value);
                  if (parsed == null || parsed <= 0) {
                    return 'Enter a valid quantity';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _notesCtrl,
                maxLines: 3,
                decoration: _dec(
                  label: 'Notes (optional)',
                  icon: Icons.notes,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    if (!_orderFormKey.currentState!.validate()) return;

                    final quantity =
                        double.parse(_quantityCtrl.text.trim());

                    final order = OrderEntity(
                      id: '',
                      productId: product.id,
                      productName: product.name,
                      buyerId: 'CURRENT_USER_ID', // plug auth user
                      buyerName: 'Current User',
                      sellerId: product.sellerId,
                      sellerName: product.sellerName,
                      quantity: quantity,
                      unit: product.unit,
                      pricePerUnit: product.pricePerUnit,
                      totalPrice: product.pricePerUnit * quantity,
                      status: 'pending',
                      notes: _notesCtrl.text.trim().isEmpty
                          ? null
                          : _notesCtrl.text.trim(),
                      location: 'N/A',
                      createdAt: DateTime.now(),
                      updatedAt: DateTime.now(),
                    );

                    context.read<MarketplaceBloc>().add(
                          PlaceOrderEvent(order: order),
                        );

                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7BA53D),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: const Text(
                    'Place Order',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _dec({
    required String label,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        title: const Text('Marketplace'),
        centerTitle: true,
      ),
      body: BlocConsumer<MarketplaceBloc, MarketplaceState>(
        listener: (ctx, state) {
          if (state is MarketplaceOperationSuccess) {
            ScaffoldMessenger.of(ctx).showSnackBar(
              const SnackBar(
                content: Text('Order placed successfully'),
                backgroundColor: Colors.green,
              ),
            );
          } else if (state is MarketplaceErrorState) {
            ScaffoldMessenger.of(ctx).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.redAccent,
              ),
            );
          }
        },
        builder: (ctx, state) {
          final isLoading =
              state is MarketplaceLoadingState ||
              state is MarketplaceOperationLoadingState;

          if (isLoading && state is! MarketplaceLoaded) {
            return const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF7BA53D),
              ),
            );
          }

          if (state is MarketplaceLoaded) {
            final products = state.products;
            if (products.isEmpty) {
              return const Center(
                child: Text(
                  'No products available.',
                  style: TextStyle(color: Colors.grey),
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 12),
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                return ProductCard(
                  product: product,
                  onTap: () => _showOrderDialog(context, product),
                );
              },
            );
          }

          if (state is MarketplaceErrorState) {
            return Center(
              child: Text(
                state.message,
                style: const TextStyle(color: Colors.redAccent),
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
