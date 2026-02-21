// lib/features/home/presentation/pages/onboarding_page.dart

import 'package:flutter/material.dart';    // ← THIS was missing — caused ALL onboarding errors
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../config/routes/route_names.dart';

class OnboardingItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color bgColor;

  const OnboardingItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.bgColor,
  });
}

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingItem> _items = const [
    OnboardingItem(
      title: 'Welcome to Smart Harvest',
      subtitle:
          'Connecting farmers, buyers, and agriculture officers on one platform.',
      icon: Icons.agriculture,
      bgColor: Color(0xFFE8F5E9),
    ),
    OnboardingItem(
      title: 'Real-Time Market Prices',
      subtitle:
          'Get daily crop price updates and weather forecasts directly on your phone.',
      icon: Icons.wb_sunny_outlined,
      bgColor: Color(0xFFFFF8E1),
    ),
    OnboardingItem(
      title: 'Trade Smarter',
      subtitle:
          'Browse listings, place orders, and chat with buyers and officers instantly.',
      icon: Icons.handshake_outlined,
      bgColor: Color(0xFFE3F2FD),
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToNextPage() {
    if (_currentPage < _items.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      if (mounted) {
        Navigator.pushReplacementNamed(context, RouteNames.login);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // ── Top row: page count + skip ─────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 24, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${_currentPage + 1}/${_items.length}',
                    style: AppTextStyles.bodyText.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pushReplacementNamed(
                        context, RouteNames.login),
                    child: Text(
                      'Skip',
                      style: AppTextStyles.bodyText.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Page view ──────────────────────────────────────────────
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _items.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemBuilder: (context, index) {
                  return _buildOnboardingItem(_items[index]);
                },
              ),
            ),

            // ── Bottom: dots + next button ─────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Dot indicators
                  Row(
                    children: List.generate(
                      _items.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _currentPage == index ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? AppColors.primaryGreen
                              : Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                    ),
                  ),

                  // Next / Get Started button
                  GestureDetector(
                    onTap: _goToNextPage,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: _currentPage == _items.length - 1 ? 160 : 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: AppColors.primaryGreen,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryGreen.withOpacity(0.4),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Center(
                        child: _currentPage == _items.length - 1
                            ? Text(
                                'Get Started',
                                style: AppTextStyles.bodyText.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              )
                            : const Icon(
                                Icons.arrow_forward,
                                color: Colors.white,
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
          // Icon circle
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              color: item.bgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(
              item.icon,
              size: 96,
              color: AppColors.primaryGreen,
            ),
          ),

          const SizedBox(height: 48),

          // Title
          Text(
            item.title,
            style: AppTextStyles.heading2.copyWith(fontSize: 24),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 16),

          // Subtitle
          Text(
            item.subtitle,
            style: AppTextStyles.bodyText.copyWith(
              color: AppColors.textSecondary,
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
