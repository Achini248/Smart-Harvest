import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../config/routes/route_names.dart';
import '../../../authentication/presentation/bloc/auth_bloc.dart';
import '../../../authentication/presentation/bloc/auth_state.dart';

class DrawerMenu extends StatelessWidget {
  const DrawerMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          return ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: const BoxDecoration(
                  color: AppColors.primaryGreen,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const CircleAvatar(
                      radius: 32,
                      backgroundColor: AppColors.white,
                      child: Icon(
                        Icons.person,
                        size: 32,
                        color: AppColors.primaryGreen,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (state is Authenticated) ...[
                      Text(
                        state.user.name ?? 'User',
                        style: AppTextStyles.bodyTextBold.copyWith(
                          color: AppColors.white,
                        ),
                      ),
                      Text(
                        state.user.email,
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.white,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              ListTile(
                leading: const Icon(Icons.home),
                title: const Text('Home'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.agriculture),
                title: const Text('My Crops'),
                onTap: () {
                  Navigator.pushNamed(context, RouteNames.cropsList);
                },
              ),
              ListTile(
                leading: const Icon(Icons.trending_up),
                title: const Text('Market Prices'),
                onTap: () {
                  Navigator.pushNamed(context, RouteNames.marketPrices);
                },
              ),
              ListTile(
                leading: const Icon(Icons.wb_sunny),
                title: const Text('Weather'),
                onTap: () {
                  Navigator.pushNamed(context, RouteNames.weather);
                },
              ),
              ListTile(
                leading: const Icon(Icons.message),
                title: const Text('Messages'),
                onTap: () {
                  Navigator.pushNamed(context, RouteNames.messagesList);
                },
              ),
              ListTile(
                leading: const Icon(Icons.analytics),
                title: const Text('Analytics'),
                onTap: () {
                  Navigator.pushNamed(context, RouteNames.analytics);
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.settings),
                title: const Text('Settings'),
                onTap: () {
                  Navigator.pushNamed(context, RouteNames.accountSettings);
                },
              ),
              ListTile(
                leading: const Icon(Icons.help),
                title: const Text('Help & Support'),
                onTap: () {
                  Navigator.pushNamed(context, RouteNames.helpSupport);
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
