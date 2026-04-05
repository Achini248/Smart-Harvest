import '../entities/dashboard_stats.dart';
import '../repositories/dashboard_repository.dart';

class GetDashboardStatsUseCase {
  final DashboardRepository repository;

  const GetDashboardStatsUseCase(this.repository);

  Future<DashboardStats> call() => repository.getDashboardStats();
}
