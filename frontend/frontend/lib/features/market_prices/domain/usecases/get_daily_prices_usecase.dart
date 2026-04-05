import '../entities/price.dart';
import '../repositories/price_repository.dart';

class GetDailyPricesUseCase {
  final PriceRepository repository;
  const GetDailyPricesUseCase(this.repository);

  Future<List<PriceEntity>> call({String? district}) =>
      repository.getDailyPrices(district: district);
}
