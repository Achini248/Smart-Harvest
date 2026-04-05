// lib/features/government_dashboard/data/datasources/dashboard_remote_datasource.dart
// Computes national KPIs directly from Firestore — works on all platforms.

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/dashboard_stats_model.dart';

abstract class DashboardRemoteDataSource {
  Future<DashboardStatsModel> getDashboardStats();
  Stream<DashboardStatsModel> watchDashboardStats();
}

class DashboardRemoteDataSourceImpl implements DashboardRemoteDataSource {
  final FirebaseFirestore _db;

  DashboardRemoteDataSourceImpl({
    FirebaseFirestore? firestore,
    dynamic apiClient,            // kept for DI compat — no longer used
  }) : _db = firestore ?? FirebaseFirestore.instance;

  @override
  Future<DashboardStatsModel> getDashboardStats() async {
    try {
      // 1. Try the cached national document (written by seed.py / backend)
      final cached = await _db.collection('dashboard_stats').doc('national').get();
      if (cached.exists) {
        return DashboardStatsModel.fromFirestore(cached);
      }
    } catch (_) {}

    // 2. Compute live from Firestore collections
    try {
      return await _computeFromCollections();
    } catch (_) {}

    // 3. Absolute fallback — zeroed model so the screen still renders
    return const DashboardStatsModel(
      totalFarmers: 0, totalCrops: 0, totalOrders: 0,
      totalRevenue: 0, surplusRegions: 0, shortageRegions: 0,
      nationalSurplusIndex: 0, cropDistribution: {},
    );
  }

  Future<DashboardStatsModel> _computeFromCollections() async {
    // Count farmers (users with role=farmer)
    final usersSnap = await _db.collection('users')
        .where('role', isEqualTo: 'farmer').get();
    final totalFarmers = usersSnap.docs.length;

    // Count crops
    final cropsSnap  = await _db.collection('crops').get();
    final totalCrops = cropsSnap.docs.length;

    // Crop distribution by name
    final cropDist = <String, double>{};
    for (final d in cropsSnap.docs) {
      final data = d.data();
      final name = data['name'] as String? ?? 'Other';
      final qty  = (data['quantity'] as num?)?.toDouble() ?? 0;
      cropDist[name] = (cropDist[name] ?? 0) + qty;
    }

    // Orders & revenue
    final ordersSnap  = await _db.collection('orders').get();
    int    totalOrders = 0;
    double totalRevenue = 0;
    for (final d in ordersSnap.docs) {
      final data   = d.data();
      final status = data['status'] as String? ?? '';
      if (status == 'accepted' || status == 'delivered') {
        totalOrders++;
        totalRevenue += (data['totalPrice'] as num?)?.toDouble() ?? 0;
      }
    }

    // Surplus/shortage from latest daily_prices
    int surplus = 0, shortage = 0;
    try {
      final today = DateTime.now();
      String? date;
      for (var i = 0; i < 30; i++) {
        final d = today.subtract(Duration(days: i));
        final s = '${d.year}-'
            '${d.month.toString().padLeft(2,'0')}-'
            '${d.day.toString().padLeft(2,'0')}';
        final probe = await _db.collection('daily_prices')
            .where('date', isEqualTo: s).limit(1).get();
        if (probe.docs.isNotEmpty) { date = s; break; }
      }
      if (date != null) {
        final priceSnap = await _db.collection('daily_prices')
            .where('date', isEqualTo: date).get();
        for (final d in priceSnap.docs) {
          final data = d.data();
          if (data['isSurplus']  == true) surplus++;
          if (data['isShortage'] == true) shortage++;
        }
      }
    } catch (_) {}

    final total = surplus + shortage;
    final surplusIndex = total > 0
        ? ((surplus / total) * 100).clamp(0, 100).toDouble()
        : 100.0;

    return DashboardStatsModel(
      totalFarmers:         totalFarmers,
      totalCrops:           totalCrops,
      totalOrders:          totalOrders,
      totalRevenue:         totalRevenue,
      surplusRegions:       surplus,
      shortageRegions:      shortage,
      nationalSurplusIndex: surplusIndex,
      cropDistribution:     cropDist,
    );
  }

  @override
  Stream<DashboardStatsModel> watchDashboardStats() {
    return _db.collection('dashboard_stats').doc('national')
        .snapshots()
        .asyncMap((doc) async {
      if (doc.exists) return DashboardStatsModel.fromFirestore(doc);
      return getDashboardStats();
    }).handleError((_) async => getDashboardStats());
  }
}
