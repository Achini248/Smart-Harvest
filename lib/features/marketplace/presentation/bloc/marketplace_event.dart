import 'package:equatable/equatable.dart';
import '../../domain/entities/order.dart';
import '../../domain/entities/seller.dart';

abstract class MarketplaceEvent extends Equatable {
  const MarketplaceEvent();

  @override
  List<Object?> get props => [];
}

class LoadProductsEvent extends MarketplaceEvent {
  final String? category;
  final String? searchQuery;
  const LoadProductsEvent({this.category, this.searchQuery});

  @override
  List<Object?> get props => [category, searchQuery];
}

class SearchProductsEvent extends MarketplaceEvent {
  final String query;
  const SearchProductsEvent({required this.query});

  @override
  List<Object?> get props => [query];
}

class FilterByCategoryEvent extends MarketplaceEvent {
  final String? category;
  const FilterByCategoryEvent({this.category});

  @override
  List<Object?> get props => [category];
}

class SelectProductEvent extends MarketplaceEvent {
  final ProductEntity product;
  const SelectProductEvent({required this.product});

  @override
  List<Object?> get props => [product];
}

class PlaceOrderEvent extends MarketplaceEvent {
  final OrderEntity order;
  const PlaceOrderEvent({required this.order});

  @override
  List<Object?> get props => [order];
}

class LoadMyOrdersEvent extends MarketplaceEvent {
  final String buyerId;
  const LoadMyOrdersEvent({required this.buyerId});

  @override
  List<Object?> get props => [buyerId];
}

class LoadIncomingOrdersEvent extends MarketplaceEvent {
  final String sellerId;
  const LoadIncomingOrdersEvent({required this.sellerId});

  @override
  List<Object?> get props => [sellerId];
}

class UpdateOrderStatusEvent extends MarketplaceEvent {
  final String orderId;
  final String status;
  const UpdateOrderStatusEvent({required this.orderId, required this.status});

  @override
  List<Object?> get props => [orderId, status];
}

class ClearMarketplaceErrorEvent extends MarketplaceEvent {
  const ClearMarketplaceErrorEvent();
}
