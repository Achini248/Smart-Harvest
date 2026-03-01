import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/price_repository.dart';

class GetPriceTrendsUseCase {
  final PriceRepository repository;

  const GetPriceTrendsUseCase(this.repository);

  // Return type එක Map එකක් විදිහට වෙනස් කළා
  Future<Either<Failure, Map<DateTime, double>>> call(String productName) async {
    return await repository.getPriceTrends(productName);
  }
}