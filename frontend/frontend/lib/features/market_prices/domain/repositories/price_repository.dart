// lib/features/market_prices/domain/repositories/price_repository.dart
import '../entities/price.dart';

abstract class PriceRepository {
  Future<List<PriceEntity>>    getDailyPrices({String? district});
  Future<List<PriceHistoryPoint>> getPriceHistory(String cropName, {int days = 30});
  Future<SupplyAnalyticsEntity>   getSupplyStatus();
  Future<ForecastEntity>          getForecast(String cropName);
}
