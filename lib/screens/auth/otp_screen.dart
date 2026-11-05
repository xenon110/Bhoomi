import 'dart:async';
import 'package:flutter/material.dart';
import '../../main.dart';
import '../../services/storage_service.dart';
import 'signup_screen.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String phoneNumber;
  final bool isLoginOnly;

  const OtpVerificationScreen({
    Key? key,
    required this.phoneNumber,
    this.isLoginOnly = false,
  }) : super(key: key);

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  // Prepopulate initial demo value '481' to closely match the HTML screenshot design
  String _otp = '481';
  int _secondsRemaining = 30;
  Timer? _countdownTimer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _countdownTimer?.cancel();
    setState(() {
      _secondsRemaining = 30;
    });
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() {
          _secondsRemaining--;
        });
      } else {
        timer.cancel();
      }
    });
  }

  void _onKeyPress(String val) {
    if (_otp.length < 4) {
      setState(() {
        _otp += val;
      });
      if (_otp.length == 4) {
        // Auto-verify on 4th digit
        Future.delayed(const Duration(milliseconds: 200), _onVerify);
      }
    }
  }

  void _onDelete() {
    if (_otp.isNotEmpty) {
      setState(() {
        _otp = _otp.substring(0, _otp.length - 1);
      });
    }
  }

  void _onVerify() {
    if (_otp.length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please enter the 4-digit verification code',
            style: TextStyle(fontFamily: 'Mukta', fontWeight: FontWeight.w600),
          ),
          backgroundColor: Color(0xFF1E4D2B),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    // If already has profile filled and is login only, go directly to MainNavigation
    final profile = StorageService().getProfile();
    final hasValidProfile = profile.name.trim().isNotEmpty && profile.village.trim().isNotEmpty;

    if (widget.isLoginOnly && hasValidProfile) {
      Navigator.of(context).pushAndRemoveUntil(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const MainNavigation(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 400),
        ),
        (route) => false,
      );
    } else {
      // Step 2 of 2: Profile setup
      Navigator.of(context).push(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              SignupProfileScreen(phoneNumber: widget.phoneNumber),
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
  }

  String _formatPhoneMasked(String raw) {
    if (raw.length >= 10) {
      final start = raw.substring(0, 2);
      final end = raw.substring(raw.length - 3);
      return '+91 ${start}XXX XX$end';
    }
    return '+91 98XXX XX210';
  }

  @override
  Widget build(BuildContext context) {
    final activeIndex = _otp.length < 4 ? _otp.length : 3;

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
                    // Top Bar with Back Button
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.of(context).pop(),
                            child: Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(22),
                                border: Border.all(color: const Color(0xFFDDD6C4), width: 1),
                              ),
                              alignment: Alignment.center,
                              child: const Icon(
                                Icons.chevron_left_rounded,
                                color: Color(0xFF1B2A21),
                                size: 24,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Main Body Content
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 1. Phone / Device Icon Squircle (64x64, #FCEFD0)
                            Container(
                              width: 64,
                              height: 64,
                              decoration: BoxDecoration(
                                color: const Color(0xFFFCEFD0),
                                borderRadius: BorderRadius.circular(22),
                              ),
                              alignment: Alignment.center,
                              child: CustomPaint(
                                size: const Size(34, 34),
                                painter: _PhoneDevicePainter(),
                              ),
                            ),
                            const SizedBox(height: 14),

                            // 2. Title & Masked Phone Subtitle
                            const Text(
                              'Enter the code',
                              style: TextStyle(
                                fontFamily: 'Mukta',
                                fontSize: 30,
                                fontWeight: FontWeight.w800,
                                height: 1.1,
                                color: Color(0xFF1B2A21),
                              ),
                            ),
                            const SizedBox(height: 6),

                            RichText(
                              text: TextSpan(
                                style: const TextStyle(
                                  fontFamily: 'Mukta',
                                  fontSize: 15.5,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF55655A),
                                ),
                                children: [
                                  const TextSpan(text: 'We sent a 4-digit code to '),
                                  TextSpan(
                                    text: _formatPhoneMasked(widget.phoneNumber),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF1B2A21),
                                    ),
                                  ),
                                  const TextSpan(text: '  '),
                                  WidgetSpan(
                                    alignment: PlaceholderAlignment.middle,
                                    child: GestureDetector(
                                      onTap: () => Navigator.of(context).pop(),
                                      child: const Text(
                                        'Change',
                                        style: TextStyle(
                                          fontFamily: 'Mukta',
                                          fontSize: 15,
                                          fontWeight: FontWeight.w800,
                                          color: Color(0xFF1E4D2B),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 24),

                            // 3. 4-digit OTP Boxes
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(4, (index) {
                                final digit = index < _otp.length ? _otp[index] : '';
                                final isCurrent = index == activeIndex;

                                return Container(
                                  width: 64,
                                  height: 72,
                                  margin: const EdgeInsets.symmetric(horizontal: 5),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: isCurrent
                                          ? const Color(0xFF1E4D2B)
                                          : const Color(0xFFDDD6C4),
                                      width: isCurrent ? 2.5 : 1.5,
                                    ),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    digit,
                                    style: const TextStyle(
                                      fontFamily: 'Mukta',
                                      fontSize: 32,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF1B2A21),
                                    ),
                                  ),
                                );
                              }),
                            ),

                            const SizedBox(height: 16),

                            // 4. Resend code timer
                            Center(
                              child: _secondsRemaining > 0
                                  ? RichText(
                                      text: TextSpan(
                                        style: const TextStyle(
                                          fontFamily: 'Mukta',
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF55655A),
                                        ),
                                        children: [
                                          const TextSpan(text: 'Resend code in '),
                                          TextSpan(
                                            text: '0:${_secondsRemaining.toString().padLeft(2, '0')}',
                                            style: const TextStyle(
                                              color: Color(0xFF1E4D2B),
                                              fontWeight: FontWeight.w800,
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  : GestureDetector(
                                      onTap: _startTimer,
                                      child: const Text(
                                        'Resend code now',
                                        style: TextStyle(
                                          fontFamily: 'Mukta',
                                          fontSize: 15,
                                          fontWeight: FontWeight.w800,
                                          color: Color(0xFF1E4D2B),
                                        ),
                                      ),
                                    ),
                            ),

                            const SizedBox(height: 16),

                            // 5. Verify Button
                            GestureDetector(
                              onTap: _onVerify,
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
                                      'Verify',
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

                            const Spacer(),

                            // 6. On-screen Custom Numeric Keypad (3x4 Grid)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 20),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      _buildKey('1'),
                                      const SizedBox(width: 8),
                                      _buildKey('2'),
                                      const SizedBox(width: 8),
                                      _buildKey('3'),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      _buildKey('4'),
                                      const SizedBox(width: 8),
                                      _buildKey('5'),
                                      const SizedBox(width: 8),
                                      _buildKey('6'),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      _buildKey('7'),
                                      const SizedBox(width: 8),
                                      _buildKey('8'),
                                      const SizedBox(width: 8),
                                      _buildKey('9'),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      // Empty spacer
                                      const Expanded(child: SizedBox(height: 52)),
                                      const SizedBox(width: 8),
                                      _buildKey('0'),
                                      const SizedBox(width: 8),
                                      // Backspace key
                                      Expanded(
                                        child: GestureDetector(
                                          onTap: _onDelete,
                                          child: Container(
                                            height: 52,
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFE9E2D1),
                                              borderRadius: BorderRadius.circular(16),
                                            ),
                                            alignment: Alignment.center,
                                            child: CustomPaint(
                                              size: const Size(26, 26),
                                              painter: _DeleteKeyPainter(),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
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
          ),
        ),
      ),
    );
  }

  Widget _buildKey(String label) {
    return Expanded(
      child: GestureDetector(
        onTap: () => _onKeyPress(label),
        child: Container(
          height: 52,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE6E0D2), width: 1),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: const TextStyle(
              fontFamily: 'Mukta',
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1B2A21),
            ),
          ),
        ),
      ),
    );
  }
}

/// Custom painter for Phone / Device icon in squircle (rect x=7 y=2 w=10 h=20 rx=3)
class _PhoneDevicePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 24.0;
    canvas.save();
    canvas.scale(scale, scale);

    final paint = Paint()
      ..color = const Color(0xFF7A4D00)
      ..strokeWidth = 1.9
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Phone body: rect x=7, y=2, w=10, h=20, rx=3
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(7, 2, 10, 20), const Radius.circular(3)),
      paint,
    );

    // Earpiece line: M10 6h4
    canvas.drawLine(const Offset(10, 6), const Offset(14, 6), paint);

    // Bottom home button/bar: M11 18h2
    canvas.drawLine(const Offset(11, 18), const Offset(13, 18), paint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Custom painter for the backspace delete key: M21 5H9l-6 7 6 7h12z M12 9l6 6 M18 9l-6 6
class _DeleteKeyPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 24.0;
    canvas.save();
    canvas.scale(scale, scale);

    final paint = Paint()
      ..color = const Color(0xFF1B2A21)
      ..strokeWidth = 1.9
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Delete tag outline: M21 5H9l-6 7 6 7h12z
    final path = Path();
    path.moveTo(21, 5);
    path.lineTo(9, 5);
    path.lineTo(3, 12);
    path.lineTo(9, 19);
    path.lineTo(21, 19);
    path.close();
    canvas.drawPath(path, paint);

    // Cross lines: M12 9l6 6
    canvas.drawLine(const Offset(12, 9), const Offset(18, 15), paint);
    // M18 9l-6 6
    canvas.drawLine(const Offset(18, 9), const Offset(12, 15), paint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

