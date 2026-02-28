// lib/features/analytics/presentation/pages/analytics_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/datasources/analytics_remote_datasource.dart';
import '../../data/repositories/analytics_repository_impl.dart';
import '../../domain/usecases/get_analytics_usecase.dart';
import '../bloc/analytics_bloc.dart';
import '../bloc/analytics_event.dart';
import ../bloc/analytics_state.dart';
import '../widgets/chart_widget.dart';

class AnalyticsPage extends StatelessWidget {
  const AnalyticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AnalyticsBloc(
        getAnalytics: GetAnalyticsUseCase(
          AnalyticsRepositoryImpl(
            remoteDataSource: AnalyticsRemoteDataSourceImpl(),
          ),
        ),
      )..add(const LoadAnalyticsEvent()),
      child: const _AnalyticsView(),
    );
  }
}

class _AnalyticsView extends StatelessWidget {
  const _AnalyticsView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F5F7),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF4F5F7),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              size: 18, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          'Analytics',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 18,
            color: Colors.black87,
          ),
        ),
      ),
      body: BlocBuilder<AnalyticsBloc, AnalyticsState>(
        builder: (context, state) {
          if (state.isLoading && state.analytics == null) {
            return const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF7BA53D),
              ),
            );
          }

          if (state.errorMessage != null &&
              state.analytics == null) {
            return _ErrorView(message: state.errorMessage!);
          }

          final analytics = state.analytics;
          if (analytics == null) {
            return const _ErrorView(
                message: 'Analytics not available.');
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            child: Column(
              children: [
                // Responsive grid of cards
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isWide =
                        constraints.maxWidth >= 600;
                    return GridView.count(
                      crossAxisCount: isWide ? 3 : 2,
                      shrinkWrap: true,
                      physics:
                          const NeverScrollableScrollPhysics(),
                      childAspectRatio: 1.5,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      children: [
                        _StatCard(
                          title: 'Total Crops',
                          value: analytics.totalCrops.toString(),
                          icon:
                              Icons.agriculture_outlined,
                          color: const Color(0xFF7BA53D),
                        ),
                        _StatCard(
                          title: 'Total Orders',
                          value: analytics.totalOrders.toString(),
                          icon: Icons.receipt_long_outlined,
                          color: const Color(0xFF2196F3),
                        ),
                        _StatCard(
                          title: 'Total Revenue',
                          value:
                              'Rs. ${analytics.totalRevenue.toStringAsFixed(0)}',
                          icon: Icons.attach_money_outlined,
                          color: const Color(0xFFFFA726),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 24),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Crop Distribution',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: Colors.grey.shade900,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color:
                            Colors.black.withOpacity(0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: ChartWidget(
                    data: analytics.cropDistribution,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;

  const _ErrorView({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline,
                size: 48, color: Colors.redAccent),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: Colors.grey, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
