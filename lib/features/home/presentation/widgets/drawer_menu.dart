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
    return Drawer(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(context),
            const Divider(),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _DrawerItem(
                    icon: Icons.home_outlined,
                    title: 'Home',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        RouteNames.home,
                        (_) => false,
                      );
                    },
                  ),
                  _DrawerItem(
                    icon: Icons.agriculture_outlined,
                    title: 'My Crops',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(
                          context, RouteNames.cropsList);
                    },
                  ),
                  _DrawerItem(
                    icon: Icons.trending_up_outlined,
                    title: 'Market Prices',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(
                          context, RouteNames.marketPrices);
                    },
                  ),
                  _DrawerItem(
                    icon: Icons.wb_sunny_outlined,
                    title: 'Weather',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(
                          context, RouteNames.weather);
                    },
                  ),
                  _DrawerItem(
                    icon: Icons.notifications_outlined,
                    title: 'Notifications',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(
                          context, RouteNames.notifications);
                    },
                  ),
                  _DrawerItem(
                    icon: Icons.message_outlined,
                    title: 'Messages',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(
                          context, RouteNames.messagesList);
                    },
                  ),
                  const SizedBox(height: 8),
                  const _SectionLabel(label: 'Account'),
                  _DrawerItem(
                    icon: Icons.person_outline,
                    title: 'Account Settings',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(
                          context, RouteNames.accountSettings);
                    },
                  ),
                  _DrawerItem(
                    icon: Icons.help_outline,
                    title: 'Help & Support',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(
                          context, RouteNames.helpSupport);
                    },
                  ),
                ],
              ),
            ),
            const Divider(height: 0),
            _LogoutTile(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        String name = 'Smart Harvest User';
        String email = '';

        if (state is Authenticated) {
          name = state.user.name ?? name;
          email = state.user.email;
        }

        return UserAccountsDrawerHeader(
          decoration:
              const BoxDecoration(color: AppColors.primaryGreen),
          accountName: Text(
            name,
            style: AppTextStyles.bodyTextBold.copyWith(
              color: AppColors.white,
            ),
          ),
          accountEmail: Text(
            email,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.white.withOpacity(0.9),
            ),
          ),
          currentAccountPicture: CircleAvatar(
            backgroundColor: AppColors.primaryGreenLight,
            child: Text(
              name.isNotEmpty ? name[0].toUpperCase() : '?',
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: AppColors.primaryGreen,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _DrawerItem({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primaryGreen),
      title: Text(
        title,
        style: AppTextStyles.bodyText,
      ),
      onTap: onTap,
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;

  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Text(
        label.toUpperCase(),
        style: AppTextStyles.caption.copyWith(
          color: AppColors.textSecondary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _LogoutTile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading:
          const Icon(Icons.logout, color: AppColors.error),
      title: Text(
        'Logout',
        style: AppTextStyles.bodyTextBold.copyWith(
          color: AppColors.error,
        ),
      ),
      onTap: () {
        Navigator.pop(context);
        context.read<AuthBloc>().add(const LogoutEvent());
        Navigator.pushNamedAndRemoveUntil(
          context,
          RouteNames.login,
          (_) => false,
        );
      },
    );
  }
}
