import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/price_repository.dart';

class GetPriceTrendsUseCase {
  final PriceRepository repository;
  const GetPriceTrendsUseCase(this.repository);

  Future<Either<Failure, Map<DateTime, double>>> call(String productName) async {
    try {
      final result = await repository.getPriceTrends(productName);
      // Repository එකෙන් කෙලින්ම Map එකක් එනවා නම් ඒක Right() එකක් ඇතුළට දාන්න ඕනේ
      return Right(result);
    } catch (e) {
      return Left(ServerFailure()); // Failure එකක් return කරන්න
    }
  }
}