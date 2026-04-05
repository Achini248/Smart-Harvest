// lib/features/market_prices/data/repositories/price_repository_impl.dart
import '../../domain/entities/price.dart';
import '../../domain/repositories/price_repository.dart';
import '../datasources/price_remote_datasource.dart';

class PriceRepositoryImpl implements PriceRepository {
  final PriceRemoteDataSource remoteDataSource;

  PriceRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<PriceEntity>> getDailyPrices({String? district}) =>
      remoteDataSource.getDailyPrices(district: district);

  @override
  Future<List<PriceHistoryPoint>> getPriceHistory(
          String cropName, {int days = 30}) =>
      remoteDataSource.getPriceHistory(cropName, days: days);

  @override
  Future<SupplyAnalyticsEntity> getSupplyStatus() =>
      remoteDataSource.getSupplyStatus();

  @override
  Future<ForecastEntity> getForecast(String cropName) =>
      remoteDataSource.getForecast(cropName);
}
