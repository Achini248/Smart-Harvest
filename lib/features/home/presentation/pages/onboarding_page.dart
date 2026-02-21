import 'package:flutter/material.dart';
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
      image: Icons.agriculture,
    ),
    OnboardingItem(
      title: AppStrings.protectYourHarvest,
      image: Icons.wb_sunny_outlined,
    ),
    OnboardingItem(
      title: AppStrings.yourFarmYourPrice,
      image: Icons.handshake_outlined,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pushReplacementNamed(context, RouteNames.login);
            },
            child: Text(
              AppStrings.skip,
              style: AppTextStyles.bodyTextBold.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
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
          _buildIndicators(),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: List.generate(
                    _items.length,
                    (index) => Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: _currentPage == index ? 32 : 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: _currentPage == index
                            ? AppColors.primaryGreen
                            : AppColors.lightGrey,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ),
                ),
                FloatingActionButton(
                  onPressed: () {
                    if (_currentPage == _items.length - 1) {
                      Navigator.pushReplacementNamed(context, RouteNames.login);
                    } else {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    }
                  },
                  backgroundColor: AppColors.primaryGreen,
                  child: const Icon(Icons.arrow_forward, color: AppColors.white),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildOnboardingItem(OnboardingItem item) {
    return Padding(
      padding: const EdgeInsets.all(40.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              color: AppColors.primaryGreenLight.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              item.image,
              size: 150,
              color: AppColors.primaryGreen,
            ),
          ),
          const SizedBox(height: 48),
          Text(
            item.title,
            style: AppTextStyles.heading2,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildIndicators() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
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
                : AppColors.lightGrey,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }
}

class OnboardingItem {
  final String title;
  final IconData image;

  OnboardingItem({required this.title, required this.image});
}
