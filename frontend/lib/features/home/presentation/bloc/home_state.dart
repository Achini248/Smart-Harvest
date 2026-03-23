// lib/features/home/presentation/bloc/home_state.dart
import 'package:equatable/equatable.dart';

class NewsItem {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final String publishedAt;
  final String source;
  final String category;

  const NewsItem({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.publishedAt,
    required this.source,
    required this.category,
  });

  factory NewsItem.fromJson(Map<String, dynamic> json) => NewsItem(
        id:          json['id']          as String? ?? '',
        title:       json['title']       as String? ?? '',
        description: json['description'] as String? ?? '',
        imageUrl:    json['imageUrl']    as String? ?? '',
        publishedAt: json['publishedAt'] as String? ?? '',
        source:      json['source']      as String? ?? '',
        category:    json['category']    as String? ?? '',
      );
}

class TopPriceItem {
  final String cropName;
  final double avgPrice;
  final double? predictedPrice;
  final bool isSurplus;
  final bool isShortage;

  const TopPriceItem({
    required this.cropName,
    required this.avgPrice,
    this.predictedPrice,
    required this.isSurplus,
    required this.isShortage,
  });

  factory TopPriceItem.fromJson(Map<String, dynamic> json) => TopPriceItem(
        cropName:       json['cropName']       as String? ?? '',
        avgPrice:       (json['avgPrice']       as num? ?? 0).toDouble(),
        predictedPrice: (json['predictedPrice'] as num?)?.toDouble(),
        isSurplus:      json['isSurplus']       as bool? ?? false,
        isShortage:     json['isShortage']      as bool? ?? false,
      );

  /// positive = price going up, negative = going down
  double get priceChange =>
      predictedPrice != null ? predictedPrice! - avgPrice : 0.0;

  double get priceChangePct =>
      avgPrice > 0 && predictedPrice != null
          ? (predictedPrice! - avgPrice) / avgPrice * 100
          : 0.0;
}

class WeatherSummary {
  final String location;
  final String condition;
  final double temperature;
  final String iconCode;
  final String farmingAdvice;

  const WeatherSummary({
    required this.location,
    required this.condition,
    required this.temperature,
    required this.iconCode,
    required this.farmingAdvice,
  });

  factory WeatherSummary.fromJson(Map<String, dynamic> json) {
    // Backend sends: temperatureC, condition, icon (not iconCode), location
    final cond = json['condition'] as String? ?? 'Clear';
    return WeatherSummary(
      location:      json['location']      as String? ?? '',
      condition:     cond,
      temperature:   (json['temperatureC'] as num?
                      ?? json['temperature'] as num?
                      ?? 0).toDouble(),
      iconCode:      json['icon']     as String?
                     ?? json['iconCode'] as String? ?? '',
      farmingAdvice: _advice(cond),
    );
  }

  static String _advice(String condition) {
    final c = condition.toLowerCase();
    if (c.contains('rain') || c.contains('storm') || c.contains('drizzle')) {
      return 'Heavy rain expected. Avoid pesticide spraying. Check drainage.';
    } else if (c.contains('cloud')) {
      return 'Overcast skies. Good conditions for transplanting seedlings.';
    } else if (c.contains('sunny') || c.contains('clear')) {
      return 'Clear skies. Ideal for harvesting and field spraying.';
    } else if (c.contains('haze') || c.contains('mist') || c.contains('fog')) {
      return 'Low visibility. Delay field operations until mid-morning.';
    }
    return 'Monitor conditions before starting field operations.';
  }
}

// ── State ─────────────────────────────────────────────────────────────────────

abstract class HomeState extends Equatable {
  const HomeState();
  @override
  List<Object?> get props => [];
}

class HomeInitial extends HomeState {
  const HomeInitial();
}

class HomeLoading extends HomeState {
  const HomeLoading();
}

class HomeLoaded extends HomeState {
  final List<NewsItem>    news;
  final List<TopPriceItem> topPrices;
  final WeatherSummary?  weather;
  final int surplusCount;
  final int shortageCount;

  const HomeLoaded({
    required this.news,
    required this.topPrices,
    this.weather,
    required this.surplusCount,
    required this.shortageCount,
  });

  @override
  List<Object?> get props => [news, topPrices, weather, surplusCount, shortageCount];
}

class HomeError extends HomeState {
  final String message;
  const HomeError(this.message);
  @override
  List<Object?> get props => [message];
}
