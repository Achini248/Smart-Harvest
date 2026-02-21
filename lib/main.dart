// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'features/authentication/data/datasources/auth_remote_datasource.dart';
import 'features/authentication/data/repositories/auth_repository_impl.dart';
import 'features/authentication/domain/usecases/login_usecase.dart';
import 'features/authentication/domain/usecases/register_usecase.dart';
import 'features/authentication/domain/usecases/logout_usecase.dart';
import 'features/authentication/domain/usecases/send_otp_usecase.dart';
import 'features/authentication/domain/usecases/verify_otp_usecase.dart';
import 'features/authentication/presentation/bloc/auth_bloc.dart';
import 'config/routes/app_router.dart';
import 'config/routes/route_names.dart';
import 'core/constants/app_colors.dart';

void main() {
  runApp(const SmartHarvestApp());
}

class SmartHarvestApp extends StatelessWidget {
  const SmartHarvestApp({super.key});

  @override
  Widget build(BuildContext context) {
    // ── Wire up dependencies manually (no get_it needed for now) ──────────
    final remoteDataSource = AuthRemoteDataSourceImpl();
    final authRepository = AuthRepositoryImpl(
      remoteDataSource: remoteDataSource,  // named param matches impl
    );

    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (_) => AuthBloc(
            loginUseCase: LoginUseCase(authRepository),
            registerUseCase: RegisterUseCase(authRepository),
            logoutUseCase: LogoutUseCase(authRepository),
            sendOtpUseCase: SendOtpUseCase(authRepository),
            verifyOtpUseCase: VerifyOtpUseCase(authRepository),
          )..add(AuthCheckStatusEvent()),
        ),
      ],
      child: MaterialApp(
        title: 'Smart Harvest',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.primaryGreen,
          ),
          useMaterial3: true,
          scaffoldBackgroundColor: AppColors.background,
          fontFamily: 'Poppins',
        ),
        initialRoute: RouteNames.splash,
        onGenerateRoute: AppRouter.generateRoute,
      ),
    );
  }
}
