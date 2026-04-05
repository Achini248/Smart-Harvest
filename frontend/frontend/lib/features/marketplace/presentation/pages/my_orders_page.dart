import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/constants/app_colors.dart';
import '../bloc/marketplace_bloc.dart';
import '../bloc/marketplace_event.dart';
import '../bloc/marketplace_state.dart';
import '../widgets/order_item.dart';

class MyOrdersPage extends StatefulWidget {
  const MyOrdersPage({super.key});

  @override
  State<MyOrdersPage> createState() => _MyOrdersPageState();
}

class _MyOrdersPageState extends State<MyOrdersPage> {
  @override
  void initState() {
    super.initState();
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      context
          .read<MarketplaceBloc>()
          .add(LoadMyOrdersEvent(buyerId: uid));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('My Orders',
            style: TextStyle(
                fontWeight: FontWeight.w700, fontSize: 20)),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: BlocBuilder<MarketplaceBloc, MarketplaceState>(
        builder: (context, state) {
          if (state is MarketplaceLoadingState) {
            return const Center(
                child: CircularProgressIndicator(
                    color: AppColors.primaryGreen));
          }

          if (state is MarketplaceEmptyState) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: AppColors.primaryGreen.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.receipt_long_outlined,
                          size: 50, color: AppColors.primaryGreen),
                    ),
                    const SizedBox(height: 16),
                    const Text('No Orders Yet',
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700)),
                    const SizedBox(height: 8),
                    const Text(
                        'Your placed orders will appear here.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: AppColors.textSecondary)),
                  ],
                ),
              ),
            );
          }

          if (state is MarketplaceErrorState) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline,
                      size: 54, color: AppColors.error),
                  const SizedBox(height: 12),
                  Text(state.message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          color: AppColors.textSecondary)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryGreen),
                    onPressed: () {
                      final uid =
                          FirebaseAuth.instance.currentUser?.uid;
                      if (uid != null) {
                        context.read<MarketplaceBloc>().add(
                            LoadMyOrdersEvent(buyerId: uid));
                      }
                    },
                    child: const Text('Retry',
                        style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            );
          }

          if (state is OrdersLoadedState && !state.isSeller) {
            return RefreshIndicator(
              color: AppColors.primaryGreen,
              onRefresh: () async {
                final uid =
                    FirebaseAuth.instance.currentUser?.uid;
                if (uid != null) {
                  context.read<MarketplaceBloc>().add(
                      LoadMyOrdersEvent(buyerId: uid));
                }
                await Future.delayed(
                    const Duration(milliseconds: 400));
              },
              child: ListView.builder(
                padding: const EdgeInsets.only(top: 12, bottom: 20),
                itemCount: state.orders.length,
                itemBuilder: (_, i) =>
                    OrderItem(order: state.orders[i], isSeller: false),
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
