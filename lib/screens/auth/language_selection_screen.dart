import 'package:flutter/material.dart';
import '../../l10n/app_strings.dart';
import '../../services/storage_service.dart';
import 'login_screen.dart';

class LanguageSelectionScreen extends StatefulWidget {
  const LanguageSelectionScreen({Key? key}) : super(key: key);

  @override
  State<LanguageSelectionScreen> createState() => _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen> {
  // Currently selected language code
  String _selectedCode = 'hi';

  final List<Map<String, String>> _languages = const [
    {
      'code': 'hi',
      'native': 'हिन्दी',
      'label': 'Hindi',
    },
    {
      'code': 'en',
      'native': 'English',
      'label': 'English',
    },
    {
      'code': 'mr',
      'native': 'मराठी',
      'label': 'Marathi',
    },
    {
      'code': 'bho',
      'native': 'भोजपुरी',
      'label': 'Bhojpuri',
    },
    {
      'code': 'mai',
      'native': 'मैथिली',
      'label': 'Maithili',
    },
    {
      'code': 'ne',
      'native': 'नेपाली',
      'label': 'Nepali',
    },
  ];

  @override
  void initState() {
    super.initState();
    final current = AppLanguage().currentLang;
    if (current == 'English') {
      _selectedCode = 'en';
    } else if (current == 'मराठी') {
      _selectedCode = 'mr';
    } else if (current == 'भोजपुरी') {
      _selectedCode = 'bho';
    } else if (current == 'मैथिली') {
      _selectedCode = 'mai';
    } else if (current == 'नेपाली') {
      _selectedCode = 'ne';
    } else {
      _selectedCode = 'hi';
    }
  }

  void _onContinue() {
    final langItem = _languages.firstWhere(
      (element) => element['code'] == _selectedCode,
      orElse: () => _languages[0],
    );

    final langName = langItem['code'] == 'en' ? 'English' : langItem['native']!;
    AppLanguage().setLanguage(langName);
    StorageService().setLanguage(langName);

    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const LoginScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1, 0),
              end: Offset.zero,
            ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 350),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F2E9),
      body: SafeArea(
        top: true,
        bottom: true,
        child: SizedBox.expand(
          child: FittedBox(
            fit: BoxFit.contain,
            alignment: Alignment.center,
            child: SizedBox(
              width: 390,
              height: 844,
              child: Container(
                color: const Color(0xFFF6F2E9),
                child: Column(
                  children: [
                    // Main Content Section
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 1. Globe Icon Squircle (64x64, #DDEBF3)
                            Container(
                              width: 64,
                              height: 64,
                              decoration: BoxDecoration(
                                color: const Color(0xFFDDEBF3),
                                borderRadius: BorderRadius.circular(22),
                              ),
                              alignment: Alignment.center,
                              child: CustomPaint(
                                size: const Size(34, 34),
                                painter: _GlobeIconPainter(),
                              ),
                            ),
                            const SizedBox(height: 14),

                            // 2. Title & Hindi Subtitle
                            const Text(
                              'Choose your language',
                              style: TextStyle(
                                fontFamily: 'Mukta',
                                fontSize: 32,
                                fontWeight: FontWeight.w800,
                                height: 1.1,
                                color: Color(0xFF1B2A21),
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'अपनी भाषा चुनें',
                              style: TextStyle(
                                fontFamily: 'Mukta',
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF3F5547),
                              ),
                            ),
                            const SizedBox(height: 20),

                            // 3. 2x3 Grid of Languages
                            GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                                childAspectRatio: 169 / 88,
                              ),
                              itemCount: _languages.length,
                              itemBuilder: (context, index) {
                                final item = _languages[index];
                                final isSelected = item['code'] == _selectedCode;

                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _selectedCode = item['code']!;
                                    });
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: isSelected ? const Color(0xFFE2EFDF) : Colors.white,
                                      borderRadius: BorderRadius.circular(22),
                                      border: Border.all(
                                        color: isSelected
                                            ? const Color(0xFF1E4D2B)
                                            : const Color(0xFFE6E0D2),
                                        width: isSelected ? 2.0 : 1.0,
                                      ),
                                    ),
                                    padding: const EdgeInsets.symmetric(horizontal: 16),
                                    child: Stack(
                                      children: [
                                        // Selected Checkmark Badge (top-right)
                                        if (isSelected)
                                          Positioned(
                                            right: 0,
                                            top: 10,
                                            child: Container(
                                              width: 22,
                                              height: 22,
                                              decoration: BoxDecoration(
                                                color: const Color(0xFF1E4D2B),
                                                borderRadius: BorderRadius.circular(11),
                                              ),
                                              alignment: Alignment.center,
                                              child: CustomPaint(
                                                size: const Size(13, 13),
                                                painter: _CheckmarkPainter(),
                                              ),
                                            ),
                                          ),

                                        // Language Names
                                        Align(
                                          alignment: Alignment.centerLeft,
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                item['native']!,
                                                style: const TextStyle(
                                                  fontFamily: 'Mukta',
                                                  fontSize: 24,
                                                  fontWeight: FontWeight.w800,
                                                  height: 1.1,
                                                  color: Color(0xFF1B2A21),
                                                ),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                item['label']!,
                                                style: const TextStyle(
                                                  fontFamily: 'Mukta',
                                                  fontSize: 13.5,
                                                  fontWeight: FontWeight.w600,
                                                  color: Color(0xFF55655A),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),

                    // 4. Continue Button Section
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
                      child: GestureDetector(
                        onTap: _onContinue,
                        child: Container(
                          width: double.infinity,
                          height: 56,
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E4D2B),
                            borderRadius: BorderRadius.circular(28),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0xFF123320),
                                offset: Offset(0, 4),
                                blurRadius: 0,
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Text(
                                'Continue',
                                style: TextStyle(
                                  fontFamily: 'Mukta',
                                  fontSize: 17,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(width: 8),
                              Icon(
                                Icons.arrow_forward_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Custom painter for the Globe SVG icon (circle + latitude/longitude curves)
class _GlobeIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 24.0;
    canvas.save();
    canvas.scale(scale, scale);

    final paint = Paint()
      ..color = const Color(0xFF18566F)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.9
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Outer circle: cx=12, cy=12, r=9
    canvas.drawCircle(const Offset(12, 12), 9, paint);

    // Horizontal equator: M3 12h18
    canvas.drawLine(const Offset(3, 12), const Offset(21, 12), paint);

    // Right meridian: M12 3c3 3 3 15 0 18
    final pathRight = Path();
    pathRight.moveTo(12, 3);
    pathRight.cubicTo(16, 6, 16, 18, 12, 21);
    canvas.drawPath(pathRight, paint);

    // Left meridian: M12 3c-3 3-3 15 0 18
    final pathLeft = Path();
    pathLeft.moveTo(12, 3);
    pathLeft.cubicTo(8, 6, 8, 18, 12, 21);
    canvas.drawPath(pathLeft, paint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Custom painter for the small white checkmark (M5 12l5 5 9-10)
class _CheckmarkPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 24.0;
    canvas.save();
    canvas.scale(scale, scale);

    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.4
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();
    path.moveTo(5, 12);
    path.lineTo(10, 17);
    path.lineTo(19, 7);
    canvas.drawPath(path, paint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

