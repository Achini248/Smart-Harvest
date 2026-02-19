import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../config/routes/route_names.dart';
import '../../../authentication/presentation/bloc/auth_bloc.dart';
import '../../../authentication/presentation/bloc/auth_event.dart';
import '../../../authentication/presentation/bloc/auth_state.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/drawer_menu.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const HomeTabView(),
    const MarketplaceTabView(),
    const CropsTabView(),
    const ProfileTabView(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppStrings.appName,
          style: AppTextStyles.heading3,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              Navigator.pushNamed(context, RouteNames.notifications);
            },
          ),
        ],
      ),
      drawer: const DrawerMenu(),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}

// Home Tab
class HomeTabView extends StatelessWidget {
  const HomeTabView({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primaryGreen, AppColors.primaryGreenLight],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome Back!',
                          style: AppTextStyles.heading3.copyWith(
                            color: AppColors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          AppStrings.appSlogan,
                          style: AppTextStyles.bodyText.copyWith(
                            color: AppColors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.eco,
                    size: 60,
                    color: AppColors.white,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Quick Actions
            Text(
              'Quick Actions',
              style: AppTextStyles.heading3,
            ),
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              children: [
                _buildQuickActionCard(
                  context,
                  'My Crops',
                  Icons.agriculture,
                  () {
                    Navigator.pushNamed(context, RouteNames.cropsList);
                  },
                ),
                _buildQuickActionCard(
                  context,
                  'Market Prices',
                  Icons.trending_up,
                  () {
                    Navigator.pushNamed(context, RouteNames.marketPrices);
                  },
                ),
                _buildQuickActionCard(
                  context,
                  'Weather',
                  Icons.wb_sunny,
                  () {
                    Navigator.pushNamed(context, RouteNames.weather);
                  },
                ),
                _buildQuickActionCard(
                  context,
                  'Messages',
                  Icons.message,
                  () {
                    Navigator.pushNamed(context, RouteNames.messagesList);
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Recent Activity
            Text(
              'Recent Activity',
              style: AppTextStyles.heading3,
            ),
            const SizedBox(height: 16),
            _buildActivityItem('New order received', '2 hours ago'),
            _buildActivityItem('Price update for tomatoes', '5 hours ago'),
            _buildActivityItem('Weather alert for your area', '1 day ago'),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionCard(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 48, color: AppColors.primaryGreen),
              const SizedBox(height: 12),
              Text(
                title,
                style: AppTextStyles.bodyTextBold,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActivityItem(String title, String time) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: AppColors.primaryGreenLight,
          child: Icon(Icons.notifications, color: AppColors.primaryGreen),
        ),
        title: Text(title, style: AppTextStyles.bodyText),
        subtitle: Text(time, style: AppTextStyles.caption),
      ),
    );
  }
}

// Marketplace Tab
class MarketplaceTabView extends StatelessWidget {
  const MarketplaceTabView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Marketplace - Coming Soon'),
    );
  }
}

// Crops Tab
class CropsTabView extends StatelessWidget {
  const CropsTabView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Crops Management - Coming Soon'),
    );
  }
}

// Profile Tab
class ProfileTabView extends StatelessWidget {
  const ProfileTabView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is Authenticated) {
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const SizedBox(height: 24),
                  // Profile Avatar
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: AppColors.primaryGreenLight,
                    child: const Icon(
                      Icons.person,
                      size: 60,
                      color: AppColors.primaryGreen,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    state.user.name ?? 'User',
                    style: AppTextStyles.heading2,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.user.email,
                    style: AppTextStyles.bodyText.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Profile Options
                  _buildProfileOption(
                    context,
                    'Profile Settings',
                    Icons.person_outline,
                    () {
                      Navigator.pushNamed(context, RouteNames.profileSettings);
                    },
                  ),
                  _buildProfileOption(
                    context,
                    'Account Settings',
                    Icons.settings_outlined,
                    () {
                      Navigator.pushNamed(context, RouteNames.accountSettings);
                    },
                  ),
                  _buildProfileOption(
                    context,
                    'Help & Support',
                    Icons.help_outline,
                    () {
                      Navigator.pushNamed(context, RouteNames.helpSupport);
                    },
                  ),
                  _buildProfileOption(
                    context,
                    'Logout',
                    Icons.logout,
                    () {
                      _showLogoutDialog(context);
                    },
                    isDestructive: true,
                  ),
                ],
              ),
            ),
          );
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  Widget _buildProfileOption(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onTap, {
    bool isDestructive = false,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(
          icon,
          color: isDestructive ? AppColors.error : AppColors.primaryGreen,
        ),
        title: Text(
          title,
          style: AppTextStyles.bodyTextBold.copyWith(
            color: isDestructive ? AppColors.error : AppColors.textPrimary,
          ),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Are You Sure Want To\nLog Out',
            style: AppTextStyles.heading3,
            textAlign: TextAlign.center,
          ),
          actions: [
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      Navigator.pop(dialogContext);
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: AppColors.lightGrey,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Text(
                        'Cancel',
                        style: AppTextStyles.bodyTextBold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      Navigator.pop(dialogContext);
                      context.read<AuthBloc>().add(LogoutEvent());
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: AppColors.primaryGreen,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Text(
                        'Log Out',
                        style: AppTextStyles.bodyTextBold.copyWith(
                          color: AppColors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
