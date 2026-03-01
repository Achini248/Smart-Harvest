// lib/features/market_prices/data/repositories/price_repository_impl.dart
import '../../domain/entities/price.dart';
import '../../domain/repositories/price_repository.dart';
import '../datasources/price_remote_datasource.dart';

class PriceRepositoryImpl implements PriceRepository {
  final PriceRemoteDataSource remoteDataSource;

  PriceRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<PriceEntity>> getDailyPrices() async {
    try {
      final models = await remoteDataSource.getDailyPrices();
      return models;
    } catch (e) {
      // In a real app you might throw domain-specific exceptions.
      rethrow;
    }
  }

  @override
  Future<Map<DateTime, double>> getPriceTrends(String productName) async {
    try {
      return await remoteDataSource.getPriceTrends(productName);
    } catch (e) {
      rethrow;
    }
  }
}
