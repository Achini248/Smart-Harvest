// lib/features/market_prices/domain/usecases/get_daily_prices_usecase.dart
import '../entities/price.dart';
import '../repositories/price_repository.dart';

class GetDailyPricesUseCase {
  final PriceRepository repository;

  GetDailyPricesUseCase(this.repository);

 Future<List<PriceEntity>> call() {
    return repository.getDailyPrices();
  }
}
