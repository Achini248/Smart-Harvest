import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/price.dart';
import '../repositories/price_repository.dart';

class GetPriceTrendsUseCase {
  final PriceRepository repository;

  GetPriceTrendsUseCase(this.repository);

  // බෝගයේ නම (productName) ලබාදී මිල වෙනස්වීමේ දත්ත ලබාගැනීම
  Future<Either<Failure, List<PriceEntity>>> call(String productName) async {
    return await repository.getPriceTrends(productName);
  }
}