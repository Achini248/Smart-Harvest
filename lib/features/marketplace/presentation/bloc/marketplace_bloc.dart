import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/browse_products_usecase.dart';
import '../../domain/usecases/get_orders_usecase.dart';
import '../../domain/usecases/place_order_usecase.dart';
import '../../domain/repositories/marketplace_repository.dart';
import 'marketplace_event.dart';
import 'marketplace_state.dart';

class MarketplaceBloc extends Bloc<MarketplaceEvent, MarketplaceState> {
  final BrowseProductsUseCase _browseProductsUseCase;
  final PlaceOrderUseCase _placeOrderUseCase;
  final GetOrdersUseCase _getOrdersUseCase;
  final MarketplaceRepository _repository;

  MarketplaceBloc({
    required BrowseProductsUseCase browseProductsUseCase,
    required PlaceOrderUseCase placeOrderUseCase,
    required GetOrdersUseCase getOrdersUseCase,
    required MarketplaceRepository repository,
  })  : _browseProductsUseCase = browseProductsUseCase,
        _placeOrderUseCase = placeOrderUseCase,
        _getOrdersUseCase = getOrdersUseCase,
        _repository = repository,
        super(const MarketplaceInitialState()) {
    on<LoadProductsEvent>(_onLoadProducts);
    on<SearchProductsEvent>(_onSearchProducts);
    on<FilterByCategoryEvent>(_onFilterByCategory);
    on<SelectProductEvent>(_onSelectProduct);
    on<PlaceOrderEvent>(_onPlaceOrder);
    on<LoadMyOrdersEvent>(_onLoadMyOrders);
    on<LoadIncomingOrdersEvent>(_onLoadIncomingOrders);
    on<UpdateOrderStatusEvent>(_onUpdateOrderStatus);
    on<ClearMarketplaceErrorEvent>(_onClearError);
  }

  Future<void> _onLoadProducts(
      LoadProductsEvent event, Emitter<MarketplaceState> emit) async {
    emit(const MarketplaceLoadingState());
    final result = await _browseProductsUseCase(
      BrowseProductsParams(
        category: event.category,
        searchQuery: event.searchQuery,
      ),
    );
    result.fold(
      (f) => emit(MarketplaceErrorState(message: f.message)),
      (products) => products.isEmpty
          ? emit(const MarketplaceEmptyState(
              message: 'No products found in the marketplace.'))
          : emit(ProductsLoadedState(
              products: products,
              activeCategory: event.category,
              activeSearch: event.searchQuery,
            )),
    );
  }

  Future<void> _onSearchProducts(
      SearchProductsEvent event, Emitter<MarketplaceState> emit) async {
    emit(const MarketplaceLoadingState());
    final result = await _browseProductsUseCase(
      BrowseProductsParams(searchQuery: event.query),
    );
    result.fold(
      (f) => emit(MarketplaceErrorState(message: f.message)),
      (products) => products.isEmpty
          ? emit(MarketplaceEmptyState(
              message: 'No products found for "${event.query}"'))
          : emit(ProductsLoadedState(
              products: products,
              activeSearch: event.query,
            )),
    );
  }

  Future<void> _onFilterByCategory(
      FilterByCategoryEvent event, Emitter<MarketplaceState> emit) async {
    emit(const MarketplaceLoadingState());
    final result = await _browseProductsUseCase(
      BrowseProductsParams(category: event.category),
    );
    result.fold(
      (f) => emit(MarketplaceErrorState(message: f.message)),
      (products) => products.isEmpty
          ? const MarketplaceEmptyState(message: 'No products in this category.')
          : emit(ProductsLoadedState(
              products: products,
              activeCategory: event.category,
            )),
    );
  }

  void _onSelectProduct(
      SelectProductEvent event, Emitter<MarketplaceState> emit) {
    emit(ProductSelectedState(product: event.product));
  }

  Future<void> _onPlaceOrder(
      PlaceOrderEvent event, Emitter<MarketplaceState> emit) async {
    emit(const MarketplaceOperationLoadingState());
    final result =
        await _placeOrderUseCase(PlaceOrderParams(order: event.order));
    result.fold(
      (f) => emit(MarketplaceErrorState(message: f.message)),
      (order) => emit(OrderPlacedState(order: order)),
    );
  }

  Future<void> _onLoadMyOrders(
      LoadMyOrdersEvent event, Emitter<MarketplaceState> emit) async {
    emit(const MarketplaceLoadingState());
    final result = await _getOrdersUseCase(
      GetOrdersParams(userId: event.buyerId, isSeller: false),
    );
    result.fold(
      (f) => emit(MarketplaceErrorState(message: f.message)),
      (orders) => orders.isEmpty
          ? const MarketplaceEmptyState(message: 'You have no orders yet.')
          : emit(OrdersLoadedState(orders: orders, isSeller: false)),
    );
  }

  Future<void> _onLoadIncomingOrders(
      LoadIncomingOrdersEvent event, Emitter<MarketplaceState> emit) async {
    emit(const MarketplaceLoadingState());
    final result = await _getOrdersUseCase(
      GetOrdersParams(userId: event.sellerId, isSeller: true),
    );
    result.fold(
      (f) => emit(MarketplaceErrorState(message: f.message)),
      (orders) => orders.isEmpty
          ? const MarketplaceEmptyState(
              message: 'No incoming orders yet.')
          : emit(OrdersLoadedState(orders: orders, isSeller: true)),
    );
  }

  Future<void> _onUpdateOrderStatus(
      UpdateOrderStatusEvent event, Emitter<MarketplaceState> emit) async {
    emit(const MarketplaceOperationLoadingState());
    final result = await _repository.updateOrderStatus(
      orderId: event.orderId,
      status: event.status,
    );
    result.fold(
      (f) => emit(MarketplaceErrorState(message: f.message)),
      (order) => emit(OrderStatusUpdatedState(order: order)),
    );
  }

  void _onClearError(
      ClearMarketplaceErrorEvent event, Emitter<MarketplaceState> emit) {
    emit(const MarketplaceInitialState());
  }
}
