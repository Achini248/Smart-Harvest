import '../entities/dashboard_stats.dart';

abstract class DashboardRepository {
  Future<DashboardStats> getDashboardStats();
  Stream<DashboardStats> watchDashboardStats();
}
