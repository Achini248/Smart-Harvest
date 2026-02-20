import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../config/routes/route_names.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingItem> _items = [
    OnboardingItem(
      title: AppStrings.planForTomorrow,
      description: 'Plan your crops smarter with real-time data and insights',
      icon: Icons.agriculture,
      bgColor: const Color(0xFFE8F5E9),
    ),
    OnboardingItem(
      title: AppStrings.protectYourHarvest,
      description: 'Get weather alerts and pest warnings to protect your yield',
      icon: Icons.wb_sunny_outlined,
      bgColor: const Color(0xFFFFF8E1),
    ),
    OnboardingItem(
      title: AppStrings.yourFarmYourPrice,
      description: 'Connect with buyers and sell your crops at the best price',
      icon: Icons.handshake_outlined,
      bgColor: const Color(0xFFE3F2FD),
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_complete', true);

    if (mounted) {
      Navigator.pushReplacementNamed(context, RouteNames.login);
    }
  }

  void _nextPage() {
    if (_currentPage < _items.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Skip Button Row
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Page count
                  Text(
                    '${_currentPage + 1}/${_items.length}',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  // Skip button
                  TextButton(
                    onPressed: _completeOnboarding,
                    child: Text(
                      AppStrings.skip,
                      style: AppTextStyles.bodyTextBold.copyWith(
                        color: AppColors.primaryGreen,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Page View
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: _items.length,
                itemBuilder: (context, index) {
                  return _buildOnboardingItem(_items[index]);
                },
              ),
            ),

            // Bottom Navigation
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Page Indicators
                  Row(
                    children: List.generate(
                      _items.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _currentPage == index ? 28 : 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? AppColors.primaryGreen
                              : AppColors.lightGrey,
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                    ),
                  ),

                  // Next / Get Started Button
                  GestureDetector(
                    onTap: _nextPage,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: _currentPage == _items.length - 1 ? 160 : 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: AppColors.primaryGreen,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryGreen.withValues(alpha: 0.4),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Center(
                        child: _currentPage == _items.length - 1
                            ? Text(
                                'Get Started',
                                style: AppTextStyles.bodyTextBold.copyWith(
                                  color: AppColors.white,
                                  fontSize: 15,
                                ),
                              )
                            : const Icon(
                                Icons.arrow_forward,
                                color: AppColors.white,
                                size: 28,
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOnboardingItem(OnboardingItem item) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon Container
          Container(
            width: 220,
            height: 220,
            decoration: BoxDecoration(
              color: item.bgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(
              item.icon,
              size: 110,
              color: AppColors.primaryGreen,
            ),
          ),
          const SizedBox(height: 48),

          // Title
          Text(
            item.title,
            style: AppTextStyles.heading2.copyWith(
              fontSize: 24,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),

          // Description
          Text(
            item.description,
            style: AppTextStyles.bodyText.copyWith(
              color: AppColors.textSecondary,
              fontSize: 15,
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class OnboardingItem {
  final String title;
  final String description;
  final IconData icon;
  final Color bgColor;

  OnboardingItem({
    required this.title,
    required this.description,
    required this.icon,
    required this.bgColor,
  });
}
