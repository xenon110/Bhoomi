import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'intro/onboarding_flow_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _spinController;
  Timer? _timer;
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();
    _spinController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 7),
    )..repeat();

    _timer = Timer(const Duration(milliseconds: 2800), _navigateToHome);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _spinController.dispose();
    super.dispose();
  }

  void _navigateToHome() {
    if (_hasNavigated || !mounted) return;
    _hasNavigated = true;
    _timer?.cancel();

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const OnboardingFlowScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 550),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E4D2B),
      body: GestureDetector(
        onTap: _navigateToHome,
        behavior: HitTestBehavior.opaque,
        child: SizedBox.expand(
          child: FittedBox(
            fit: BoxFit.contain,
            alignment: Alignment.center,
            child: SizedBox(
              width: 390,
              height: 844,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // 1. Full Scenic SVG Background
                  const CustomPaint(
                    painter: _SplashBackgroundPainter(),
                    size: Size(390, 844),
                  ),

                  // 2. Central Branding: "Bh" + [Wheel] + [Wheel] + "mi"
                  Positioned(
                    left: 0,
                    right: 0,
                    top: 268,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Wordmark
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            const Text(
                              'Bh',
                              style: TextStyle(
                                fontFamily: 'Mukta',
                                fontSize: 72,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                height: 1.0,
                                letterSpacing: -1.0,
                              ),
                            ),
                            const SizedBox(width: 2),
                            // First Spinning Wheel (o)
                            AnimatedBuilder(
                              animation: _spinController,
                              builder: (context, child) {
                                return Transform.rotate(
                                  angle: _spinController.value * 2 * math.pi,
                                  child: child,
                                );
                              },
                              child: const CustomPaint(
                                size: Size(42, 42),
                                painter: _BhoomiWheelPainter(),
                              ),
                            ),
                            const SizedBox(width: 3),
                            // Second Spinning Wheel (o)
                            AnimatedBuilder(
                              animation: _spinController,
                              builder: (context, child) {
                                return Transform.rotate(
                                  angle: _spinController.value * 2 * math.pi,
                                  child: child,
                                );
                              },
                              child: const CustomPaint(
                                size: Size(42, 42),
                                painter: _BhoomiWheelPainter(),
                              ),
                            ),
                            const SizedBox(width: 2),
                            const Text(
                              'mi',
                              style: TextStyle(
                                fontFamily: 'Mukta',
                                fontSize: 72,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                height: 1.0,
                                letterSpacing: -1.0,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Subtitle: — Your farming companion —
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 28,
                              height: 3,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF2B134),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            const SizedBox(width: 10),
                            const Text(
                              'Your farming companion',
                              style: TextStyle(
                                fontFamily: 'Mukta',
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                                letterSpacing: 0.2,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Container(
                              width: 28,
                              height: 3,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF2B134),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // 3. Bottom Pagination Dots
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 44,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: const BoxDecoration(
                            color: Color(0xFFF2B134),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.7),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.4),
                            shape: BoxShape.circle,
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
    );
  }
}

/// Custom painter for the animated spinning 'o' tractor wheel
class _BhoomiWheelPainter extends CustomPainter {
  const _BhoomiWheelPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final scale = size.width / 100.0;

    // 1. Outer Cream Rim
    final creamPaint = Paint()
      ..color = const Color(0xFFF6F2E9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14 * scale;
    canvas.drawCircle(center, 40 * scale, creamPaint);

    // 2. Dark Green Dashed Tread Outer Ring
    final treadPaint = Paint()
      ..color = const Color(0xFF1E4D2B)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6 * scale;

    const numDashes = 16;
    const sweep = (2 * math.pi) / numDashes;
    for (int i = 0; i < numDashes; i++) {
      final startAngle = i * sweep;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: 47 * scale),
        startAngle,
        sweep * 0.45,
        false,
        treadPaint,
      );
    }

    // 3. Six Golden Spokes
    final spokePaint = Paint()
      ..color = const Color(0xFFF2B134)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5 * scale
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < 6; i++) {
      final angle = i * (math.pi / 3);
      final p2 = Offset(
        center.dx + 32 * scale * math.sin(angle),
        center.dy - 32 * scale * math.cos(angle),
      );
      canvas.drawLine(center, p2, spokePaint);
    }

    // 4. Center Gold Hub
    final hubPaint = Paint()
      ..color = const Color(0xFFF2B134)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 11 * scale, hubPaint);

    // 5. Center Pin
    final pinPaint = Paint()
      ..color = const Color(0xFF1E4D2B)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 4 * scale, pinPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Custom painter for the complete SVG agricultural landscape
class _SplashBackgroundPainter extends CustomPainter {
  const _SplashBackgroundPainter();

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Sun Glow & Core Sun (top right: 318, 150)
    final sunGlow = Paint()
      ..color = const Color(0xFFF2B134).withOpacity(0.18)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(const Offset(318, 150), 92, sunGlow);

    final sunCore = Paint()
      ..color = const Color(0xFFF2B134)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(const Offset(318, 150), 52, sunCore);

    // 2. Soft Cloud (M40 118 h54 a14 14 ...)
    final cloudPaint = Paint()
      ..color = Colors.white.withOpacity(0.14)
      ..style = PaintingStyle.fill;
    final cloudPath = Path()
      ..moveTo(40, 118)
      ..lineTo(94, 118)
      ..arcToPoint(const Offset(94, 90), radius: const Radius.circular(14), clockwise: false)
      ..arcToPoint(const Offset(56, 86), radius: const Radius.circular(20), clockwise: false)
      ..arcToPoint(const Offset(40, 118), radius: const Radius.circular(16), clockwise: false)
      ..close();
    canvas.drawPath(cloudPath, cloudPaint);

    // 3. Flying Birds
    final birdPaint = Paint()
      ..color = Colors.white.withOpacity(0.55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final bird1 = Path()
      ..moveTo(150, 214)
      ..quadraticBezierTo(157, 205, 164, 214)
      ..quadraticBezierTo(171, 205, 178, 214);
    canvas.drawPath(bird1, birdPaint);

    final bird2 = Path()
      ..moveTo(196, 190)
      ..quadraticBezierTo(201, 183, 206, 190)
      ..quadraticBezierTo(211, 183, 216, 190);
    canvas.drawPath(bird2, birdPaint);

    // 4. Distant Green Hill (0, 640 to 390, 844)
    final distHillPaint = Paint()
      ..color = const Color(0xFF2B6A3E)
      ..style = PaintingStyle.fill;
    final distHill = Path()
      ..moveTo(0, 640)
      ..quadraticBezierTo(97.5, 596, 195, 634)
      ..quadraticBezierTo(292.5, 672, 390, 620)
      ..lineTo(390, 844)
      ..lineTo(0, 844)
      ..close();
    canvas.drawPath(distHill, distHillPaint);

    // 5. Detailed Yellow Tractor (at translate(34, 532))
    canvas.save();
    canvas.translate(34, 532);

    // Smoke Puffs
    canvas.drawCircle(
      const Offset(-6, 82),
      5,
      Paint()..color = Colors.white.withOpacity(0.18),
    );
    canvas.drawCircle(
      const Offset(-18, 84),
      3.5,
      Paint()..color = Colors.white.withOpacity(0.12),
    );

    // Exhaust Pipe
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(96, 22, 6, 26), const Radius.circular(2)),
      Paint()..color = const Color(0xFF14291C),
    );

    // Engine Hood
    final hoodPath = Path()
      ..moveTo(52, 42)
      ..lineTo(104, 42)
      ..arcToPoint(const Offset(112, 50), radius: const Radius.circular(8))
      ..lineTo(112, 66)
      ..lineTo(52, 66)
      ..close();
    canvas.drawPath(
      hoodPath,
      Paint()..color = const Color(0xFFF2B134),
    );
    canvas.drawPath(
      hoodPath,
      Paint()
        ..color = const Color(0xFFC98F1C)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6,
    );

    // Cabin
    final cabPath = Path()
      ..moveTo(14, 10)
      ..lineTo(54, 10)
      ..lineTo(54, 48)
      ..lineTo(14, 48)
      ..close();
    canvas.drawPath(
      cabPath,
      Paint()..color = const Color(0xFFF2B134),
    );
    canvas.drawPath(
      cabPath,
      Paint()
        ..color = const Color(0xFFC98F1C)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6,
    );

    // Roof
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(10, 6, 48, 6), const Radius.circular(3)),
      Paint()..color = const Color(0xFF14291C),
    );

    // Window
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(20, 16, 26, 20), const Radius.circular(3)),
      Paint()..color = const Color(0xFFDDEBF3),
    );

    // Big Rear Wheel (cx: 32, cy: 60, r: 28)
    final rearTire = Paint()..color = const Color(0xFF14291C);
    canvas.drawCircle(const Offset(32, 60), 28, rearTire);

    // 14 Treads on Rear Wheel
    const rearTreads = 14;
    for (int i = 0; i < rearTreads; i++) {
      final angle = i * (2 * math.pi / rearTreads);
      canvas.save();
      canvas.translate(32, 60);
      canvas.rotate(angle);
      canvas.drawRRect(
        RRect.fromRectAndRadius(const Rect.fromLTWH(-2, -31, 4, 6), const Radius.circular(1)),
        rearTire,
      );
      canvas.restore();
    }
    // Rear Rim
    canvas.drawCircle(const Offset(32, 60), 16, Paint()..color = const Color(0xFF3A8350));
    // Rear Hub
    canvas.drawCircle(const Offset(32, 60), 6, Paint()..color = const Color(0xFFF2B134));

    // Front Wheel (cx: 104, cy: 72, r: 16)
    final frontTire = Paint()..color = const Color(0xFF14291C);
    canvas.drawCircle(const Offset(104, 72), 16, frontTire);

    // 10 Treads on Front Wheel
    const frontTreads = 10;
    for (int i = 0; i < frontTreads; i++) {
      final angle = i * (2 * math.pi / frontTreads);
      canvas.save();
      canvas.translate(104, 72);
      canvas.rotate(angle);
      canvas.drawRRect(
        RRect.fromRectAndRadius(const Rect.fromLTWH(-2, -19, 4, 6), const Radius.circular(1)),
        frontTire,
      );
      canvas.restore();
    }
    // Front Rim
    canvas.drawCircle(const Offset(104, 72), 8, Paint()..color = const Color(0xFF3A8350));
    // Front Hub
    canvas.drawCircle(const Offset(104, 72), 3, Paint()..color = const Color(0xFFF2B134));

    canvas.restore();

    // 6. Foreground Rolling Hill (0, 676 to 390, 844)
    final foreHillPaint = Paint()
      ..color = const Color(0xFF3A8350)
      ..style = PaintingStyle.fill;
    final foreHill = Path()
      ..moveTo(0, 676)
      ..quadraticBezierTo(117, 634, 234, 668)
      ..quadraticBezierTo(312, 685, 390, 654)
      ..lineTo(390, 844)
      ..lineTo(0, 844)
      ..close();
    canvas.drawPath(foreHill, foreHillPaint);

    // 7. Field Furrow Perspective Lines
    final furrowPaint = Paint()
      ..color = const Color(0xFF5DAA6E)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(const Offset(10, 844), const Offset(110, 700), furrowPaint);
    canvas.drawLine(const Offset(80, 844), const Offset(180, 704), furrowPaint);
    canvas.drawLine(const Offset(160, 844), const Offset(250, 708), furrowPaint);
    canvas.drawLine(const Offset(240, 844), const Offset(320, 712), furrowPaint);
    canvas.drawLine(const Offset(320, 844), const Offset(390, 726), furrowPaint);

    // 8. Sprouting Crop Plants
    void drawSprout(Offset pos) {
      canvas.save();
      canvas.translate(pos.dx, pos.dy);

      final stemPaint = Paint()
        ..color = const Color(0xFF9AD3A4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.4
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(Offset.zero, const Offset(0, -12), stemPaint);

      final leafPaint = Paint()
        ..color = const Color(0xFF5DAA6E)
        ..style = PaintingStyle.fill;

      final leftLeaf = Path()
        ..moveTo(0, -6)
        ..cubicTo(-6, -6, -8, -10, -8, -14)
        ..cubicTo(-3, -14, 0, -11, 0, -6)
        ..close();
      canvas.drawPath(leftLeaf, leafPaint);

      final rightLeaf = Path()
        ..moveTo(0, -8)
        ..cubicTo(0, -12, 3, -15, 8, -15)
        ..cubicTo(8, -11, 5, -8, 0, -8)
        ..close();
      canvas.drawPath(rightLeaf, leafPaint);

      canvas.restore();
    }

    drawSprout(const Offset(60, 738));
    drawSprout(const Offset(150, 770));
    drawSprout(const Offset(236, 742));
    drawSprout(const Offset(312, 776));
    drawSprout(const Offset(30, 800));
    drawSprout(const Offset(204, 810));
    drawSprout(const Offset(350, 744));

    // 9. Golden Wheat Stalks
    void drawWheat(Offset pos, double degrees) {
      canvas.save();
      canvas.translate(pos.dx, pos.dy);
      canvas.rotate(degrees * math.pi / 180);

      final stemPaint = Paint()
        ..color = const Color(0xFFF2B134)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.6
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(Offset.zero, const Offset(0, -70), stemPaint);

      final grainPaint = Paint()
        ..color = const Color(0xFFF2B134)
        ..style = PaintingStyle.fill;

      void drawGrain(double x, double y, double rot) {
        canvas.save();
        canvas.translate(x, y);
        canvas.rotate(rot * math.pi / 180);
        canvas.drawOval(
          Rect.fromCenter(center: Offset.zero, width: 8, height: 18),
          grainPaint,
        );
        canvas.restore();
      }

      drawGrain(-6, -62, -30);
      drawGrain(6, -62, 30);
      drawGrain(-6, -48, -30);
      drawGrain(6, -48, 30);
      drawGrain(-6, -34, -30);
      drawGrain(6, -34, 30);
      drawGrain(0, -76, 0);

      canvas.restore();
    }

    drawWheat(const Offset(352, 790), 6);
    drawWheat(const Offset(370, 800), -4);
    drawWheat(const Offset(334, 800), -10);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

