import '../entities/price.dart';
import '../repositories/price_repository.dart';

class GetForecastUseCase {
  final PriceRepository repository;
  const GetForecastUseCase(this.repository);

  Future<ForecastEntity> call(String cropName) =>
      repository.getForecast(cropName);
}
