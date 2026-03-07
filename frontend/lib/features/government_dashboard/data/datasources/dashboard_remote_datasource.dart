import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/dashboard_stats_model.dart';

abstract class DashboardRemoteDataSource {
  Future<DashboardStatsModel> getDashboardStats();
  Stream<DashboardStatsModel> watchDashboardStats();
}

class DashboardRemoteDataSourceImpl implements DashboardRemoteDataSource {
  final FirebaseFirestore firestore;
  static const String collectionName = 'dashboard_stats';
  static const String docId = 'national';

  DashboardRemoteDataSourceImpl({FirebaseFirestore? firestore})
      : firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<DashboardStatsModel> getDashboardStats() async {
    try {
      final doc = await firestore.collection(collectionName).doc(docId).get();
      if (!doc.exists) {
        // Return mock data if no Firestore document
        return _getMockData();
      }
      return DashboardStatsModel.fromFirestore(doc);
    } catch (e) {
      // Fallback to mock data on error
      return _getMockData();
    }
  }

  @override
  Stream<DashboardStatsModel> watchDashboardStats() {
    return firestore
        .collection(collectionName)
        .doc(docId)
        .snapshots()
        .asyncMap((doc) async {
      if (!doc.exists) return _getMockData();
      return DashboardStatsModel.fromFirestore(doc);
    }).handleError((_) => Stream.value(_getMockData()));
  }

  DashboardStatsModel _getMockData() {
    return const DashboardStatsModel(
      totalFarmers: 12456,
      totalCrops: 45230,
      totalOrders: 2340,
      totalRevenue: 12500000,
      surplusRegions: 12,
      shortageRegions: 3,
      nationalSurplusIndex: 12.4,
      cropDistribution: {'Rice': 45000, 'Vegetables': 2300, 'Fruits': 1200},
    );
  }
}
