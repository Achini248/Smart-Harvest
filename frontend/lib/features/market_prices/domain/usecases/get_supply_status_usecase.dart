import '../entities/price.dart';
import '../repositories/price_repository.dart';

class GetSupplyStatusUseCase {
  final PriceRepository repository;
  const GetSupplyStatusUseCase(this.repository);

  Future<SupplyAnalyticsEntity> call() => repository.getSupplyStatus();
}
