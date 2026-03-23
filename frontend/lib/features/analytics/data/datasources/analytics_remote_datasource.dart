// lib/features/analytics/data/datasources/analytics_remote_datasource.dart
// MODIFIED: replaced Random() simulation with real Flask API call.
// Calls GET /api/analytics which queries real Firestore data via AnalyticsService.

import '../../../../core/network/api_client.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/analytics_model.dart';

abstract class AnalyticsRemoteDataSource {
  Future<AnalyticsModel> getAnalytics();
}

class AnalyticsRemoteDataSourceImpl implements AnalyticsRemoteDataSource {
  final ApiClient _api;

  AnalyticsRemoteDataSourceImpl({ApiClient? apiClient})
      : _api = apiClient ?? ApiClient.instance;

  @override
  Future<AnalyticsModel> getAnalytics() async {
    final data = await _api.get(ApiConstants.userAnalytics);
    return AnalyticsModel.fromJson(data as Map<String, dynamic>);
  }
}
