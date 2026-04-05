// lib/features/government_dashboard/data/models/dashboard_stats_model.dart
// MODIFIED: added fromApi() factory for Flask /api/dashboard response.
// Preserves existing fromFirestore() and toFirestore() methods unchanged.

import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/dashboard_stats.dart';

class DashboardStatsModel extends DashboardStats {
  const DashboardStatsModel({
    required super.totalFarmers,
    required super.totalCrops,
    required super.totalOrders,
    required super.totalRevenue,
    required super.surplusRegions,
    required super.shortageRegions,
    required super.nationalSurplusIndex,
    super.cropDistribution,
  });

  // ── From Flask /api/dashboard response ────────────────────────────────────
  factory DashboardStatsModel.fromApi(Map<String, dynamic> data) {
    return DashboardStatsModel(
      totalFarmers:         _toInt(data['totalFarmers']),
      totalCrops:           _toInt(data['totalCrops']),
      totalOrders:          _toInt(data['totalOrders']),
      totalRevenue:         _toDouble(data['totalRevenue']),
      surplusRegions:       _toInt(data['surplusRegions']),
      shortageRegions:      _toInt(data['shortageRegions']),
      nationalSurplusIndex: _toDouble(data['nationalSurplusIndex']),
      cropDistribution:     _toCropDist(data['cropDistribution']),
    );
  }

  // ── From Firestore document (existing — unchanged) ────────────────────────
  factory DashboardStatsModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return DashboardStatsModel(
      totalFarmers:         _toInt(data['totalFarmers']),
      totalCrops:           _toInt(data['totalCrops']),
      totalOrders:          _toInt(data['totalOrders']),
      totalRevenue:         _toDouble(data['totalRevenue']),
      surplusRegions:       _toInt(data['surplusRegions']),
      shortageRegions:      _toInt(data['shortageRegions']),
      nationalSurplusIndex: _toDouble(data['nationalSurplusIndex']),
      cropDistribution:     _toCropDist(data['cropDistribution']),
    );
  }

  // ── To Firestore (existing — unchanged) ──────────────────────────────────
  Map<String, dynamic> toFirestore() => {
        'totalFarmers':         totalFarmers,
        'totalCrops':           totalCrops,
        'totalOrders':          totalOrders,
        'totalRevenue':         totalRevenue,
        'surplusRegions':       surplusRegions,
        'shortageRegions':      shortageRegions,
        'nationalSurplusIndex': nationalSurplusIndex,
        'cropDistribution':     cropDistribution,
        'updatedAt':            FieldValue.serverTimestamp(),
      };

  // ── Helpers ───────────────────────────────────────────────────────────────
  static int _toInt(dynamic v) =>
      v == null ? 0 : (v as num).toInt();

  static double _toDouble(dynamic v) =>
      v == null ? 0.0 : (v as num).toDouble();

  static Map<String, dynamic> _toCropDist(dynamic raw) {
    if (raw == null) return {};
    if (raw is Map) return Map<String, dynamic>.from(raw);
    return {};
  }
}
