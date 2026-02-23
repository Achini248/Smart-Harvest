import '../../domain/entities/dashboard_stats.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../datasources/dashboard_remote_datasource.dart';
import '../models/dashboard_stats_model.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  final DashboardRemoteDataSource remoteDataSource;

  const DashboardRepositoryImpl({required this.remoteDataSource});

  @override
  Future<DashboardStats> getDashboardStats() async {
    try {
      final model = await remoteDataSource.getDashboardStats();
      return model;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Stream<DashboardStats> watchDashboardStats() {
    return remoteDataSource.watchDashboardStats();
  }
}
