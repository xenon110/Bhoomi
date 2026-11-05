import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_strings.dart';
import 'screens/advice_screen.dart';
import 'screens/diary/farm_diary_screen.dart';
import 'screens/home_screen.dart';
import 'screens/market_screen.dart';
import 'screens/my_farm_screen.dart';
import 'screens/planner/farm_planner_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/scan/scan_ask_screen.dart';
import 'screens/tools/fertilizer_calculator_screen.dart';
import 'screens/tools/kisan_yojana_screen.dart';
import 'screens/equipment/equipment_rental_screen.dart';
import 'screens/land/land_marketplace_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/intro/onboarding_flow_screen.dart';
import 'screens/intro/intro_scan_screen.dart';
import 'screens/intro/intro_advice_screen.dart';
import 'screens/auth/language_selection_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/otp_screen.dart';
import 'screens/auth/signup_screen.dart';
import 'services/storage_service.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await StorageService().init();
  runApp(const BhoomiApp());
}

class BhoomiApp extends StatelessWidget {
  const BhoomiApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bhoomi',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', ''),
        Locale('hi', ''),
      ],
      routes: {
        '/scan': (_) => const ScanAskScreen(),
        '/planner': (_) => const FarmPlannerScreen(),
        '/diary': (_) => const FarmDiaryScreen(),
        '/fertilizer': (_) => const EquipmentRentalScreen(),
        '/equipment': (_) => const EquipmentRentalScreen(),
        '/land': (_) => const LandMarketplaceScreen(),
        '/yojana': (_) => const KisanYojanaScreen(),
        '/onboarding': (_) => const OnboardingFlowScreen(),
        '/intro_scan': (_) => const IntroScanScreen(),
        '/intro_advice': (_) => const IntroAdviceScreen(),
        '/language': (_) => const LanguageSelectionScreen(),
        '/login': (_) => const LoginScreen(),
        '/otp': (_) => const OtpVerificationScreen(phoneNumber: '9876543210'),
        '/signup': (_) => const SignupProfileScreen(),
        '/main': (_) => const MainNavigation(),
      },
      home: const SplashScreen(),
    );
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({Key? key}) : super(key: key);

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;
  final AppLanguage _lang = AppLanguage();

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _lang,
      builder: (context, _) {
        final List<Widget> pages = [
          HomeScreen(onNavigateTab: _onItemTapped),
          MyFarmScreen(onBackToHome: () => _onItemTapped(0)),
          AdviceScreen(onBackToHome: () => _onItemTapped(0)),
          MarketScreen(onBackToHome: () => _onItemTapped(0)),
          ProfileScreen(onNavigateTab: _onItemTapped),
        ];

        final bottomInset = MediaQuery.of(context).padding.bottom;

        return Scaffold(
          backgroundColor: AppColors.creamBg,
          body: SafeArea(
            bottom: false,
            child: IndexedStack(
              index: _selectedIndex,
              children: pages,
            ),
          ),
          bottomNavigationBar: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(color: AppColors.borderLight, width: 1.0),
              ),
            ),
            padding: EdgeInsets.fromLTRB(12, 8, 12, bottomInset > 0 ? bottomInset + 4 : 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildNavItem(0, Icons.home_outlined, Icons.home_rounded, _lang.t('nav_home')),
                _buildNavItem(1, Icons.spa_outlined, Icons.spa_rounded, _lang.t('nav_farm')),
                _buildNavItem(2, Icons.lightbulb_outline_rounded, Icons.lightbulb_rounded, _lang.t('nav_advice')),
                _buildNavItem(3, Icons.show_chart_rounded, Icons.show_chart_rounded, _lang.t('nav_market')),
                _buildNavItem(4, Icons.person_outline_rounded, Icons.person_rounded, _lang.t('nav_profile')),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildNavItem(int index, IconData outlineIcon, IconData filledIcon, String label) {
    final isSelected = _selectedIndex == index;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _onItemTapped(index),
      child: Container(
        constraints: const BoxConstraints(minWidth: 56, minHeight: 44),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.mintTint : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSelected ? filledIcon : outlineIcon,
              color: isSelected ? AppColors.primaryGreen : AppColors.textMuted,
              size: 22,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Mukta',
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
                color: isSelected ? AppColors.primaryGreen : AppColors.textMuted,
                height: 1.1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
