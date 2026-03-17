// lib/config/dependency_injection/injection_container.dart
import 'package:get_it/get_it.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../features/weather/data/datasources/weather_remote_datasource.dart';
import '../../features/weather/data/repositories/weather_repository_impl.dart';
import '../../features/weather/domain/repositories/weather_repository.dart';
import '../../features/weather/domain/usecases/get_weather_forecast_usecase.dart';
import '../../features/authentication/presentation/bloc/auth_bloc.dart';
import '../../features/market_prices/data/datasources/price_remote_datasource.dart';
import '../../features/market_prices/data/repositories/price_repository_impl.dart';
import '../../features/market_prices/domain/repositories/price_repository.dart';
import '../../features/market_prices/domain/usecases/get_daily_prices_usecase.dart';
import '../../features/market_prices/domain/usecases/get_price_trends_usecase.dart';
import '../../features/market_prices/presentation/bloc/price_bloc.dart';
import '../../features/messaging/data/datasources/message_remote_datasource.dart';
import '../../features/messaging/data/repositories/message_repository_impl.dart';
import '../../features/messaging/domain/repositories/message_repository.dart';
import '../../features/messaging/domain/usecases/get_messages_usecase.dart';
import '../../features/messaging/domain/usecases/send_message_usecase.dart';
import '../../features/messaging/presentation/bloc/message_bloc.dart';
import '../../features/crop_management/data/repositories/crop_repository_impl.dart';
import '../../features/crop_management/domain/repositories/crop_repository.dart';
import '../../features/crop_management/domain/usecases/get_crops_usecase.dart';
import '../../features/crop_management/presentation/bloc/crop_bloc.dart';
import '../../features/crop_management/domain/usecases/add_crop_usecase.dart';
import '../../features/crop_management/domain/usecases/update_crop_usecase.dart';
import '../../features/crop_management/data/datasources/crop_remote_datasource.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Firebase
  sl.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);

  // Blocs
  sl.registerFactory(
    () => AuthBloc(),
  );

  // ---------------- WEATHER ----------------

  // Data source
  sl.registerLazySingleton<WeatherRemoteDataSource>(
        () => WeatherRemoteDataSourceImpl(),
  );

  // Repository
  sl.registerLazySingleton<WeatherRepository>(
        () => WeatherRepositoryImpl(
          remoteDataSource: sl(),
        ),
  );

  // Use case
  sl.registerLazySingleton<GetWeatherForecastUseCase>(
        () => GetWeatherForecastUseCase(
          sl(),
        ),
  );

  // ---------------- MARKET PRICES ----------------

  // Data source
  sl.registerLazySingleton<PriceRemoteDataSource>(
    () => PriceRemoteDataSourceImpl(),
  );

  // Repository
  sl.registerLazySingleton<PriceRepository>(
    () => PriceRepositoryImpl(
      remoteDataSource: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton<GetDailyPricesUseCase>(
    () => GetDailyPricesUseCase(sl()),
  );

  sl.registerLazySingleton<GetPriceTrendsUseCase>(
    () => GetPriceTrendsUseCase(sl()),
  );

  // Bloc
  sl.registerFactory<PriceBloc>(
    () => PriceBloc(
      getDailyPrices: sl(),
      getPriceTrends: sl(),
    ),
  );

  // ---------------- MESSAGES ----------------

  sl.registerLazySingleton<MessageRemoteDataSource>(
        () => MessageRemoteDataSourceImpl(),
  );

  sl.registerLazySingleton<MessageRepository>(
        () => MessageRepositoryImpl(
      remoteDataSource: sl(),
    ),
  );

  sl.registerLazySingleton<GetMessagesUseCase>(
        () => GetMessagesUseCase(sl()),
  );

  sl.registerLazySingleton<SendMessageUseCase>(
    () => SendMessageUseCase(sl()),
  );

  sl.registerFactory<MessageBloc>(
    () => MessageBloc(
      sendMessageUseCase: sl(),
      getMessagesUseCase: sl(),
      repository: sl(),
    ),
  );

  // CROPS

  sl.registerLazySingleton<CropRemoteDataSource>(
        () => CropRemoteDataSourceImpl(),
  );

  sl.registerLazySingleton<CropRepository>(
        () => CropRepositoryImpl(
      remoteDataSource: sl(),
    ),
  );

  sl.registerLazySingleton<GetCropsUseCase>(
        () => GetCropsUseCase(sl()),
  );

  sl.registerFactory<CropBloc>(
        () => CropBloc(
      getCropsUseCase: sl(),
      addCropUseCase: sl(),
      updateCropUseCase: sl(),
      cropRepository: sl(),
    ),
  );

  sl.registerLazySingleton<AddCropUseCase>(
        () => AddCropUseCase(sl()),
  );

  sl.registerLazySingleton<UpdateCropUseCase>(
        () => UpdateCropUseCase(sl()),
  );
}
