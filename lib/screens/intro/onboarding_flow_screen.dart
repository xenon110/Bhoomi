import 'package:flutter/material.dart';
import '../auth/language_selection_screen.dart';
import 'intro_advice_screen.dart';
import 'intro_price_screen.dart';
import 'intro_scan_screen.dart';

class OnboardingFlowScreen extends StatefulWidget {
  const OnboardingFlowScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingFlowScreen> createState() => _OnboardingFlowScreenState();
}

class _OnboardingFlowScreenState extends State<OnboardingFlowScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  void _nextPage() {
    if (_currentPage < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _finishOnboarding();
    }
  }

  void _finishOnboarding() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const LanguageSelectionScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F2E9),
      body: PageView(
        controller: _pageController,
        onPageChanged: (idx) => setState(() => _currentPage = idx),
        physics: const BouncingScrollPhysics(),
        children: [
          IntroScanScreen(onNext: _nextPage),
          IntroAdviceScreen(onNext: _nextPage),
          IntroPriceScreen(onNext: _finishOnboarding),
        ],
      ),
    );
  }
}


