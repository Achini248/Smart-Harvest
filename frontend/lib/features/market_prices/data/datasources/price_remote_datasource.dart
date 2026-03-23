// lib/features/market_prices/data/datasources/price_remote_datasource.dart
import '../../../../core/network/api_client.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/price_model.dart';
import '../../domain/entities/price.dart';

abstract class PriceRemoteDataSource {
  Future<List<PriceModel>>       getDailyPrices({String? district});
  Future<List<PriceHistoryModel>> getPriceHistory(String cropName, {int days = 30});
  Future<SupplyAnalyticsModel>   getSupplyStatus();
  Future<ForecastModel>          getForecast(String cropName);
}

class PriceRemoteDataSourceImpl implements PriceRemoteDataSource {
  final ApiClient _api;

  PriceRemoteDataSourceImpl({ApiClient? apiClient})
      : _api = apiClient ?? ApiClient.instance;

  @override
  Future<List<PriceModel>> getDailyPrices({String? district}) async {
    final params = <String, String>{
      'per_page': '100',
      if (district != null && district != 'All') 'district': district,
    };
    final data = await _api.get(ApiConstants.todayPrices, queryParams: params);
    // Backend returns paginated: { items: [...], total: ... }
    final items = (data is Map && data.containsKey('items'))
        ? data['items'] as List<dynamic>
        : data as List<dynamic>;
    return items
        .map((e) => PriceModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<PriceHistoryModel>> getPriceHistory(
      String cropName, {int days = 30}) async {
    final data = await _api.get(
      ApiConstants.priceHistory(cropName),
      queryParams: {'days': days.toString()},
    );
    return (data as List<dynamic>)
        .map((e) => PriceHistoryModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<SupplyAnalyticsModel> getSupplyStatus() async {
    final data = await _api.get(ApiConstants.supplyStatus);
    return SupplyAnalyticsModel.fromJson(data as Map<String, dynamic>);
  }

  @override
  Future<ForecastModel> getForecast(String cropName) async {
    final data = await _api.get(ApiConstants.forecast(cropName));
    return ForecastModel.fromJson(data as Map<String, dynamic>);
  }
}
