// lib/features/analytics/domain/usecases/get_analytics_usecase.dart
import '../entities/analytics.dart';
import '../repositories/analytics_repository.dart';

class GetAnalyticsUseCase {
  final AnalyticsRepository repository;

  GetAnalyticsUseCase(this.repository);

  Future<Analytics> call() => repository.getAnalytics();
}
