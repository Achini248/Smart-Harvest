import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/price_repository.dart';

class GetPriceTrendsUseCase {
  final PriceRepository repository;
  const GetPriceTrendsUseCase(this.repository);

  Future<Either<Failure, Map<DateTime, double>>> call(String productName) async {
    try {
      final result = await repository.getPriceTrends(productName);
      return Right(result);
    } catch (e) {
      // මෙතන message එකක් ඇතුළත් කළා
      return const Left(ServerFailure(message: 'Server error occurred')); 
    }
  }
}