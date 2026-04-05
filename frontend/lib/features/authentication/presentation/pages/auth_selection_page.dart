// lib/features/authentication/presentation/pages/auth_selection_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../config/routes/route_names.dart';
import '../bloc/auth_state.dart';
import '../bloc/auth_bloc.dart';

class AuthSelectionPage extends StatelessWidget {
  const AuthSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is Authenticated) {
          Navigator.pushNamedAndRemoveUntil(context, RouteNames.home, (_) => false);
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              children: [
                const Spacer(flex: 2),
                Container(
                  width: 90, height: 90,
                  decoration: BoxDecoration(color: AppColors.primaryGreen, borderRadius: BorderRadius.circular(24)),
                  child: const Icon(Icons.eco, size: 48, color: Colors.white),
                ),
                const SizedBox(height: 20),
                Text('Smart Harvest',
                    style: AppTextStyles.heading1.copyWith(color: AppColors.primaryGreen, fontSize: 28)),
                const SizedBox(height: 10),
                Text('Your smart agriculture companion\nfor Sri Lanka 🇱🇰',
                    style: AppTextStyles.bodyText.copyWith(color: AppColors.textSecondary),
                    textAlign: TextAlign.center),
                const SizedBox(height: 28),
                _FeatureRow(icon: Icons.trending_up, text: 'Live market prices & AI forecasts'),
                _FeatureRow(icon: Icons.wb_sunny_outlined, text: 'Weather & farming advisories'),
                _FeatureRow(icon: Icons.store_outlined, text: 'Direct buyer-farmer marketplace'),
                const Spacer(flex: 3),
                _AuthButton(label: 'Sign In',
                    onTap: () => Navigator.pushNamed(context, RouteNames.login), isPrimary: true),
                const SizedBox(height: 12),
                _AuthButton(label: 'Create Account',
                    onTap: () => Navigator.pushNamed(context, RouteNames.signup), isPrimary: false),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () => Navigator.pushNamedAndRemoveUntil(context, RouteNames.home, (_) => false),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text('Continue as Guest (limited features)',
                        style: AppTextStyles.bodyText.copyWith(
                            color: AppColors.textSecondary,
                            decoration: TextDecoration.underline, fontSize: 13)),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _FeatureRow({required this.icon, required this.text});
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(children: [
          Icon(icon, color: AppColors.primaryGreen, size: 18),
          const SizedBox(width: 10),
          Text(text, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
        ]),
      );
}

class _AuthButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool isPrimary;
  const _AuthButton({required this.label, required this.onTap, required this.isPrimary});
  @override
  Widget build(BuildContext context) => SizedBox(
        width: double.infinity, height: 52,
        child: isPrimary
            ? ElevatedButton(
                onPressed: onTap,
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)))
            : OutlinedButton(
                onPressed: onTap,
                style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.primaryGreen, width: 1.5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                child: Text(label, style: const TextStyle(color: AppColors.primaryGreen, fontSize: 16, fontWeight: FontWeight.w600))),
      );
}
