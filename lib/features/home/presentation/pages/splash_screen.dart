//Add spash screen
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../config/routes/route_names.dart';
import '../../../authentication/presentation/bloc/auth_bloc.dart';
import '../../../authentication/presentation/bloc/auth_event.dart';
import '../../../authentication/presentation/bloc/auth_state.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNextScreen();
  }

  Future<void> _navigateToNextScreen() async {
    // Wait for splash screen duration
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    // Check if onboarding was completed
    final prefs = await SharedPreferences.getInstance();
    final onboardingComplete = prefs.getBool('onboarding_complete') ?? false;

    // Check authentication status
    context.read<AuthBloc>().add(CheckAuthStatusEvent());
    
    // Wait a bit for auth check
    await Future.delayed(const Duration(milliseconds: 500));
    
    if (!mounted) return;

    final authState = context.read<AuthBloc>().state;

    // Navigation logic
    if (!onboardingComplete) {
      // First time user - show onboarding
      Navigator.pushReplacementNamed(context, RouteNames.onboarding);
    } else if (authState is Authenticated) {
      // User completed onboarding and is logged in - go to home
      Navigator.pushReplacementNamed(context, RouteNames.home);
    } else {
      // User completed onboarding but not logged in - go to login
      Navigator.pushReplacementNamed(context, RouteNames.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo
            Container(
              width: 120,
              height: 120,
              decoration: const BoxDecoration(
                color: AppColors.primaryGreen,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.eco,
                size: 60,
                color: AppColors.white,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              AppStrings.appName,
              style: AppTextStyles.heading1.copyWith(
                color: AppColors.primaryGreen,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              AppStrings.appSlogan,
              style: AppTextStyles.bodyText.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 32),
            // Loading indicator
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryGreen),
            ),
          ],
        ),
      ),
    );
  }
}
