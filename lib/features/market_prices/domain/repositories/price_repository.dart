// lib/features/market_prices/domain/repositories/price_repository.dart
import '../entities/price.dart';

abstract class PriceRepository {
  
Future<List<PriceEntity>> getDailyPrices(); 
  /// Returns map of date -> price for a given product.
  Future<Map<DateTime, double>> getPriceTrends(String productName);
}
