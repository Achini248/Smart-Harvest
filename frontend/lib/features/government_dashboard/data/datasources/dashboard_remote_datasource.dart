// lib/features/government_dashboard/data/datasources/dashboard_remote_datasource.dart
// MODIFIED: tries Flask /api/dashboard first (live computed stats),
// falls back to Firestore cached document if Flask is unreachable.

import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/dashboard_stats_model.dart';

abstract class DashboardRemoteDataSource {
  Future<DashboardStatsModel> getDashboardStats();
  Stream<DashboardStatsModel> watchDashboardStats();
}

class DashboardRemoteDataSourceImpl implements DashboardRemoteDataSource {
  final FirebaseFirestore firestore;
  final ApiClient _api;

  static const String _collection = 'dashboard_stats';
  static const String _docId      = 'national';

  DashboardRemoteDataSourceImpl({
    FirebaseFirestore? firestore,
    ApiClient? apiClient,
  })  : firestore = firestore ?? FirebaseFirestore.instance,
        _api      = apiClient  ?? ApiClient.instance;

  // ── Primary: Flask API ────────────────────────────────────────────────────
  @override
  Future<DashboardStatsModel> getDashboardStats() async {
    // 1. Try Flask backend — triggers DashboardService which recomputes from
    //    Firestore and caches the result in dashboard_stats/national.
    try {
      final data =
          await _api.get(ApiConstants.dashboard);
      return DashboardStatsModel.fromApi(data as Map<String, dynamic>);
    } catch (_) {
      // Flask unreachable → fall back to cached Firestore document
    }

    // 2. Fall back to Firestore cached document
    try {
      final doc = await firestore
          .collection(_collection)
          .doc(_docId)
          .get();
      if (doc.exists) {
        return DashboardStatsModel.fromFirestore(doc);
      }
    } catch (_) {}

    // 3. Last resort: return zeroed model so UI can still render
    return const DashboardStatsModel(
      totalFarmers:        0,
      totalCrops:          0,
      totalOrders:         0,
      totalRevenue:        0,
      surplusRegions:      0,
      shortageRegions:     0,
      nationalSurplusIndex: 0,
      cropDistribution:   {},
    );
  }

  // ── Realtime stream: Firestore only ───────────────────────────────────────
  @override
  Stream<DashboardStatsModel> watchDashboardStats() {
    return firestore
        .collection(_collection)
        .doc(_docId)
        .snapshots()
        .asyncMap((doc) async {
      if (!doc.exists) return await getDashboardStats();
      return DashboardStatsModel.fromFirestore(doc);
    }).handleError((_) async => getDashboardStats());
  }
}
