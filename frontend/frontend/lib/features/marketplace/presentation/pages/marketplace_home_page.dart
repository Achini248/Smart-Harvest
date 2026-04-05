// lib/features/marketplace/presentation/pages/marketplace_home_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../config/routes/route_names.dart';
import '../../../authentication/presentation/bloc/auth_bloc.dart';
import '../../../authentication/presentation/bloc/auth_state.dart';
import '../bloc/marketplace_bloc.dart';
import '../bloc/marketplace_event.dart';
import '../bloc/marketplace_state.dart';
import '../../domain/entities/seller.dart';
import '../../domain/entities/order.dart';
import 'add_product_page.dart';

class MarketplaceHomePage extends StatefulWidget {
  const MarketplaceHomePage({super.key});
  @override State<MarketplaceHomePage> createState() => _MarketplaceHomePageState();
}

class _MarketplaceHomePageState extends State<MarketplaceHomePage> {
  final _searchCtrl = TextEditingController();
  String? _cat;
  // Cache the last successfully loaded list so it stays visible during
  // transient states (order placed, operation loading, etc.)
  List<ProductEntity> _cachedProducts = [];
  static const _cats = ['All', 'Vegetables', 'Fruits', 'Grains', 'Legumes', 'Herbs', 'Dairy'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) =>
        context.read<MarketplaceBloc>().add(const LoadProductsEvent()));
  }

  @override
  void dispose() { _searchCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F5F7),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF4F5F7), elevation: 0,
        title: const Text('Marketplace', style: TextStyle(fontWeight: FontWeight.w700)),
        actions: [
          IconButton(icon: const Icon(Icons.message_outlined), tooltip: 'Messages',
              onPressed: () {
                if (context.read<AuthBloc>().state is! Authenticated) { _signIn(context); return; }
                Navigator.pushNamed(context, RouteNames.messagesList);
              }),
          IconButton(icon: const Icon(Icons.shopping_bag_outlined), tooltip: 'My Orders',
              onPressed: () {
                if (context.read<AuthBloc>().state is! Authenticated) { _signIn(context); return; }
                Navigator.pushNamed(context, RouteNames.myOrders);
              }),
        ],
      ),
      floatingActionButton: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, auth) {
          if (auth is! Authenticated) return const SizedBox.shrink();
          return FloatingActionButton.extended(
            backgroundColor: AppColors.primaryGreen,
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text('List Crop',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
            onPressed: () async {
              final result = await Navigator.push<bool>(
                context,
                MaterialPageRoute(
                  builder: (_) => BlocProvider.value(
                    value: context.read<MarketplaceBloc>(),
                    child: const AddProductPage(),
                  ),
                ),
              );
              if (result == true && context.mounted) {
                context.read<MarketplaceBloc>().add(const LoadProductsEvent());
              }
            },
          );
        },
      ),
      body: Column(children: [
        Padding(padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
          child: TextField(
            controller: _searchCtrl,
            onChanged: (v) => context.read<MarketplaceBloc>().add(SearchProductsEvent(query: v)),
            decoration: InputDecoration(
              hintText: 'Search crops, sellers, locations…',
              hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
              prefixIcon: Icon(Icons.search, color: Colors.grey.shade400),
              suffixIcon: _searchCtrl.text.isNotEmpty
                  ? IconButton(icon: const Icon(Icons.clear, size: 18), onPressed: () {
                      _searchCtrl.clear(); context.read<MarketplaceBloc>().add(const LoadProductsEvent());
                    }) : null,
              filled: true, fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
            ),
          )),
        SizedBox(height: 44,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            itemCount: _cats.length,
            itemBuilder: (context, i) {
              final cat = _cats[i];
              final sel = (i == 0 && _cat == null) || _cat == cat;
              return Padding(padding: const EdgeInsets.symmetric(horizontal: 4),
                child: FilterChip(
                  label: Text(cat, style: TextStyle(fontSize: 12,
                      color: sel ? Colors.white : AppColors.textPrimary, fontWeight: FontWeight.w500)),
                  selected: sel, backgroundColor: Colors.white,
                  selectedColor: AppColors.primaryGreen, checkmarkColor: Colors.white,
                  onSelected: (_) {
                    setState(() => _cat = cat == 'All' ? null : cat);
                    context.read<MarketplaceBloc>().add(LoadProductsEvent(category: cat == 'All' ? null : cat));
                  },
                ));
            },
          )),
        Expanded(child: BlocConsumer<MarketplaceBloc, MarketplaceState>(
          listener: (context, state) {
            if (state is ProductsLoadedState) {
              // Update cache whenever we get a fresh load
              setState(() => _cachedProducts = state.products);
            }
            if (state is OrderPlacedState) {
              _showOrderSuccess(context, state.order.id);
              // Reload listings after order so stock levels are current
              context.read<MarketplaceBloc>().add(const LoadProductsEvent());
            }
            if (state is MarketplaceErrorState) _errorDialog(context, state.message);
          },
          builder: (context, state) {
            // ── Full-screen loading (first load only, no cached data yet) ──
            if (state is MarketplaceLoadingState && _cachedProducts.isEmpty) {
              return const Center(
                  child: CircularProgressIndicator(color: AppColors.primaryGreen));
            }

            // ── Error with no cached products — show retry screen ──
            if (state is MarketplaceErrorState && _cachedProducts.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.cloud_off_outlined,
                        size: 64, color: Colors.grey.shade400),
                    const SizedBox(height: 16),
                    const Text('Could not load listings',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    Text(state.message,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            color: AppColors.textSecondary, fontSize: 13)),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryGreen,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12))),
                      icon: const Icon(Icons.refresh, color: Colors.white),
                      label: const Text('Try Again',
                          style: TextStyle(color: Colors.white)),
                      onPressed: () => context
                          .read<MarketplaceBloc>()
                          .add(const LoadProductsEvent()),
                    ),
                  ]),
                ),
              );
            }

            // ── Determine which products to display ──
            // Use fresh products from state when available, fall back to cache.
            final List<ProductEntity> displayProducts;
            if (state is ProductsLoadedState) {
              displayProducts = state.products;
            } else if (state is MarketplaceEmptyState && _cachedProducts.isEmpty) {
              // Genuine empty — no products exist
              return _empty();
            } else {
              displayProducts = _cachedProducts;
            }

            // ── Show the product list ──
            if (displayProducts.isEmpty) return _empty();

            return Stack(children: [
              RefreshIndicator(
                color: AppColors.primaryGreen,
                onRefresh: () async =>
                    context.read<MarketplaceBloc>().add(const LoadProductsEvent()),
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                  itemCount: displayProducts.length,
                  itemBuilder: (context, i) => _ProductCard(
                    product: displayProducts[i],
                    onTap: () => _showDetail(context, displayProducts[i]),
                  ),
                ),
              ),
              // Subtle loading overlay while refreshing (not blocking)
              if (state is MarketplaceLoadingState)
                Positioned(
                  top: 0, left: 0, right: 0,
                  child: LinearProgressIndicator(
                    backgroundColor: Colors.transparent,
                    color: AppColors.primaryGreen.withOpacity(0.6),
                    minHeight: 3,
                  ),
                ),
            ]);
          },
        )),
      ]),
    );
  }

  void _showDetail(BuildContext context, ProductEntity product) {
    showModalBottomSheet(context: context, isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => BlocProvider.value(
            value: context.read<MarketplaceBloc>(),
            child: _ProductDetailSheet(product: product)));
  }

  void _showOrderSuccess(BuildContext context, String orderId) {
    showDialog(context: context, builder: (_) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Row(children: [Icon(Icons.check_circle, color: AppColors.primaryGreen),
          SizedBox(width: 8), Text('Order Placed!')]),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        const Text('Your order has been sent to the farmer.'),
        const SizedBox(height: 8),
        Text('Order ID: $orderId', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
      ]),
      actions: [
        ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryGreen),
            onPressed: () { Navigator.pop(context); Navigator.pushNamed(context, RouteNames.myOrders); },
            child: const Text('View Orders', style: TextStyle(color: Colors.white))),
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Continue')),
      ],
    ));
  }

  void _errorDialog(BuildContext context, String msg) {
    showDialog(context: context, builder: (_) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Row(children: [Icon(Icons.error_outline, color: Colors.red), SizedBox(width: 8), Text('Error')]),
      content: Text(msg),
      actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))],
    ));
  }

  void _signIn(BuildContext context) {
    showDialog(context: context, builder: (_) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('Sign in required'),
      content: const Text('Please sign in to access this feature.'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryGreen),
            onPressed: () { Navigator.pop(context); Navigator.pushNamed(context, RouteNames.login); },
            child: const Text('Sign In', style: TextStyle(color: Colors.white))),
      ],
    ));
  }

  Widget _empty() => Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.store_outlined, size: 64, color: Colors.grey.shade400),
        const SizedBox(height: 16),
        const Text('No products found', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        const Text('Try a different search or category', style: TextStyle(color: AppColors.textSecondary)),
      ]));
}

class _ProductCard extends StatelessWidget {
  final ProductEntity product;
  final VoidCallback onTap;
  const _ProductCard({required this.product, required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE8E8E8))),
        child: Padding(padding: const EdgeInsets.all(14), child: Row(children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: product.imageUrl != null && product.imageUrl!.isNotEmpty
                ? Image.network(
                    product.imageUrl!,
                    width: 64, height: 64,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _productIconPlaceholder(),
                  )
                : _productIconPlaceholder(),
          ),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(product.name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Row(children: [const Icon(Icons.person_outline, size: 13, color: AppColors.textSecondary), const SizedBox(width: 3),
              Expanded(child: Text(product.sellerName, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary), overflow: TextOverflow.ellipsis))]),
            Row(children: [const Icon(Icons.location_on_outlined, size: 13, color: AppColors.textSecondary), const SizedBox(width: 3),
              Text(product.location, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary))]),
            const SizedBox(height: 6),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('Rs. ${product.pricePerUnit.toStringAsFixed(0)}/${product.unit}',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.primaryGreen)),
              Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: AppColors.primaryGreen.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                  child: const Text('View →', style: TextStyle(fontSize: 11, color: AppColors.primaryGreen, fontWeight: FontWeight.w600))),
            ]),
          ])),
        ])),
      ));
  Widget _productIconPlaceholder() => Container(
      width: 64, height: 64,
      color: AppColors.primaryGreen.withOpacity(0.1),
      child: const Icon(Icons.eco_outlined, color: AppColors.primaryGreen, size: 32));
}

class _ProductDetailSheet extends StatefulWidget {
  final ProductEntity product;
  const _ProductDetailSheet({required this.product});
  @override State<_ProductDetailSheet> createState() => _ProductDetailSheetState();
}

class _ProductDetailSheetState extends State<_ProductDetailSheet> {
  int _tab = 0;
  double _qty = 1;
  String _pay = 'Cash on Delivery';
  final _notesCtrl = TextEditingController();
  final _payOpts = ['Cash on Delivery', 'Bank Transfer', 'PayHere'];
  @override void dispose() { _notesCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final p = widget.product;
    final total = _qty * p.pricePerUnit;
    return Container(
      height: MediaQuery.of(context).size.height * 0.88,
      decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      child: Column(children: [
        Container(margin: const EdgeInsets.only(top: 12), width: 40, height: 4,
            decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
        Padding(padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Row(children: [_tb('Product Info', 0), const SizedBox(width: 8), _tb('Farmer Profile', 1), const SizedBox(width: 8), _tb('Order Now', 2)])),
        const Divider(),
        Expanded(child: SingleChildScrollView(padding: const EdgeInsets.all(16),
            child: _tab == 0 ? _info(p) : _tab == 1 ? _farmer(p) : _order(context, p, total))),
      ]),
    );
  }

  Widget _tb(String label, int idx) => Expanded(child: GestureDetector(
      onTap: () => setState(() => _tab = idx),
      child: Container(padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(color: _tab == idx ? AppColors.primaryGreen : Colors.grey.shade100, borderRadius: BorderRadius.circular(10)),
          child: Text(label, textAlign: TextAlign.center, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
              color: _tab == idx ? Colors.white : AppColors.textSecondary)))));

  Widget _info(ProductEntity p) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: p.imageUrl != null && p.imageUrl!.isNotEmpty
          ? Image.network(
              p.imageUrl!,
              width: double.infinity, height: 180,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _infoPlaceholder(),
            )
          : _infoPlaceholder(),
    ),
    const SizedBox(height: 16),
    Text(p.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
    Text('Category: ${p.category}', style: const TextStyle(color: AppColors.textSecondary)),
    const SizedBox(height: 16),
    Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: const Color(0xFFF8F9FA), borderRadius: BorderRadius.circular(12)),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
          _stat('Price', 'Rs. ${p.pricePerUnit.toStringAsFixed(0)}', '/${p.unit}'),
          Container(height: 40, width: 1, color: Colors.grey.shade200),
          _stat('Stock', '${p.availableQuantity.toStringAsFixed(0)}', p.unit),
          Container(height: 40, width: 1, color: Colors.grey.shade200),
          _stat('Location', p.location, ''),
        ])),
    const SizedBox(height: 16),
    const Text('Description', style: TextStyle(fontWeight: FontWeight.w700)),
    const SizedBox(height: 6),
    Text(p.description.isNotEmpty ? p.description : 'No description provided.',
        style: const TextStyle(color: AppColors.textSecondary, height: 1.5)),
    const SizedBox(height: 24),
    Row(children: [
      Expanded(child: OutlinedButton.icon(icon: const Icon(Icons.person_outline, color: AppColors.primaryGreen),
          label: const Text('Farmer Profile', style: TextStyle(color: AppColors.primaryGreen)),
          style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.primaryGreen),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
          onPressed: () => setState(() => _tab = 1))),
      const SizedBox(width: 12),
      Expanded(child: ElevatedButton.icon(icon: const Icon(Icons.shopping_cart_outlined, color: Colors.white, size: 18),
          label: const Text('Order Now', style: TextStyle(color: Colors.white)),
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryGreen,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
          onPressed: () => setState(() => _tab = 2))),
    ]),
  ]);

  Widget _stat(String label, String value, String sub) => Column(children: [
    Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
    Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
    if (sub.isNotEmpty) Text(sub, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
  ]);

  Widget _infoPlaceholder() => Container(
    width: double.infinity, height: 180,
    decoration: BoxDecoration(
      color: AppColors.primaryGreen.withOpacity(0.08),
      borderRadius: BorderRadius.circular(14),
    ),
    child: const Icon(Icons.eco_outlined, size: 56, color: AppColors.primaryGreen),
  );

  Widget _farmer(ProductEntity p) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Center(child: Column(children: [
      CircleAvatar(radius: 44, backgroundColor: AppColors.primaryGreen.withOpacity(0.15),
          child: Text(p.sellerName.isNotEmpty ? p.sellerName[0].toUpperCase() : '?',
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: AppColors.primaryGreen))),
      const SizedBox(height: 10),
      Text(p.sellerName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
      const SizedBox(height: 4),
      Row(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.location_on_outlined, size: 14, color: AppColors.textSecondary),
        const SizedBox(width: 3),
        Text(p.location, style: const TextStyle(color: AppColors.textSecondary))]),
      const SizedBox(height: 6),
      Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(color: AppColors.primaryGreen.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
          child: const Text('🌾 Verified Farmer', style: TextStyle(fontSize: 12, color: AppColors.primaryGreen, fontWeight: FontWeight.w600))),
    ])),
    const SizedBox(height: 24),
    Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: const Color(0xFFF8F9FA), borderRadius: BorderRadius.circular(12)),
        child: Column(children: [
          _frow(Icons.eco_outlined, 'Listed Crop', p.name), const Divider(height: 16),
          _frow(Icons.attach_money, 'Price', 'Rs. ${p.pricePerUnit.toStringAsFixed(0)}/${p.unit}'), const Divider(height: 16),
          _frow(Icons.inventory_2_outlined, 'Stock', '${p.availableQuantity.toStringAsFixed(0)} ${p.unit} available'),
        ])),
    const SizedBox(height: 24),
    Row(children: [
      Expanded(child: ElevatedButton.icon(
          icon: const Icon(Icons.message_outlined, color: Colors.white, size: 18),
          label: const Text('Message Farmer', style: TextStyle(color: Colors.white)),
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1565C0),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(vertical: 12)),
          onPressed: () {
            final auth = context.read<AuthBloc>().state;
            Navigator.pop(context);
            if (auth is! Authenticated) { Navigator.pushNamed(context, RouteNames.login); return; }
            Navigator.pushNamed(context, RouteNames.messagesList);
          })),
      const SizedBox(width: 12),
      Expanded(child: ElevatedButton.icon(
          icon: const Icon(Icons.shopping_cart_outlined, color: Colors.white, size: 18),
          label: const Text('Order Now', style: TextStyle(color: Colors.white)),
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryGreen,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(vertical: 12)),
          onPressed: () => setState(() => _tab = 2))),
    ]),
  ]);

  Widget _frow(IconData icon, String label, String value) => Row(children: [
    Icon(icon, color: AppColors.primaryGreen, size: 18), const SizedBox(width: 10),
    Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)), const Spacer(),
    Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
  ]);

  Widget _order(BuildContext context, ProductEntity p, double total) {
    final auth = context.read<AuthBloc>().state;
    if (auth is! Authenticated) {
      return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.lock_outline, size: 48, color: AppColors.textSecondary),
        const SizedBox(height: 12),
        const Text('Sign in to place orders', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 20),
        ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryGreen),
            onPressed: () { Navigator.pop(context); Navigator.pushNamed(context, RouteNames.login); },
            child: const Text('Sign In', style: TextStyle(color: Colors.white))),
      ]));
    }
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Ordering: ${p.name}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
      Text('From ${p.sellerName} · ${p.location}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
      const SizedBox(height: 20),
      const Text('Quantity', style: TextStyle(fontWeight: FontWeight.w600)),
      const SizedBox(height: 8),
      Row(children: [
        IconButton(onPressed: () { if (_qty > 1) setState(() => _qty--); },
            icon: const Icon(Icons.remove_circle_outline, color: AppColors.primaryGreen)),
        Expanded(child: Slider(value: _qty, min: 1, max: p.availableQuantity.clamp(1, 500),
            divisions: p.availableQuantity.clamp(1, 500).toInt() - 1,
            activeColor: AppColors.primaryGreen,
            label: '${_qty.toStringAsFixed(0)} ${p.unit}',
            onChanged: (v) => setState(() => _qty = v.roundToDouble()))),
        IconButton(onPressed: () { if (_qty < p.availableQuantity) setState(() => _qty++); },
            icon: const Icon(Icons.add_circle_outline, color: AppColors.primaryGreen)),
        SizedBox(width: 56, child: Text('${_qty.toStringAsFixed(0)} ${p.unit}',
            style: const TextStyle(fontWeight: FontWeight.w600))),
      ]),
      Container(padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: AppColors.primaryGreen.withOpacity(0.06), borderRadius: BorderRadius.circular(12)),
          child: Column(children: [
            _pr('Unit Price', 'Rs. ${p.pricePerUnit.toStringAsFixed(0)}/${p.unit}'),
            const SizedBox(height: 6),
            _pr('Quantity', '${_qty.toStringAsFixed(0)} ${p.unit}'),
            const Divider(height: 16),
            _pr('Total', 'Rs. ${total.toStringAsFixed(0)}', bold: true, color: AppColors.primaryGreen),
          ])),
      const SizedBox(height: 16),
      const Text('Payment Method', style: TextStyle(fontWeight: FontWeight.w600)),
      const SizedBox(height: 8),
      ..._payOpts.map((o) => RadioListTile<String>(value: o, groupValue: _pay,
          title: Text(o, style: const TextStyle(fontSize: 14)),
          activeColor: AppColors.primaryGreen, contentPadding: EdgeInsets.zero,
          onChanged: (v) => setState(() => _pay = v!))),
      const SizedBox(height: 8),
      TextField(controller: _notesCtrl, maxLines: 2,
          decoration: InputDecoration(labelText: 'Delivery notes (optional)',
            hintText: 'e.g. Deliver to Colombo by Friday',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.primaryGreen, width: 2)))),
      const SizedBox(height: 24),
      SizedBox(width: double.infinity, child: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryGreen,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
        onPressed: () {
          final order = OrderEntity(id: '', productId: p.id, productName: p.name,
              buyerId: auth.uid, buyerName: auth.displayName ?? 'Buyer',
              sellerId: p.sellerId, sellerName: p.sellerName,
              quantity: _qty, unit: p.unit, pricePerUnit: p.pricePerUnit, totalPrice: total,
              status: 'pending', notes: _notesCtrl.text.trim().isNotEmpty ? _notesCtrl.text.trim() : null,
              location: p.location, createdAt: DateTime.now(), updatedAt: DateTime.now());
          context.read<MarketplaceBloc>().add(PlaceOrderEvent(order: order));
          Navigator.pop(context);
        },
        child: Text('Confirm Order · Rs. ${total.toStringAsFixed(0)}',
            style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700)),
      )),
    ]);
  }

  Widget _pr(String label, String value, {bool bold = false, Color? color}) => Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
        Text(value, style: TextStyle(fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
            fontSize: bold ? 16 : 13, color: color ?? AppColors.textPrimary)),
      ]);
}
