import '../../domain/entities/price.dart';
import '../../domain/repositories/price_repository.dart';
import '../datasources/price_remote_datasource.dart';

class PriceRepositoryImpl implements PriceRepository {
  final PriceRemoteDataSource remoteDataSource;

  PriceRepositoryImpl({required this.remoteDataSource});

  @override
  // මෙතන PriceEntity නම නිවැරදිව තියෙනවාද බලන්න (domain/entities/price.dart බලන්න)
  Future<List<PriceEntity>> getDailyPrices() async {
    try {
      final models = await remoteDataSource.getDailyPrices();
      // Models ටික Entity list එකක් විදිහට return කරනවා
      return models;
    } catch (e) {
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