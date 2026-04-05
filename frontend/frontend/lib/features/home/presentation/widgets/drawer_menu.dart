// lib/features/home/presentation/widgets/drawer_menu.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../config/routes/route_names.dart';
import '../../../authentication/presentation/bloc/auth_bloc.dart';
import '../../../authentication/presentation/bloc/auth_event.dart';
import '../../../authentication/presentation/bloc/auth_state.dart';

class DrawerMenu extends StatelessWidget {
  const DrawerMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        final isGuest = authState is! Authenticated;
        return Drawer(
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeader(context, authState),
                const Divider(height: 0),
                Expanded(
                  child: ListView(padding: EdgeInsets.zero, children: [
                    const SizedBox(height: 8),
                    _Item(icon: Icons.home_outlined, title: 'Home', onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamedAndRemoveUntil(context, RouteNames.home, (_) => false);
                    }),
                    _Item(icon: Icons.agriculture_outlined, title: 'My Crops', onTap: () {
                      Navigator.pop(context);
                      if (isGuest) { _signInPrompt(context); return; }
                      Navigator.pushNamed(context, RouteNames.myCrops);
                    }),
                    _Item(icon: Icons.store_outlined, title: 'Marketplace', onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, RouteNames.marketplaceHome);
                    }),
                    _Item(icon: Icons.trending_up_outlined, title: 'Market Prices', onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, RouteNames.dailyMarketPrices);
                    }),
                    _Item(icon: Icons.wb_sunny_outlined, title: 'Weather', onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, RouteNames.weatherOverview);
                    }),
                    _Item(icon: Icons.message_outlined, title: 'Messages', onTap: () {
                      Navigator.pop(context);
                      if (isGuest) { _signInPrompt(context); return; }
                      Navigator.pushNamed(context, RouteNames.messagesList);
                    }),
                    const SizedBox(height: 8),
                    const _Section('Analytics & Dashboard'),
                    _Item(
                      icon: Icons.bar_chart_outlined,
                      title: 'Analytics',
                      trailing: isGuest ? const _LoginBadge() : null,
                      onTap: () {
                        Navigator.pop(context);
                        if (isGuest) { _signInPrompt(context); return; }
                        Navigator.pushNamed(context, RouteNames.analytics);
                      },
                    ),
                    _Item(
                      icon: Icons.dashboard_outlined,
                      title: 'Government Dashboard',
                      trailing: isGuest ? const _LoginBadge() : null,
                      onTap: () {
                        Navigator.pop(context);
                        if (isGuest) { _signInPrompt(context); return; }
                        Navigator.pushNamed(context, RouteNames.governmentDashboard);
                      },
                    ),
                    const SizedBox(height: 8),
                    const _Section('Account'),
                    _Item(icon: Icons.person_outline, title: 'Profile & Settings', onTap: () {
                      Navigator.pop(context);
                      if (isGuest) { _signInPrompt(context); return; }
                      Navigator.pushNamed(context, RouteNames.profileSettings);
                    }),
                    _Item(icon: Icons.help_outline, title: 'Help & Support', onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, RouteNames.helpSupport);
                    }),
                    const SizedBox(height: 8),
                  ]),
                ),
                const Divider(height: 0),
                if (isGuest)
                  ListTile(
                    leading: const Icon(Icons.login, color: AppColors.primaryGreen),
                    title: const Text('Sign In / Register',
                        style: TextStyle(color: AppColors.primaryGreen, fontWeight: FontWeight.w600)),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, RouteNames.login);
                    },
                  )
                else
                  ListTile(
                    leading: const Icon(Icons.logout, color: AppColors.error),
                    title: Text('Logout',
                        style: AppTextStyles.bodyTextBold.copyWith(color: AppColors.error)),
                    onTap: () {
                      Navigator.pop(context);
                      context.read<AuthBloc>().add(const LogoutEvent());
                      Navigator.pushNamedAndRemoveUntil(context, RouteNames.authSelection, (_) => false);
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, AuthState state) {
    String name = 'Guest User';
    String sub = 'Sign in to access all features';
    if (state is Authenticated) {
      name = state.displayName ?? 'Smart Harvest User';
      sub = state.email ?? '';
    }
    return UserAccountsDrawerHeader(
      decoration: const BoxDecoration(color: AppColors.primaryGreen),
      accountName: Text(name, style: AppTextStyles.bodyTextBold.copyWith(color: Colors.white)),
      accountEmail: Text(sub, style: AppTextStyles.caption.copyWith(color: Colors.white70)),
      currentAccountPicture: CircleAvatar(
        backgroundColor: AppColors.primaryGreenLight,
        child: Text(name.isNotEmpty ? name[0].toUpperCase() : '?',
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: AppColors.primaryGreen)),
      ),
    );
  }

  void _signInPrompt(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Sign in required'),
        content: const Text('Please sign in or create an account to access this feature.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryGreen),
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, RouteNames.login);
            },
            child: const Text('Sign In', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class _Item extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Widget? trailing;
  const _Item({required this.icon, required this.title, required this.onTap, this.trailing});
  @override
  Widget build(BuildContext context) => ListTile(
        leading: Icon(icon, color: AppColors.primaryGreen),
        title: Text(title, style: AppTextStyles.bodyText),
        trailing: trailing,
        onTap: onTap,
      );
}

class _Section extends StatelessWidget {
  final String label;
  const _Section(this.label);
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Text(label.toUpperCase(),
            style: AppTextStyles.caption.copyWith(
                color: AppColors.textSecondary, fontWeight: FontWeight.w700)),
      );
}

class _LoginBadge extends StatelessWidget {
  const _LoginBadge();
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
        decoration: BoxDecoration(color: Colors.orange.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.orange.shade300)),
        child: const Text('Login', style: TextStyle(fontSize: 10, color: Colors.orange)),
      );
}
