// lib/features/analytics/data/repositories/analytics_repository_impl.dart
import '../../domain/entities/analytics.dart';
import '../../domain/repositories/analytics_repository.dart';
import '../datasources/analytics_remote_datasource.dart';

class AnalyticsRepositoryImpl implements AnalyticsRepository {
  final AnalyticsRemoteDataSource remoteDataSource;

  AnalyticsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Analytics> getAnalytics() async {
    try {
      final model = await remoteDataSource.getAnalytics();
      return model;
    } catch (e) {
      rethrow;
    }
  }
}
