// lib/config/dependency_injection/injection_container.dart
import 'package:get_it/get_it.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/network/api_client.dart';
import '../../core/services/image_upload_service.dart';
import '../../features/weather/data/datasources/weather_remote_datasource.dart';
import '../../features/weather/data/repositories/weather_repository_impl.dart';
import '../../features/weather/domain/repositories/weather_repository.dart';
import '../../features/weather/domain/usecases/get_weather_forecast_usecase.dart';
import '../../features/weather/presentation/bloc/weather_bloc.dart';
import '../../features/authentication/data/datasources/auth_remote_datasource.dart';
import '../../features/authentication/data/repositories/auth_repository_impl.dart';
import '../../features/authentication/domain/repositories/auth_repository.dart';
import '../../features/authentication/domain/usecases/login_usecase.dart';
import '../../features/authentication/domain/usecases/register_usecase.dart';
import '../../features/authentication/domain/usecases/logout_usecase.dart';
import '../../features/authentication/presentation/bloc/auth_bloc.dart';
import '../../features/home/presentation/bloc/home_bloc.dart';
import '../../features/government_dashboard/data/datasources/dashboard_remote_datasource.dart';
import '../../features/government_dashboard/data/repositories/dashboard_repository_impl.dart';
import '../../features/government_dashboard/domain/repositories/dashboard_repository.dart';
import '../../features/government_dashboard/domain/usecases/get_dashboard_stats_usecase.dart';
import '../../features/government_dashboard/presentation/bloc/dashboard_bloc.dart';
import '../../features/analytics/data/datasources/analytics_remote_datasource.dart';
import '../../features/analytics/data/repositories/analytics_repository_impl.dart';
import '../../features/analytics/domain/repositories/analytics_repository.dart';
import '../../features/analytics/domain/usecases/get_analytics_usecase.dart';
import '../../features/analytics/presentation/bloc/analytics_bloc.dart';
import '../../features/market_prices/data/datasources/price_remote_datasource.dart';
import '../../features/market_prices/data/repositories/price_repository_impl.dart';
import '../../features/market_prices/domain/repositories/price_repository.dart';
import '../../features/market_prices/domain/usecases/get_daily_prices_usecase.dart';
import '../../features/market_prices/domain/usecases/get_price_trends_usecase.dart';
import '../../features/market_prices/domain/usecases/get_supply_status_usecase.dart';
import '../../features/market_prices/domain/usecases/get_forecast_usecase.dart';
import '../../features/market_prices/presentation/bloc/price_bloc.dart';
import '../../features/messaging/data/datasources/message_remote_datasource.dart';
import '../../features/messaging/data/repositories/message_repository_impl.dart';
import '../../features/messaging/domain/repositories/message_repository.dart';
import '../../features/messaging/domain/usecases/get_messages_usecase.dart';
import '../../features/messaging/domain/usecases/send_message_usecase.dart';
import '../../features/messaging/presentation/bloc/message_bloc.dart';
import '../../features/crop_management/data/datasources/crop_remote_datasource.dart';
import '../../features/crop_management/data/repositories/crop_repository_impl.dart';
import '../../features/crop_management/domain/repositories/crop_repository.dart';
import '../../features/crop_management/domain/usecases/get_crops_usecase.dart';
import '../../features/crop_management/domain/usecases/add_crop_usecase.dart';
import '../../features/crop_management/domain/usecases/update_crop_usecase.dart';
import '../../features/crop_management/presentation/bloc/crop_bloc.dart';
import '../../features/notifications/data/datasources/notification_remote_datasource.dart';
import '../../features/notifications/data/repositories/notification_repository_impl.dart';
import '../../features/notifications/domain/repositories/notification_repository.dart';
import '../../features/notifications/domain/usecases/get_notifications_usecase.dart';
import '../../features/notifications/presentation/bloc/notification_bloc.dart';
import '../../features/marketplace/data/datasources/marketplace_remote_datasource.dart';
import '../../features/marketplace/data/repositories/marketplace_repository_impl.dart';
import '../../features/marketplace/domain/repositories/marketplace_repository.dart';
import '../../features/marketplace/domain/usecases/browse_products_usecase.dart';
import '../../features/marketplace/domain/usecases/create_product_usecase.dart';
import '../../features/marketplace/domain/usecases/get_orders_usecase.dart';
import '../../features/marketplace/domain/usecases/place_order_usecase.dart';
import '../../features/marketplace/presentation/bloc/marketplace_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // ── Core ───────────────────────────────────────────────────────────────────
  sl.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);
  sl.registerLazySingleton<FirebaseFirestore>(() => FirebaseFirestore.instance);
  sl.registerLazySingleton<FirebaseStorage>(() => FirebaseStorage.instance);
  sl.registerLazySingleton<ApiClient>(() => ApiClient.instance);
  sl.registerLazySingleton<ImageUploadService>(
    () => ImageUploadService(storage: sl()),
  );

  // ── Authentication ─────────────────────────────────────────────────────────
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(firebaseAuth: sl()),
  );
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<LoginUseCase>(() => LoginUseCase(sl()));
  sl.registerLazySingleton<RegisterUseCase>(() => RegisterUseCase(sl()));
  sl.registerLazySingleton<LogoutUseCase>(() => LogoutUseCase(sl()));
  // AuthBloc keeps its direct Firebase wiring; use cases are available for
  // any future refactor or new code that prefers the clean-arch path.
  sl.registerFactory<AuthBloc>(() => AuthBloc());

  // ── Home ───────────────────────────────────────────────────────────────────
  sl.registerFactory<HomeBloc>(() => HomeBloc(firestore: sl()));

  // ── Government dashboard ───────────────────────────────────────────────────
  sl.registerLazySingleton<DashboardRemoteDataSource>(
    () => DashboardRemoteDataSourceImpl(firestore: sl()),
  );
  sl.registerLazySingleton<DashboardRepository>(
    () => DashboardRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<GetDashboardStatsUseCase>(
    () => GetDashboardStatsUseCase(sl()),
  );
  sl.registerFactory<DashboardBloc>(
    () => DashboardBloc(getDashboardStatsUseCase: sl()),
  );

  // ── Analytics ──────────────────────────────────────────────────────────────
  sl.registerLazySingleton<AnalyticsRemoteDataSource>(
    () => AnalyticsRemoteDataSourceImpl(firestore: sl()),
  );
  sl.registerLazySingleton<AnalyticsRepository>(
    () => AnalyticsRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<GetAnalyticsUseCase>(() => GetAnalyticsUseCase(sl()));
  sl.registerFactory<AnalyticsBloc>(() => AnalyticsBloc(getAnalytics: sl()));

  // ── Weather ────────────────────────────────────────────────────────────────
  sl.registerLazySingleton<WeatherRemoteDataSource>(
    () => WeatherRemoteDataSourceImpl(),
  );
  sl.registerLazySingleton<WeatherRepository>(
    () => WeatherRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<GetWeatherForecastUseCase>(
    () => GetWeatherForecastUseCase(sl()),
  );
  sl.registerFactory<WeatherBloc>(() => WeatherBloc(getWeather: sl()));

  // ── Market prices ──────────────────────────────────────────────────────────
  sl.registerLazySingleton<PriceRemoteDataSource>(
    () => PriceRemoteDataSourceImpl(firestore: sl()),
  );
  sl.registerLazySingleton<PriceRepository>(
    () => PriceRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<GetDailyPricesUseCase>(() => GetDailyPricesUseCase(sl()));
  sl.registerLazySingleton<GetPriceHistoryUseCase>(() => GetPriceHistoryUseCase(sl()));
  sl.registerLazySingleton<GetSupplyStatusUseCase>(() => GetSupplyStatusUseCase(sl()));
  sl.registerLazySingleton<GetForecastUseCase>(() => GetForecastUseCase(sl()));
  sl.registerFactory<PriceBloc>(() => PriceBloc(
    getDailyPrices: sl(),
    getPriceHistory: sl(),
    getSupplyStatus: sl(),
    getForecast: sl(),
  ));

  // ── Messaging ──────────────────────────────────────────────────────────────
  sl.registerLazySingleton<MessageRemoteDataSource>(
    () => MessageRemoteDataSourceImpl(firestore: sl()),
  );
  sl.registerLazySingleton<MessageRepository>(
    () => MessageRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<GetMessagesUseCase>(() => GetMessagesUseCase(sl()));
  sl.registerLazySingleton<SendMessageUseCase>(() => SendMessageUseCase(sl()));
  sl.registerFactory<MessageBloc>(() => MessageBloc(
    sendMessageUseCase: sl(),
    getMessagesUseCase: sl(),
    repository: sl(),
  ));

  // ── Crop management (Firestore direct) ───────────────────────────────────────
  sl.registerLazySingleton<CropRemoteDataSource>(
    () => CropRemoteDataSourceImpl(firestore: sl()),
  );
  sl.registerLazySingleton<CropRepository>(
    () => CropRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<GetCropsUseCase>(() => GetCropsUseCase(sl()));
  sl.registerLazySingleton<AddCropUseCase>(() => AddCropUseCase(sl()));
  sl.registerLazySingleton<UpdateCropUseCase>(() => UpdateCropUseCase(sl()));
  sl.registerFactory<CropBloc>(() => CropBloc(
    getCropsUseCase: sl(),
    addCropUseCase: sl(),
    updateCropUseCase: sl(),
    cropRepository: sl(),
  ));

  // ── Notifications ──────────────────────────────────────────────────────────
  sl.registerLazySingleton<NotificationRemoteDataSource>(
    () => NotificationRemoteDataSourceImpl(firestore: sl()),
  );
  sl.registerLazySingleton<NotificationRepository>(
    () => NotificationRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<GetNotificationsUseCase>(
    () => GetNotificationsUseCase(sl()),
  );
  sl.registerFactory<NotificationBloc>(
    () => NotificationBloc(getNotificationsUseCase: sl()),
  );

  // ── Marketplace (Firestore direct) ───────────────────────────────────────────
  sl.registerLazySingleton<MarketplaceRemoteDataSource>(
    () => MarketplaceRemoteDataSourceImpl(firestore: sl()),
  );
  sl.registerLazySingleton<MarketplaceRepository>(
    () => MarketplaceRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<BrowseProductsUseCase>(() => BrowseProductsUseCase(sl()));
  sl.registerLazySingleton<PlaceOrderUseCase>(() => PlaceOrderUseCase(sl()));
  sl.registerLazySingleton<GetOrdersUseCase>(() => GetOrdersUseCase(sl()));
  sl.registerLazySingleton<CreateProductUseCase>(() => CreateProductUseCase(sl()));
  sl.registerFactory<MarketplaceBloc>(() => MarketplaceBloc(
    browseProductsUseCase: sl(),
    placeOrderUseCase: sl(),
    getOrdersUseCase: sl(),
    createProductUseCase: sl(),
    repository: sl(),
  ));
}
