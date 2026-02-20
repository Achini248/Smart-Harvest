import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../bloc/weather_bloc.dart';
import '../bloc/weather_event.dart';
import '../bloc/weather_state.dart';
import '../widgets/weather_card.dart';
import '../domain/entities/weather.dart';

class WeatherPage extends StatefulWidget {
  const WeatherPage({super.key});

  @override
  State<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  @override
  void initState() {
    super.initState();
    context.read<WeatherBloc>().add(LoadWeatherEvent('Negombo'));
  }

  IconData _weatherIcon(String condition) {
    switch (condition.toLowerCase()) {
      case 'sunny': return Icons.wb_sunny_rounded;
      case 'rainy': return Icons.umbrella_rounded;
      case 'cloudy': return Icons.cloud_rounded;
      default: return Icons.cloud_queue_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: Text('Weather', style: AppTextStyles.heading2),
        backgroundColor: AppColors.cardBackground,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<WeatherBloc>().add(LoadWeatherEvent('Negombo')),
          ),
        ],
      ),
      body: BlocBuilder<WeatherBloc, WeatherState>(
        builder: (context, state) {
          if (state is WeatherLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is WeatherError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.error_outline, color: AppColors.error, size: 48),
                  const SizedBox(height: 8),
                  Text(state.message),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () => context.read<WeatherBloc>().add(LoadWeatherEvent('Negombo')),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          if (state is WeatherLoaded) {
            final w = state.weather;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Main weather card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF1565C0), Color(0xFF42A5F5)],
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.location_on, color: AppColors.white, size: 16),
                            const SizedBox(width: 4),
                            Text(w.location,
                                style: AppTextStyles.bodyText.copyWith(color: AppColors.white)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${w.temperatureC.toStringAsFixed(0)}°C',
                                style: const TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 56,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white)),
                            Icon(_weatherIcon(w.condition), size: 72, color: AppColors.white),
                          ],
                        ),
                        Text(w.condition,
                            style: AppTextStyles.heading2.copyWith(color: AppColors.white)),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _WeatherStat(icon: Icons.water_drop_outlined, label: 'Humidity', value: '${w.humidity}%'),
                            _WeatherStat(icon: Icons.air, label: 'Wind', value: '${w.windSpeedKmh.toStringAsFixed(0)} km/h'),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text('5-Day Forecast', style: AppTextStyles.heading2),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 110,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: w.forecast.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemBuilder: (context, i) => WeatherCard(forecast: w.forecast[i]),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Farming advice card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Color.alphaBlend(AppColors.warning.withValues(alpha: 0.1), AppColors.cardBackground),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Color.alphaBlend(AppColors.warning.withValues(alpha: 0.4), AppColors.cardBackground)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.tips_and_updates, color: AppColors.warning),
                            const SizedBox(width: 8),
                            Text('Farming Advice',
                                style: AppTextStyles.bodyText.copyWith(
                                    fontWeight: FontWeight.w600, color: AppColors.warning)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Rain expected Tuesday — consider harvesting leafy crops before then to avoid moisture damage.',
                          style: AppTextStyles.bodyText,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _WeatherStat extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _WeatherStat({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.white, size: 18),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: Colors.white, fontSize: 11)),
            Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
          ],
        ),
      ],
    );
  }
}
