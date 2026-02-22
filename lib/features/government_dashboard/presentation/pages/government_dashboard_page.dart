import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../widgets/stats_card.dart';
import '../widgets/surplus_shortage_map.dart';

class GovernmentDashboardPage extends StatelessWidget {
  const GovernmentDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Government Dashboard', style: TextStyle(fontWeight: FontWeight.w700)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Agriculture Overview',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 24),
            
            // Stats Row 1
            const Row(
              children: [
                Expanded(child: StatsCard(title: 'Farmers', value: '12.4K', icon: Icons.people)),
                SizedBox(width: 16),
                Expanded(child: StatsCard(title: 'Crops', value: '45K', icon: Icons.agriculture)),
              ],
            ),
            const SizedBox(height: 16),
            
            // Stats Row 2
            const Row(
              children: [
                Expanded(child: StatsCard(title: 'Orders', value: '2.3K', icon: Icons.shopping_cart)),
                SizedBox(width: 16),
                Expanded(child: StatsCard(title: 'Revenue', value: 'LKR 12.5M', icon: Icons.attach_money)),
              ],
            ),
            const SizedBox(height: 24),
            
            // Surplus Indicator
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [
                  AppColors.primaryGreen.withOpacity(0.1),
                  Colors.transparent,
                ]),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.primaryGreen.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.trending_up, color: AppColors.primaryGreen, size: 32),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('National Surplus', style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
                      const Text('Rice +15% | Veggies +8%', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            const SurplusShortageMap(),
            const SizedBox(height: 24),
            
            const Text(
              'Recent Trends',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 16),
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20)],
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.show_chart, size: 64, color: AppColors.textSecondary),
                    const SizedBox(height: 16),
                    const Text('Analytics Charts\nComing Soon', textAlign: TextAlign.center),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
