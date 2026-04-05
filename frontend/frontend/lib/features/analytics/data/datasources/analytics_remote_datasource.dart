// lib/features/analytics/data/datasources/analytics_remote_datasource.dart
// Computes analytics directly from Firestore — works on all platforms.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/analytics_model.dart';

abstract class AnalyticsRemoteDataSource {
  Future<AnalyticsModel> getAnalytics();
}

class AnalyticsRemoteDataSourceImpl implements AnalyticsRemoteDataSource {
  final FirebaseFirestore _db;

  AnalyticsRemoteDataSourceImpl({
    dynamic apiClient,            // kept for DI compat — no longer used
    FirebaseFirestore? firestore,
  }) : _db = firestore ?? FirebaseFirestore.instance;

  @override
  Future<AnalyticsModel> getAnalytics() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null || uid.isEmpty) {
      return const AnalyticsModel(
        totalCrops: 0, totalOrders: 0,
        totalRevenue: 0, cropDistribution: {},
      );
    }

    // Crops owned by this user
    final cropSnap = await _db.collection('crops')
        .where('ownerId', isEqualTo: uid).get();

    int totalCrops = 0;
    final cropDist = <String, double>{};
    for (final doc in cropSnap.docs) {
      final d   = doc.data();
      totalCrops++;
      final name = d['name'] as String? ?? 'Other';
      final qty  = (d['quantity'] as num?)?.toDouble() ?? 0;
      cropDist[name] = (cropDist[name] ?? 0) + qty;
    }

    // Orders where this user is the seller
    final orderSnap = await _db.collection('orders')
        .where('sellerId', isEqualTo: uid).get();

    int    totalOrders  = 0;
    double totalRevenue = 0;
    for (final doc in orderSnap.docs) {
      final d      = doc.data();
      final status = d['status'] as String? ?? '';
      if (status == 'accepted' || status == 'delivered') {
        totalOrders++;
        totalRevenue += (d['totalPrice'] as num?)?.toDouble() ?? 0;
      }
    }

    return AnalyticsModel(
      totalCrops:       totalCrops,
      totalOrders:      totalOrders,
      totalRevenue:     totalRevenue,
      cropDistribution: cropDist,
    );
  }
}
