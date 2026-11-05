import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _onGetOtp() {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty || phone.length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please enter a valid 10-digit mobile number',
            style: TextStyle(fontFamily: 'Mukta', fontWeight: FontWeight.w600),
          ),
          backgroundColor: Color(0xFF1E4D2B),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            OtpVerificationScreen(phoneNumber: phone),
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
    setState(() {
      _isListening = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          '🎙️ बोलिए अपना 10 अंकों का मोबाइल नंबर...',
          style: TextStyle(fontFamily: 'Mukta', fontWeight: FontWeight.w700, fontSize: 16),
        ),
        backgroundColor: Color(0xFF1E4D2B),
        duration: Duration(seconds: 3),
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
    return Scaffold(
      backgroundColor: const Color(0xFFF6F2E9),
      body: SafeArea(
        top: false,
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
                    // 1. Top 250px Forest Green Landscape Header
                    SizedBox(
                      height: 250,
                      width: 390,
                      child: Stack(
                        children: [
                          // Background Hills & Sun Custom Painter
                          CustomPaint(
                            size: const Size(390, 250),
                            painter: _LoginLandscapePainter(),
                          ),

                          // Bhoomi Leaf Logo & Title
                          Positioned(
                            left: 24,
                            top: 56,
                            child: Row(
                              children: [
                                // Leaf Squircle
                                Container(
                                  width: 56,
                                  height: 56,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF6F2E9),
                                    borderRadius: BorderRadius.circular(18),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Color(0xFF123320),
                                        offset: Offset(0, 3),
                                        blurRadius: 0,
                                      ),
                                    ],
                                  ),
                                  alignment: Alignment.center,
                                  child: CustomPaint(
                                    size: const Size(34, 34),
                                    painter: _BhoomiLeafPainter(),
                                  ),
                                ),
                                const SizedBox(width: 12),

                                const Text(
                                  'Bhoomi',
                                  style: TextStyle(
                                    fontFamily: 'Mukta',
                                    fontSize: 30,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // 2. Bottom Card Sheet (-28px overlap)
                    Expanded(
                      child: Transform.translate(
                        offset: const Offset(0, -28),
                        child: Container(
                          width: 390,
                          decoration: const BoxDecoration(
                            color: Color(0xFFF6F2E9),
                            borderRadius: BorderRadius.vertical(top: Radius.circular(34)),
                          ),
                          padding: const EdgeInsets.fromLTRB(24, 26, 24, 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Headline
                              const Text(
                                'Welcome, Kisan Ji',
                                style: TextStyle(
                                  fontFamily: 'Mukta',
                                  fontSize: 30,
                                  fontWeight: FontWeight.w800,
                                  height: 1.1,
                                  color: Color(0xFF1B2A21),
                                ),
                              ),
                              const SizedBox(height: 6),

                              // Subtitle
                              const Text(
                                'Log in with your mobile number',
                                style: TextStyle(
                                  fontFamily: 'Mukta',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF55655A),
                                ),
                              ),

                              const SizedBox(height: 22),

                              // Label: Mobile number
                              const Text(
                                'Mobile number',
                                style: TextStyle(
                                  fontFamily: 'Mukta',
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF3F5547),
                                ),
                              ),
                              const SizedBox(height: 6),

                              // Phone Input Row: [+91] + [Number Field]
                              Row(
                                children: [
                                  // Flag + 91 Prefix
                                  Container(
                                    height: 56,
                                    padding: const EdgeInsets.symmetric(horizontal: 16),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      border: Border.all(color: const Color(0xFFDDD6C4), width: 1.5),
                                      borderRadius: BorderRadius.circular(18),
                                    ),
                                    alignment: Alignment.center,
                                    child: const Text(
                                      '🇮🇳 +91',
                                      style: TextStyle(
                                        fontFamily: 'Mukta',
                                        fontSize: 17,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF1B2A21),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),

                                  // Mobile input
                                  Expanded(
                                    child: Container(
                                      height: 56,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        border: Border.all(color: const Color(0xFF1E4D2B), width: 1.5),
                                        borderRadius: BorderRadius.circular(18),
                                      ),
                                      alignment: Alignment.center,
                                      padding: const EdgeInsets.symmetric(horizontal: 16),
                                      child: TextField(
                                        controller: _phoneController,
                                        keyboardType: TextInputType.phone,
                                        inputFormatters: [
                                          FilteringTextInputFormatter.digitsOnly,
                                          LengthLimitingTextInputFormatter(10),
                                        ],
                                        style: const TextStyle(
                                          fontFamily: 'Mukta',
                                          fontSize: 17,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF1B2A21),
                                        ),
                                        decoration: const InputDecoration(
                                          border: InputBorder.none,
                                          isDense: true,
                                          contentPadding: EdgeInsets.zero,
                                          hintText: 'Enter 10-digit number',
                                          hintStyle: TextStyle(
                                            fontFamily: 'Mukta',
                                            fontSize: 17,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFF8A968E),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 18),

                              // Get OTP Button
                              GestureDetector(
                                onTap: _onGetOtp,
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
                                        'Get OTP',
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

                              // Divider "or"
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                child: Row(
                                  children: const [
                                    Expanded(
                                      child: Divider(
                                        color: Color(0xFFDDD6C4),
                                        thickness: 1,
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 12),
                                      child: Text(
                                        'or',
                                        style: TextStyle(
                                          fontFamily: 'Mukta',
                                          fontSize: 13.5,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF7A877E),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Divider(
                                        color: Color(0xFFDDD6C4),
                                        thickness: 1,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Speak to log in Button
                              GestureDetector(
                                onTap: _onSpeakLogin,
                                child: Container(
                                  width: double.infinity,
                                  height: 56,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(28),
                                    border: Border.all(color: const Color(0xFF1E4D2B), width: 1.5),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      CustomPaint(
                                        size: const Size(22, 22),
                                        painter: _MicrophonePainter(),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        _isListening ? 'Listening...' : 'Speak to log in',
                                        style: const TextStyle(
                                          fontFamily: 'Mukta',
                                          fontSize: 16.5,
                                          fontWeight: FontWeight.w800,
                                          color: Color(0xFF1E4D2B),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              const Spacer(),

                              // Footer: New here? Create account
                              Center(
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Text(
                                      'New here? ',
                                      style: TextStyle(
                                        fontFamily: 'Mukta',
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF55655A),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: _onCreateAccount,
                                      child: const Text(
                                        'Create account',
                                        style: TextStyle(
                                          fontFamily: 'Mukta',
                                          fontSize: 15,
                                          fontWeight: FontWeight.w800,
                                          color: Color(0xFF1E4D2B),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 2),

                              // Terms disclaimer
                              const Center(
                                child: Text(
                                  'By continuing, you agree to our Terms & Privacy Policy',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontFamily: 'Mukta',
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF7A877E),
                                  ),
                                ),
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

/// Custom painter for the top 250px green landscape with sun, hills, and furrow lines
class _LoginLandscapePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // 1. Base forest green background
    final basePaint = Paint()..color = const Color(0xFF1E4D2B);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), basePaint);

    // 2. Sun Outer Glow (cx: 320, cy: 60, r: 44, opacity: 0.22, color: #F2B134)
    final sunGlowPaint = Paint()
      ..color = const Color(0xFFF2B134).withOpacity(0.22)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(const Offset(320, 60), 44, sunGlowPaint);

    // 3. Sun Core (cx: 320, cy: 60, r: 26, color: #F2B134)
    final sunCorePaint = Paint()
      ..color = const Color(0xFFF2B134)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(const Offset(320, 60), 26, sunCorePaint);

    // 4. Hill 1: M0 190 Q97.5 146 195 184 T390 170 V250 H0 z (#2B6A3E)
    final hill1Paint = Paint()..color = const Color(0xFF2B6A3E);
    final hill1Path = Path();
    hill1Path.moveTo(0, 190);
    hill1Path.quadraticBezierTo(97.5, 146, 195.0, 184);
    hill1Path.quadraticBezierTo(292.5, 222, 390, 170);
    hill1Path.lineTo(390, 250);
    hill1Path.lineTo(0, 250);
    hill1Path.close();
    canvas.drawPath(hill1Path, hill1Paint);

    // 5. Hill 2: M0 226 Q117 184 234 218 T390 204 V250 H0 z (#3A8350)
    final hill2Paint = Paint()..color = const Color(0xFF3A8350);
    final hill2Path = Path();
    hill2Path.moveTo(0, 226);
    hill2Path.quadraticBezierTo(117.0, 184, 234.0, 218);
    hill2Path.quadraticBezierTo(351.0, 252, 390, 204);
    hill2Path.lineTo(390, 250);
    hill2Path.lineTo(0, 250);
    hill2Path.close();
    canvas.drawPath(hill2Path, hill2Paint);

    // 6. Furrow Lines: (#5DAA6E, stroke-width: 2)
    final furrowPaint = Paint()
      ..color = const Color(0xFF5DAA6E)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(const Offset(30, 250), const Offset(100, 200), furrowPaint);
    canvas.drawLine(const Offset(110, 250), const Offset(180, 202), furrowPaint);
    canvas.drawLine(const Offset(200, 250), const Offset(270, 204), furrowPaint);
    canvas.drawLine(const Offset(290, 250), const Offset(350, 206), furrowPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Custom painter for the Bhoomi leaf logo inside the squircle
class _BhoomiLeafPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 24.0;
    canvas.save();
    canvas.scale(scale, scale);

    // Leaf body: d="M5 19c0-8 5-13 14-14 0 9-5 14-13 14z" fill="#3A8350" stroke="#1E4D2B"
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

    // Center vein: d="M5 19c2-4 5-7 9-9" stroke="#F2B134" stroke-width="2.2"
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

