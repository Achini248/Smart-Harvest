import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/constants/app_colors.dart';
import '../bloc/marketplace_bloc.dart';
import '../bloc/marketplace_event.dart';
import '../bloc/marketplace_state.dart';
import '../widgets/order_item.dart';

class OrderInboxPage extends StatefulWidget {
  const OrderInboxPage({super.key});

  @override
  State<OrderInboxPage> createState() => _OrderInboxPageState();
}

class _OrderInboxPageState extends State<OrderInboxPage> {
  @override
  void initState() {
    super.initState();
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      context
          .read<MarketplaceBloc>()
          .add(LoadIncomingOrdersEvent(sellerId: uid));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Order Inbox',
            style: TextStyle(
                fontWeight: FontWeight.w700, fontSize: 20)),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: BlocConsumer<MarketplaceBloc, MarketplaceState>(
        listener: (context, state) {
          if (state is OrderStatusUpdatedState) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(
                  'Order status updated to ${state.order.status}'),
              backgroundColor: AppColors.primaryGreen,
              behavior: SnackBarBehavior.floating,
            ));
            final uid = FirebaseAuth.instance.currentUser?.uid;
            if (uid != null) {
              context.read<MarketplaceBloc>().add(
                  LoadIncomingOrdersEvent(sellerId: uid));
            }
          } else if (state is MarketplaceErrorState) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
            ));
          }
        },
        builder: (context, state) {
          if (state is MarketplaceLoadingState ||
              state is MarketplaceOperationLoadingState) {
            return const Center(
                child: CircularProgressIndicator(
                    color: AppColors.primaryGreen));
          }

          if (state is MarketplaceEmptyState) {
            return Center(
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
                    child: const Icon(Icons.inbox_outlined,
                        size: 50, color: AppColors.primaryGreen),
                  ),
                  const SizedBox(height: 16),
                  const Text('No Incoming Orders',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  const Text(
                      'Orders from buyers will appear here.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: AppColors.textSecondary)),
                ],
              ),
            );
          }

          if (state is OrdersLoadedState && state.isSeller) {
            return RefreshIndicator(
              color: AppColors.primaryGreen,
              onRefresh: () async {
                final uid =
                    FirebaseAuth.instance.currentUser?.uid;
                if (uid != null) {
                  context.read<MarketplaceBloc>().add(
                      LoadIncomingOrdersEvent(sellerId: uid));
                }
                await Future.delayed(
                    const Duration(milliseconds: 400));
              },
              child: ListView.builder(
                padding: const EdgeInsets.only(top: 12, bottom: 20),
                itemCount: state.orders.length,
                itemBuilder: (_, i) {
                  final order = state.orders[i];
                  return OrderItem(
                    order: order,
                    isSeller: true,
                    onStatusUpdate: (newStatus) {
                      context.read<MarketplaceBloc>().add(
                            UpdateOrderStatusEvent(
                              orderId: order.id,
                              status: newStatus,
                            ),
                          );
                    },
                  );
                },
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
