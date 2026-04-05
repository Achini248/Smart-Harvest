// lib/features/home/presentation/pages/home_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../config/routes/route_names.dart';
import '../../../authentication/presentation/bloc/auth_bloc.dart';
import '../../../authentication/presentation/bloc/auth_event.dart';
import '../../../authentication/presentation/bloc/auth_state.dart';
import '../bloc/home_bloc.dart';
import '../bloc/home_event.dart';
import '../bloc/home_state.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/drawer_menu.dart';
import 'profile_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  String? _preferredName;
  bool _dialogShown = false; 

  void _onNavTap(int navIndex) {
    switch (navIndex) {
      case 0:
        setState(() => _selectedIndex = 0);
        break;
      case 1:
        Navigator.pushNamed(context, RouteNames.marketplaceHome);
        break;
      case 2:
        Navigator.pushNamed(context, RouteNames.myCrops);
        break;
      case 3:
        setState(() => _selectedIndex = 1);
        break;
    }
  }

  @override
  void initState() {
    super.initState();
    // FIX: Defer execution and add a small delay to ensure the Widget Tree 
    // and BlocProvider are fully stable before showing a dialog.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) _loadPreferredName();
        });
      }
    });
  }

  Future<void> _loadPreferredName() async {
    if (!mounted) return;

    // Access AuthBloc state safely
    final authState = context.read<AuthBloc>().state;
    if (authState is! Authenticated) return;
    
    final String uid = authState.uid;
    final prefs = await SharedPreferences.getInstance();
    
    if (!mounted) return;
    final stored = prefs.getString('preferred_name_$uid');

    // If name exists (or was skipped), update UI and stop
    if (stored != null) {
      if (mounted && stored != '__skipped__') {
        setState(() => _preferredName = stored);
      }
      return;
    }

    // First time login logic
    if (!_dialogShown && mounted) {
      _showNameDialog(uid);
    }
  }

  Future<void> _showNameDialog(String uid) async {
    if (_dialogShown || !mounted) return;
    _dialogShown = true;

    final ctrl = TextEditingController();
    String? result;
    
    try {
      result = await showDialog<String>(
        context: context,
        barrierDismissible: false,
        builder: (dlgCtx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Welcome to Smart Harvest! 🌿'),
          content: Column(
            mainAxisSize: MainAxisSize.min, 
            children: [
              const Text('How would you like us to address you?',
                  style: TextStyle(color: Colors.black54)),
              const SizedBox(height: 16),
              TextField(
                controller: ctrl,
                autofocus: true,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  hintText: 'e.g. Kasun, Nimal...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.primaryGreen, width: 2),
                  ),
                  prefixIcon: const Icon(Icons.person_outline),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dlgCtx).pop('__skipped__'),
              child: const Text('Skip'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () {
                final name = ctrl.text.trim();
                Navigator.of(dlgCtx).pop(name.isEmpty ? '__skipped__' : name);
              },
              child: const Text('Save', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
    } finally {
      ctrl.dispose();
    }

    if (!mounted) return;
    final prefs = await SharedPreferences.getInstance();
    
    // Save the result locally so the dialog doesn't repeat
    if (result == '__skipped__' || result == null || result.isEmpty) {
      await prefs.setString('preferred_name_$uid', '__skipped__');
    } else {
      await prefs.setString('preferred_name_$uid', result);
      if (mounted) setState(() => _preferredName = result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is Unauthenticated) {
          Navigator.pushNamedAndRemoveUntil(context, RouteNames.authSelection, (_) => false);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(AppStrings.appName, style: AppTextStyles.heading3),
          actions: [
            IconButton(
              icon: const Icon(Icons.notifications_outlined),
              onPressed: () => Navigator.pushNamed(context, RouteNames.notifications),
              tooltip: 'Notifications',
            ),
          ],
        ),
        drawer: const DrawerMenu(),
        body: IndexedStack(
          index: _selectedIndex,
          children: [
            _HomeTab(preferredName: _preferredName),
            const ProfilePage(),
          ],
        ),
        bottomNavigationBar: BottomNavBar(
          currentIndex: _selectedIndex == 0 ? 0 : 3,
          onTap: _onNavTap,
        ),
      ),
    );
  }
}

// ── Home Tab ──────────────────────────────────────────────────────────────────
class _HomeTab extends StatelessWidget {
  final String? preferredName;
  const _HomeTab({this.preferredName});
  @override
  Widget build(BuildContext context) => BlocProvider(
        create: (_) => HomeBloc()..add(const LoadHomeDataEvent()),
        child: _HomeTabView(preferredName: preferredName),
      );
}

class _HomeTabView extends StatelessWidget {
  final String? preferredName;
  const _HomeTabView({this.preferredName});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        return RefreshIndicator(
          color: AppColors.primaryGreen,
          onRefresh: () async {
            context.read<HomeBloc>().add(const RefreshHomeDataEvent());
            await Future.delayed(const Duration(milliseconds: 800));
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const SizedBox(height: 16),

              if (state is HomeError)
                Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF3CD),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFFFE066)),
                  ),
                  child: Row(children: [
                    const Icon(Icons.wifi_off_rounded, size: 18, color: Color(0xFF856404)),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'Backend not reachable. Make sure the Flask server is running.',
                        style: TextStyle(fontSize: 12, color: Color(0xFF856404)),
                      ),
                    ),
                    GestureDetector(
                      onTap: () =>
                          context.read<HomeBloc>().add(const RefreshHomeDataEvent()),
                      child: const Padding(
                        padding: EdgeInsets.only(left: 8),
                        child: Icon(Icons.refresh, size: 18, color: Color(0xFF856404)),
                      ),
                    ),
                  ]),
                ),

              _GreetingCard(preferredName: preferredName),
              const SizedBox(height: 20),

              if (state is HomeLoaded && state.weather != null) ...[
                _WeatherCard(weather: state.weather!),
                const SizedBox(height: 20),
              ] else if (state is HomeLoading) ...[
                _Skeleton(height: 72, radius: 16),
                const SizedBox(height: 20),
              ],

              Text('Quick Actions', style: AppTextStyles.heading3),
              const SizedBox(height: 12),
              const _QuickActions(),
              const SizedBox(height: 20),

              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('Live Market Prices', style: AppTextStyles.heading3),
                TextButton(
                  onPressed: () =>
                      Navigator.pushNamed(context, RouteNames.dailyMarketPrices),
                  child: const Text('See All',
                      style: TextStyle(color: AppColors.primaryGreen)),
                ),
              ]),
              const SizedBox(height: 8),
              _PricesSection(state: state),
              const SizedBox(height: 20),

              Text('Agriculture News', style: AppTextStyles.heading3),
              const SizedBox(height: 12),
              _NewsSection(state: state),
            ]),
          ),
        );
      },
    );
  }
}

class _Skeleton extends StatelessWidget {
  final double height;
  final double radius;
  const _Skeleton({required this.height, this.radius = 8});
  @override
  Widget build(BuildContext context) => Container(
        height: height,
        decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(radius)));
}

// ── Greeting Card ─────────────────────────────────────────────────────────────
class _GreetingCard extends StatelessWidget {
  final String? preferredName;
  const _GreetingCard({this.preferredName});
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final isGuest = state is! Authenticated;
        String name = 'Welcome';
        if (!isGuest) {
          name = preferredName ??
              (state as Authenticated).displayName?.split(' ').first ??
              'Farmer';
        }
        final h = DateTime.now().hour;
        final greeting =
            h < 12 ? 'Good Morning' : h < 17 ? 'Good Afternoon' : 'Good Evening';
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primaryGreen, AppColors.primaryGreenLight],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(children: [
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('$greeting,',
                    style: const TextStyle(color: Colors.white70, fontSize: 14)),
                const SizedBox(height: 4),
                Text(
                  isGuest ? 'Hello, Welcome' : 'Hello, $name',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 6),
                Text(
                  DateFormat('EEEE, d MMMM yyyy').format(DateTime.now()),
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
                if (isGuest) ...[
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: () => Navigator.pushNamed(context, RouteNames.login),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: Colors.white.withOpacity(0.5)),
                      ),
                      child: const Text('Sign In →',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ]),
            ),
            const Icon(Icons.eco, size: 56, color: Colors.white),
          ]),
        );
      },
    );
  }
}

// ── Weather Card ──────────────────────────────────────────────────────────────
class _WeatherCard extends StatelessWidget {
  final WeatherSummary weather;
  const _WeatherCard({required this.weather});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, RouteNames.weatherOverview),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.blue.shade100),
        ),
        child: Row(children: [
          Icon(_icon(weather.condition), color: Colors.blue.shade600, size: 36),
          const SizedBox(width: 14),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Text(weather.condition,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 15)),
                const SizedBox(width: 8),
                Text('${weather.temperature.toStringAsFixed(0)}°C',
                    style: TextStyle(
                        color: Colors.blue.shade700,
                        fontWeight: FontWeight.w600)),
              ]),
              const SizedBox(height: 4),
              Text(weather.farmingAdvice,
                  style: TextStyle(fontSize: 12, color: Colors.blue.shade800),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis),
            ]),
          ),
          Icon(Icons.chevron_right, color: Colors.blue.shade400),
        ]),
      ),
    );
  }

  IconData _icon(String c) {
    final l = c.toLowerCase();
    if (l.contains('rain') || l.contains('drizzle')) return Icons.grain;
    if (l.contains('storm') || l.contains('thunder')) return Icons.thunderstorm;
    if (l.contains('cloud')) return Icons.cloud;
    if (l.contains('haze') || l.contains('mist') || l.contains('fog'))
      return Icons.blur_on;
    return Icons.wb_sunny;
  }
}

// ── Quick Actions ─────────────────────────────────────────────────────────────
class _QuickActions extends StatelessWidget {
  const _QuickActions();
  @override
  Widget build(BuildContext context) {
    final items = [
      _QA('My Crops', Icons.agriculture, RouteNames.myCrops),
      _QA('Prices', Icons.trending_up, RouteNames.dailyMarketPrices),
      _QA('Weather', Icons.wb_sunny, RouteNames.weatherOverview),
      _QA('Messages', Icons.message, RouteNames.messagesList),
    ];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: items
          .map((a) => GestureDetector(
                onTap: () => Navigator.pushNamed(context, a.route),
                child: SizedBox(
                  width: 72,
                  child: Column(children: [
                    Container(
                      width: 54,
                      height: 54,
                      decoration: BoxDecoration(
                        color: AppColors.primaryGreen.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(a.icon,
                          color: AppColors.primaryGreen, size: 26),
                    ),
                    const SizedBox(height: 6),
                    Text(a.label,
                        style: const TextStyle(
                            fontSize: 11, fontWeight: FontWeight.w600),
                        textAlign: TextAlign.center,
                        maxLines: 2),
                  ]),
                ),
              ))
          .toList(),
    );
  }
}

class _QA {
  final String label;
  final IconData icon;
  final String route;
  const _QA(this.label, this.icon, this.route);
}

// ── Prices Section ────────────────────────────────────────────────────────────
class _PricesSection extends StatelessWidget {
  final HomeState state;
  const _PricesSection({required this.state});
  @override
  Widget build(BuildContext context) {
    if (state is HomeLoading) {
      return Column(
        children: List.generate(
          3,
          (_) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Container(
              height: 64,
              decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
      );
    }
    if (state is HomeLoaded) {
      final prices = (state as HomeLoaded).topPrices;
      if (prices.isEmpty) return _empty('No price data available today.');
      return Column(children: prices.map((p) => _PriceRow(p)).toList());
    }
    return _empty('No price data available today.');
  }

  Widget _empty(String msg) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(12)),
        child:
            Text(msg, style: const TextStyle(color: AppColors.textSecondary)));
}

class _PriceRow extends StatelessWidget {
  final TopPriceItem p;
  const _PriceRow(this.p);
  @override
  Widget build(BuildContext context) {
    final isUp = p.priceChange >= 0;
    final color = isUp ? AppColors.success : AppColors.error;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 6,
              offset: const Offset(0, 2))
        ],
      ),
      child: Row(children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: p.isSurplus
                ? AppColors.success
                : p.isShortage
                    ? AppColors.error
                    : AppColors.warning,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(p.cropName,
                style: const TextStyle(
                    fontWeight: FontWeight.w700, fontSize: 14)),
            Text(
              p.isSurplus
                  ? 'Surplus'
                  : p.isShortage
                      ? 'Shortage'
                      : 'Normal',
              style: TextStyle(
                fontSize: 11,
                color: p.isSurplus
                    ? AppColors.success
                    : p.isShortage
                        ? AppColors.error
                        : AppColors.textSecondary,
              ),
            ),
          ]),
        ),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text('LKR ${p.avgPrice.toStringAsFixed(0)}/kg',
              style: const TextStyle(
                  fontWeight: FontWeight.w700, fontSize: 14)),
          if (p.predictedPrice != null)
            Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(isUp ? Icons.arrow_upward : Icons.arrow_downward,
                  size: 12, color: color),
              Text('${p.priceChangePct.abs().toStringAsFixed(1)}%',
                  style: TextStyle(fontSize: 11, color: color)),
            ]),
        ]),
      ]),
    );
  }
}

// ── News Section ──────────────────────────────────────────────────────────────
class _NewsSection extends StatelessWidget {
  final HomeState state;
  const _NewsSection({required this.state});
  @override
  Widget build(BuildContext context) {
    if (state is HomeLoading) {
      return Column(
        children: List.generate(
          2,
          (_) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Container(
              height: 140,
              decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(16)),
            ),
          ),
        ),
      );
    }
    if (state is HomeLoaded) {
      final news = (state as HomeLoaded).news;
      if (news.isEmpty) return _empty('No news available right now.');
      return Column(children: news.map((n) => _NewsCard(n)).toList());
    }
    return _empty('No news available right now.');
  }

  Widget _empty(String msg) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(12)),
        child:
            Text(msg, style: const TextStyle(color: AppColors.textSecondary)));
}

class _NewsCard extends StatelessWidget {
  final NewsItem item;
  const _NewsCard(this.item);
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 3))
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        if (item.imageUrl.isNotEmpty)
          ClipRRect(
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(16)),
            child: Image.network(
              item.imageUrl,
              height: 130,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _banner(),
            ),
          )
        else
          _banner(),
        Padding(
          padding: const EdgeInsets.all(14),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(item.title,
                style: const TextStyle(
                    fontWeight: FontWeight.w700, fontSize: 14),
                maxLines: 2,
                overflow: TextOverflow.ellipsis),
            const SizedBox(height: 6),
            Text(item.description,
                style: const TextStyle(
                    fontSize: 12, color: AppColors.textSecondary),
                maxLines: 3,
                overflow: TextOverflow.ellipsis),
            const SizedBox(height: 8),
            Row(children: [
              const Icon(Icons.source,
                  size: 12, color: AppColors.textSecondary),
              const SizedBox(width: 4),
              Expanded(
                child: Text(item.source,
                    style: const TextStyle(
                        fontSize: 11, color: AppColors.textSecondary),
                    overflow: TextOverflow.ellipsis),
              ),
              Text(_fmt(item.publishedAt),
                  style: const TextStyle(
                      fontSize: 11, color: AppColors.textSecondary)),
            ]),
          ]),
        ),
      ]),
    );
  }

  Widget _banner() {
    final bg = switch (item.category) {
      'Supply Alert' => const Color(0xFFFFF3CD),
      'Market Update' => const Color(0xFFE3F2FD),
      _ => const Color(0xFFE8F5E9),
    };
    return Container(
      height: 44,
      decoration: BoxDecoration(
          color: bg,
          borderRadius:
              const BorderRadius.vertical(top: Radius.circular(16))),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(children: [
        const Icon(Icons.article_outlined,
            size: 16, color: AppColors.primaryGreen),
        const SizedBox(width: 8),
        Text(item.category,
            style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 12,
                color: AppColors.primaryGreen)),
      ]),
    );
  }

  String _fmt(String raw) {
    try {
      return DateFormat('d MMM').format(DateTime.parse(raw));
    } catch (_) {
      return raw.length > 10 ? raw.substring(0, 10) : raw;
    }
  }
}