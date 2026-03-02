import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/dashboard_stats.dart';
import '../bloc/dashboard_bloc.dart';
import '../bloc/dashboard_event.dart';
import '../bloc/dashboard_state.dart';
import '../widgets/stats_card.dart';
import '../widgets/surplus_shortage_map.dart';

class GovernmentDashboardPage extends StatefulWidget {
  const GovernmentDashboardPage({super.key});

  @override
  State<GovernmentDashboardPage> createState() => _GovernmentDashboardPageState();
}

class _GovernmentDashboardPageState extends State<GovernmentDashboardPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardBloc>().add(const LoadDashboardEvent());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: const Text('Government Dashboard', style: TextStyle(fontWeight: FontWeight.w700)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          BlocBuilder<DashboardBloc, DashboardState>(
            builder: (context, state) {
              return IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () => context.read<DashboardBloc>().add(const RefreshDashboardEvent()),
              );
            },
          ),
        ],
      ),
      body: BlocConsumer<DashboardBloc, DashboardState>(
        listener: (context, state) {
          if (state is DashboardError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.red),
            );
          }
        },
        builder: (context, state) {
          if (state is DashboardLoading) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primaryGreen));
          }
          
          if (state is DashboardError) {
            return _buildErrorState(state.message);
          }

          if (state is DashboardLoaded) {
            return RefreshIndicator(
              onRefresh: () async {
                context.read<DashboardBloc>().add(const RefreshDashboardEvent());
              },
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Agriculture Overview', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 24),
                    Row(children: [
                      Expanded(child: StatsCard(title: 'Farmers', value: state.stats.totalFarmers.toString(), icon: Icons.people_outline)),
                      const SizedBox(width: 16),
                      Expanded(child: StatsCard(title: 'Crops', value: state.stats.totalCrops.toString(), icon: Icons.agriculture_outlined)),
                    ]),
                    const SizedBox(height: 16),
                    Row(children: [
                      Expanded(child: StatsCard(title: 'Orders', value: state.stats.totalOrders.toString(), icon: Icons.shopping_cart_outlined)),
                      const SizedBox(width: 16),
                      Expanded(child: StatsCard(title: 'Revenue', value: 'LKR ${state.stats.totalRevenue.toStringAsFixed(0)}', icon: Icons.attach_money)),
                    ]),
                    const SizedBox(height: 24),
                    _buildSurplusCard(state.stats),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton.icon(
                        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SurplusShortageMap())),
                        icon: const Icon(Icons.map),
                        label: const Text('View Surplus/Shortage Map'),
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryGreen),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return _buildEmptyState();
        },
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: AppColors.error),
          const SizedBox(height: 16),
          Padding(padding: const EdgeInsets.symmetric(horizontal: 40), child: Text(message, textAlign: TextAlign.center)),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => context.read<DashboardBloc>().add(const LoadDashboardEvent()),
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(child: Text('No dashboard data available'));
  }

  Widget _buildSurplusCard(DashboardStats stats) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [AppColors.primaryGreen.withValues(alpha: 0.1), Colors.transparent]),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primaryGreen.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.trending_up, color: AppColors.primaryGreen, size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('National Surplus Index', style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
                Text('${stats.nationalSurplusIndex.toStringAsFixed(1)}%', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                Text('${stats.surplusRegions} Surplus | ${stats.shortageRegions} Shortage', style: TextStyle(color: AppColors.primaryGreen)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
