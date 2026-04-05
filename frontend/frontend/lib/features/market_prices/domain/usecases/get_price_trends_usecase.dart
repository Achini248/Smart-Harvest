import '../entities/price.dart';
import '../repositories/price_repository.dart';

class GetPriceHistoryUseCase {
  final PriceRepository repository;
  const GetPriceHistoryUseCase(this.repository);

  Future<List<PriceHistoryPoint>> call(String cropName, {int days = 30}) =>
      repository.getPriceHistory(cropName, days: days);
}
