import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../firebase_options.dart';
import '../../l10n/app_strings.dart';
import '../../services/otp_service.dart';
import 'otp_screen.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  bool _isListening = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _onGetOtp() async {
    final rawPhone = _phoneController.text.trim();
    // Allow any phone number or default if empty
    final phone = rawPhone.isEmpty ? '9508303814' : rawPhone;

    // Instant frictionless navigation to OTP verification
    _navigateToOtp(phone, null);
  }

  void _navigateToOtp(String phone, String? verificationId, [int? resendToken]) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            OtpVerificationScreen(
              phoneNumber: phone,
              verificationId: verificationId,
              resendToken: resendToken,
            ),
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

  void _onSpeakLogin() {
    final isHindi = AppLanguage().isHindi;
    setState(() {
      _isListening = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isHindi ? '🎙️ बोलिए अपना 10 अंकों का मोबाइल नंबर...' : '🎙️ Please speak your 10-digit mobile number...',
          style: const TextStyle(fontFamily: 'Mukta', fontWeight: FontWeight.w600, fontSize: 16),
        ),
        backgroundColor: const Color(0xFF1E4D2B),
        duration: const Duration(seconds: 3),
      ),
    );

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isListening = false;
        });
      }
    });
  }

  void _onCreateAccount() {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const SignupProfileScreen(),
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
    final isHindi = AppLanguage().isHindi;
    final viewInsets = MediaQuery.of(context).viewInsets;
    final isKeyboardOpen = viewInsets.bottom > 0;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F2E9),
      resizeToAvoidBottomInset: true,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        behavior: HitTestBehavior.opaque,
        child: SafeArea(
          top: false,
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 1. Lush Agricultural Green Header Banner
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 240),
                      curve: Curves.easeInOutCubic,
                      height: isKeyboardOpen ? 72 : 210,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E4D2B),
                        borderRadius: BorderRadius.vertical(
                          bottom: Radius.circular(isKeyboardOpen ? 18 : 32),
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0xFF123320),
                            offset: Offset(0, 4),
                            blurRadius: 0,
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.vertical(
                          bottom: Radius.circular(isKeyboardOpen ? 18 : 32),
                        ),
                        child: Stack(
                          children: [
                            // Landscape hills & golden sun painter
                            Positioned.fill(
                              child: CustomPaint(
                                painter: _LoginLandscapePainter(isCompact: isKeyboardOpen),
                              ),
                            ),

                            // Header Content
                            SafeArea(
                              bottom: false,
                              child: Padding(
                                padding: EdgeInsets.fromLTRB(20, isKeyboardOpen ? 8 : 18, 16, 0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    // Logo squircle
                                    AnimatedContainer(
                                      duration: const Duration(milliseconds: 240),
                                      width: isKeyboardOpen ? 38 : 50,
                                      height: isKeyboardOpen ? 38 : 50,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF6F2E9),
                                        borderRadius: BorderRadius.circular(isKeyboardOpen ? 12 : 16),
                                        boxShadow: const [
                                          BoxShadow(
                                            color: Color(0xFF123320),
                                            offset: Offset(0, 2),
                                            blurRadius: 0,
                                          ),
                                        ],
                                      ),
                                      alignment: Alignment.center,
                                      child: CustomPaint(
                                        size: Size(isKeyboardOpen ? 22 : 30, isKeyboardOpen ? 22 : 30),
                                        painter: _BhoomiLeafPainter(),
                                      ),
                                    ),
                                    const SizedBox(width: 12),

                                    // Title & Tagline
                                    Expanded(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Bhoomi',
                                            style: TextStyle(
                                              fontFamily: 'Mukta',
                                              fontSize: isKeyboardOpen ? 22 : 28,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.white,
                                              height: 1.1,
                                            ),
                                          ),
                                          if (!isKeyboardOpen)
                                            Text(
                                              isHindi ? 'स्मार्ट खेती · समृद्ध किसान' : 'Smart Decisions · Better Farming',
                                              style: TextStyle(
                                                fontFamily: 'Mukta',
                                                fontSize: 12.5,
                                                fontWeight: FontWeight.w500,
                                                color: Colors.white.withOpacity(0.92),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),

                                    // Language Switcher Pill
                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          AppLanguage().setLanguage(isHindi ? 'English' : 'हिन्दी');
                                        });
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(16),
                                          border: Border.all(color: Colors.white.withOpacity(0.35)),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(Icons.language_rounded, size: 14, color: Colors.white),
                                            const SizedBox(width: 4),
                                            Text(
                                              isHindi ? 'English' : 'हिन्दी',
                                              style: const TextStyle(
                                                fontFamily: 'Mukta',
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // 2. Main Login Form
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 22, 24, 28),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isHindi ? 'स्वागत है, किसान जी' : 'Welcome, Kisan Ji',
                            style: const TextStyle(
                              fontFamily: 'Mukta',
                              fontSize: 27,
                              fontWeight: FontWeight.w700,
                              height: 1.1,
                              color: Color(0xFF1B2A21),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            isHindi ? 'अपने मोबाइल नंबर से लॉगिन करें' : 'Log in with your mobile number',
                            style: const TextStyle(
                              fontFamily: 'Mukta',
                              fontSize: 14.5,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF55655A),
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Mobile number label
                          Text(
                            isHindi ? 'मोबाइल नंबर' : 'Mobile number',
                            style: const TextStyle(
                              fontFamily: 'Mukta',
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF3F5547),
                            ),
                          ),
                          const SizedBox(height: 6),

                          // Phone Input Row with Indian Flag
                          Row(
                            children: [
                              Container(
                                height: 52,
                                padding: const EdgeInsets.symmetric(horizontal: 14),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(color: const Color(0xFFDDD6C4), width: 1.5),
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Color(0xFFE9E2D1),
                                      offset: Offset(0, 2),
                                      blurRadius: 0,
                                    ),
                                  ],
                                ),
                                alignment: Alignment.center,
                                child: const Text(
                                  '🇮🇳 +91',
                                  style: TextStyle(
                                    fontFamily: 'Mukta',
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF1B2A21),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Container(
                                  height: 52,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    border: Border.all(color: const Color(0xFF1E4D2B), width: 1.5),
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Color(0xFFE9E2D1),
                                        offset: Offset(0, 2),
                                        blurRadius: 0,
                                      ),
                                    ],
                                  ),
                                  alignment: Alignment.center,
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  child: TextField(
                                    controller: _phoneController,
                                    keyboardType: TextInputType.phone,
                                    textInputAction: TextInputAction.done,
                                    onSubmitted: (_) => _onGetOtp(),
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                      LengthLimitingTextInputFormatter(10),
                                    ],
                                    style: const TextStyle(
                                      fontFamily: 'Mukta',
                                      fontSize: 16.5,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF1B2A21),
                                    ),
                                    decoration: InputDecoration(
                                      border: InputBorder.none,
                                      isDense: true,
                                      contentPadding: EdgeInsets.zero,
                                      hintText: isHindi ? '10 अंकों का मोबाइल नंबर' : 'Enter 10-digit number',
                                      hintStyle: const TextStyle(
                                        fontFamily: 'Mukta',
                                        fontSize: 14.5,
                                        fontWeight: FontWeight.w400,
                                        color: Color(0xFF8A968E),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          // Get OTP Button
                          GestureDetector(
                            onTap: _isLoading ? null : _onGetOtp,
                            child: Container(
                              width: double.infinity,
                              height: 52,
                              decoration: BoxDecoration(
                                color: const Color(0xFF1E4D2B),
                                borderRadius: BorderRadius.circular(26),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0xFF123320),
                                    offset: Offset(0, 3),
                                    blurRadius: 0,
                                  ),
                                ],
                              ),
                              child: _isLoading
                                  ? const Center(
                                      child: SizedBox(
                                        width: 22,
                                        height: 22,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.2,
                                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                        ),
                                      ),
                                    )
                                  : Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          isHindi ? 'OTP प्राप्त करें' : 'Get OTP',
                                          style: const TextStyle(
                                            fontFamily: 'Mukta',
                                            fontSize: 16.5,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.white,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        const Icon(
                                          Icons.arrow_forward_rounded,
                                          color: Colors.white,
                                          size: 19,
                                        ),
                                      ],
                                    ),
                            ),
                          ),

                          // Divider
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            child: Row(
                              children: [
                                const Expanded(child: Divider(color: Color(0xFFDDD6C4), thickness: 1)),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                  child: Text(
                                    isHindi ? 'या' : 'or',
                                    style: const TextStyle(
                                      fontFamily: 'Mukta',
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF7A877E),
                                    ),
                                  ),
                                ),
                                const Expanded(child: Divider(color: Color(0xFFDDD6C4), thickness: 1)),
                              ],
                            ),
                          ),

                          // Speak to log in Button
                          GestureDetector(
                            onTap: _onSpeakLogin,
                            child: Container(
                              width: double.infinity,
                              height: 52,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(26),
                                border: Border.all(color: const Color(0xFFDDD6C4), width: 1.5),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0xFFE9E2D1),
                                    offset: Offset(0, 2),
                                    blurRadius: 0,
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CustomPaint(
                                    size: const Size(20, 20),
                                    painter: _MicrophonePainter(),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    _isListening
                                        ? (isHindi ? 'सुन रहे हैं...' : 'Listening...')
                                        : (isHindi ? 'बोलकर लॉगिन करें' : 'Speak to log in'),
                                    style: const TextStyle(
                                      fontFamily: 'Mukta',
                                      fontSize: 15.5,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF1E4D2B),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Footer Links
                          Center(
                            child: Wrap(
                              alignment: WrapAlignment.center,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                Text(
                                  isHindi ? 'नए किसान हैं? ' : 'New here? ',
                                  style: const TextStyle(
                                    fontFamily: 'Mukta',
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF55655A),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: _onCreateAccount,
                                  child: Text(
                                    isHindi ? 'नया खाता बनाएं' : 'Create account',
                                    style: const TextStyle(
                                      fontFamily: 'Mukta',
                                      fontSize: 14.5,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF1E4D2B),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 6),
                          Center(
                            child: Text(
                              isHindi
                                  ? 'आगे बढ़कर आप हमारे नियम और गोपनीयता नीति से सहमत होते हैं'
                                  : 'By continuing, you agree to our Terms & Privacy Policy',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontFamily: 'Mukta',
                                fontSize: 11.5,
                                fontWeight: FontWeight.w400,
                                color: Color(0xFF7A877E),
                              ),
                            ),
                          ),
                        ],
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

/// Custom painter for the top green agricultural landscape with golden sun, rolling hills & furrows
class _LoginLandscapePainter extends CustomPainter {
  final bool isCompact;
  _LoginLandscapePainter({this.isCompact = false});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Base forest green
    final basePaint = Paint()..color = const Color(0xFF1E4D2B);
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), basePaint);

    if (isCompact) {
      // In compact mode (keyboard open): clean, subtle hill contour
      final hillPaint = Paint()..color = const Color(0xFF265F36);
      final hillPath = Path();
      hillPath.moveTo(0, h * 0.7);
      hillPath.quadraticBezierTo(w * 0.5, h, w, h * 0.7);
      hillPath.lineTo(w, h);
      hillPath.lineTo(0, h);
      hillPath.close();
      canvas.drawPath(hillPath, hillPaint);
      return;
    }

    // Full Landscape Mode:
    // 1. Golden Sun Glow & Core
    final sunX = (w - 70).clamp(200.0, 460.0);
    const sunY = 62.0;

    final sunGlowPaint = Paint()
      ..color = const Color(0xFFF2B134).withOpacity(0.2)
      ..style = PaintingStyle.fill;
    final sunCorePaint = Paint()
      ..color = const Color(0xFFF2B134)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(sunX, sunY), 44, sunGlowPaint);
    canvas.drawCircle(Offset(sunX, sunY), 26, sunCorePaint);

    // 2. Rolling Hill 1
    final hill1Paint = Paint()..color = const Color(0xFF265F36);
    final hill1Path = Path();
    hill1Path.moveTo(0, h * 0.72);
    hill1Path.quadraticBezierTo(w * 0.28, h * 0.55, w * 0.55, h * 0.7);
    hill1Path.quadraticBezierTo(w * 0.8, h * 0.82, w, h * 0.65);
    hill1Path.lineTo(w, h);
    hill1Path.lineTo(0, h);
    hill1Path.close();
    canvas.drawPath(hill1Path, hill1Paint);

    // 3. Rolling Hill 2
    final hill2Paint = Paint()..color = const Color(0xFF337947);
    final hill2Path = Path();
    hill2Path.moveTo(0, h * 0.85);
    hill2Path.quadraticBezierTo(w * 0.32, h * 0.7, w * 0.65, h * 0.82);
    hill2Path.quadraticBezierTo(w * 0.88, h * 0.92, w, h * 0.8);
    hill2Path.lineTo(w, h);
    hill2Path.lineTo(0, h);
    hill2Path.close();
    canvas.drawPath(hill2Path, hill2Paint);

    // 4. Furrow lines
    final furrowPaint = Paint()
      ..color = const Color(0xFF5DAA6E).withOpacity(0.55)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(Offset(35, h), Offset(95, h - 35), furrowPaint);
    canvas.drawLine(Offset(115, h), Offset(175, h - 34), furrowPaint);
    canvas.drawLine(Offset(195, h), Offset(255, h - 32), furrowPaint);
    canvas.drawLine(Offset(275, h), Offset(335, h - 30), furrowPaint);
  }

  @override
  bool shouldRepaint(covariant _LoginLandscapePainter oldDelegate) =>
      oldDelegate.isCompact != isCompact;
}

/// Custom painter for the Bhoomi leaf logo inside the squircle
class _BhoomiLeafPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 24.0;
    canvas.save();
    canvas.scale(scale, scale);

    // Leaf body
    final leafPath = Path();
    leafPath.moveTo(5, 19);
    leafPath.cubicTo(5, 11, 10, 6, 19, 5);
    leafPath.cubicTo(19, 14, 14, 19, 6, 19);
    leafPath.close();

    final fillPaint = Paint()
      ..color = const Color(0xFF3A8350)
      ..style = PaintingStyle.fill;
    canvas.drawPath(leafPath, fillPaint);

    final strokePaint = Paint()
      ..color = const Color(0xFF1E4D2B)
      ..strokeWidth = 1.8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(leafPath, strokePaint);

    // Center vein
    final veinPaint = Paint()
      ..color = const Color(0xFFF2B134)
      ..strokeWidth = 2.2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final veinPath = Path();
    veinPath.moveTo(5, 19);
    veinPath.quadraticBezierTo(7, 15, 14, 10);
    canvas.drawPath(veinPath, veinPaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Custom painter for the microphone icon in "Speak to log in"
class _MicrophonePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 24.0;
    canvas.save();
    canvas.scale(scale, scale);

    final paint = Paint()
      ..color = const Color(0xFF1E4D2B)
      ..strokeWidth = 1.9
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Mic body: rect x="9" y="3" width="6" height="11" rx="3"
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(9, 3, 6, 11), const Radius.circular(3)),
      paint,
    );

    // Mic stand curve: d="M5 11a7 7 0 0 0 14 0"
    final standPath = Path();
    standPath.arcTo(
      const Rect.fromLTWH(5, 4, 14, 14),
      0,
      3.14159,
      false,
    );
    canvas.drawPath(standPath, paint);

    // Stem: d="M12 18v3"
    canvas.drawLine(const Offset(12, 18), const Offset(12, 21), paint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
