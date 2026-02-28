// lib/features/analytics/domain/repositories/analytics_repository.dart
import '../entities/analytics.dart';

abstract class AnalyticsRepository {
  Future<Analytics> getAnalytics();
}
