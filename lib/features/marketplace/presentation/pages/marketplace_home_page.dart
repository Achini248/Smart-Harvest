import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../config/routes/route_names.dart';
import '../bloc/marketplace_bloc.dart';
import '../bloc/marketplace_event.dart';
import '../bloc/marketplace_state.dart';
import '../widgets/product_card.dart';
import '../../domain/entities/seller.dart';

class MarketplaceHomePage extends StatefulWidget {
  const MarketplaceHomePage({super.key});

  @override
  State<MarketplaceHomePage> createState() => _MarketplaceHomePageState();
}

class _MarketplaceHomePageState extends State<MarketplaceHomePage> {
  final _searchCtrl = TextEditingController();
  String? _selectedCategory;

  final List<String?> _categories = [
    null,
    'vegetables',
    'fruits',
    'grains',
    'legumes',
    'herbs',
    'dairy',
    'other',
  ];

  final Map<String?, String> _categoryLabels = {
    null: 'All',
    'vegetables': 'Vegetables',
    'fruits': 'Fruits',
    'grains': 'Grains',
    'legumes': 'Legumes',
    'herbs': 'Herbs',
    'dairy': 'Dairy',
    'other': 'Other',
  };

  @override
  void initState() {
    super.initState();
    context.read<MarketplaceBloc>().add(const LoadProductsEvent());
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _showOrderDialog(BuildContext context, ProductEntity product) {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    final qtyCtrl = TextEditingController(text: '1');
    final notesCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text('Order — ${product.name}',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Text(
                'Rs. ${product.pricePerUnit.toStringAsFixed(2)} per ${product.unit}  •  ${product.sellerName}',
                style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 13),
              ),
              const SizedBox(height: 20),

              TextFormField(
                controller: qtyCtrl,
                keyboardType: TextInputType.number,
                decoration: _dec(
                    label: 'Quantity (${product.unit})',
                    icon: Icons.straighten),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Required';
                  final q = double.tryParse(v);
                  if (q == null || q <= 0) return 'Enter valid quantity';
                  if (q > product.availableQuantity) {
                    return 'Only ${product.availableQuantity} ${product.unit} available';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: notesCtrl,
                maxLines: 2,
                decoration:
                    _dec(label: 'Notes (optional)', icon: Icons.notes),
              ),
              const SizedBox(height: 20),

              BlocConsumer<MarketplaceBloc, MarketplaceState>(
                listener: (ctx, state) {
                  if (state is OrderPlacedState) {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Order placed successfully!'),
                        backgroundColor: AppColors.primaryGreen,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  } else if (state is MarketplaceErrorState) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.message),
                        backgroundColor: AppColors.error,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                },
                builder: (ctx, state) {
                  final loading =
                      state is MarketplaceOperationLoadingState;
