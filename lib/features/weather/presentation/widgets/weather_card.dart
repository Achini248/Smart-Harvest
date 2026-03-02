import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../domain/entities/weather.dart';

class WeatherCard extends StatelessWidget {
  final WeatherForecast forecast;
  const WeatherCard({super.key, required this.forecast});

  IconData _icon(String c) {
    switch (c.toLowerCase()) {
      case 'sunny': return Icons.wb_sunny_rounded;
      case 'rainy': return Icons.umbrella_rounded;
      default: return Icons.cloud_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Text(forecast.day,
              style: AppTextStyles.bodyText.copyWith(
                  fontWeight: FontWeight.w600, fontSize: 12)),
          Icon(_icon(forecast.condition),
              color: AppColors.warning, size: 24),
          Text('${forecast.highC.toStringAsFixed(0)}°',
              style: AppTextStyles.bodyText
                  .copyWith(fontWeight: FontWeight.w700, fontSize: 13)),
          Text('${forecast.lowC.toStringAsFixed(0)}°',
              style: AppTextStyles.bodyText.copyWith(
                  color: AppColors.textSecondary, fontSize: 11)),
        ],
      ),
    );
  }
}
