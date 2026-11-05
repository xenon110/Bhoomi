import 'package:flutter/material.dart';
import '../../main.dart';
import '../../theme/app_theme.dart';

class IntroScanScreen extends StatelessWidget {
  final VoidCallback? onNext;

  const IntroScanScreen({Key? key, this.onNext}) : super(key: key);

  void _handleNext(BuildContext context) {
    if (onNext != null) {
      onNext!();
    } else {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const MainNavigation(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 400),
        ),
      );
    }
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
              child: Column(
                children: [
                  // 1. Top Illustration Section (440px high with rounded bottom)
                  Container(
                    width: 390,
                    height: 440,
                    decoration: const BoxDecoration(
                      color: Color(0xFFDCEBD7),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(44),
                        bottomRight: Radius.circular(44),
                      ),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Stack(
                      children: [
                        const CustomPaint(
                          painter: _IntroScanIllustrationPainter(),
                          size: Size(390, 440),
                        ),

                        // Left Floating Badge: "Leaf spot found"
                        Positioned(
                          left: 20,
                          top: 132,
                          child: Container(
                            height: 42,
                            constraints: const BoxConstraints(maxWidth: 160),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(21),
                              border: Border.all(color: const Color(0xFFE6E0D2)),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x15000000),
                                  offset: Offset(0, 2),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 14,
                                  height: 14,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFF2B134),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                const Flexible(
                                  child: Text(
                                    'Leaf spot found',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontFamily: 'Mukta',
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF1B2A21),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Right Floating Badge: "Tap to listen"
                        Positioned(
                          right: 20,
                          top: 250,
                          child: Container(
                            height: 42,
                            constraints: const BoxConstraints(maxWidth: 160),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E4D2B),
                              borderRadius: BorderRadius.circular(21),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x20000000),
                                  offset: Offset(0, 3),
                                  blurRadius: 6,
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Icon(Icons.volume_up_rounded, size: 18, color: Colors.white),
                                SizedBox(width: 6),
                                Flexible(
                                  child: Text(
                                    'Tap to listen',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontFamily: 'Mukta',
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
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

                  // 2. Bottom Content Section
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 26, 24, 28),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Headline
                          const Text(
                            'Scan your crop,\nfind the problem',
                            style: TextStyle(
                              fontFamily: 'Mukta',
                              fontSize: 30,
                              fontWeight: FontWeight.w700,
                              height: 1.1,
                              color: Color(0xFF1B2A21),
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 10),

                          // Description
                          const Text(
                            'Take a photo of a leaf. Get simple answers and what to do next.',
                            style: TextStyle(
                              fontFamily: 'Mukta',
                              fontSize: 16.5,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF55655A),
                              height: 1.35,
                            ),
                          ),

                          const Spacer(),

                          // Bottom Row: [Pill Indicators] and [Next Button]
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // 3 Pagination Pills
                              Row(
                                children: [
                                  // Active Pill (Step 1)
                                  Container(
                                    width: 26,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF1E4D2B),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  // Inactive Dot 2
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFCFC8B5),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  // Inactive Dot 3
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFCFC8B5),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                ],
                              ),

                              // "Next →" Button
                              GestureDetector(
                                onTap: () => _handleNext(context),
                                child: Container(
                                  height: 56,
                                  constraints: const BoxConstraints(minWidth: 150),
                                  padding: const EdgeInsets.symmetric(horizontal: 22),
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
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: const [
                                      Text(
                                        'Next',
                                        style: TextStyle(
                                          fontFamily: 'Mukta',
                                          fontSize: 17,
                                          fontWeight: FontWeight.w700,
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
                            ],
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
    );
  }
}

/// Custom painter for the complete SVG crop scanner phone illustration
class _IntroScanIllustrationPainter extends CustomPainter {
  const _IntroScanIllustrationPainter();

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Soft White Ambient Circle in background (cx: 195, cy: 215, r: 150)
    final circlePaint = Paint()
      ..color = Colors.white.withOpacity(0.55)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(const Offset(195, 215), 150, circlePaint);

    // 2. Phone Outer Frame (x: 125, y: 62, w: 140, h: 290, rx: 28)
    final phoneFramePaint = Paint()
      ..color = const Color(0xFF1B2A21)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(125, 62, 140, 290),
        const Radius.circular(28),
      ),
      phoneFramePaint,
    );

    // 3. Phone Inner Screen Viewport (x: 135, y: 76, w: 120, h: 262, rx: 20)
    final phoneScreenPaint = Paint()
      ..color = const Color(0xFFCFE5CA)
      ..style = PaintingStyle.fill;
    final screenRRect = RRect.fromRectAndRadius(
      const Rect.fromLTWH(135, 76, 120, 262),
      const Radius.circular(20),
    );
    canvas.drawRRect(screenRRect, phoneScreenPaint);

    // Clip elements inside the phone screen
    canvas.save();
    canvas.clipRRect(screenRRect);

    // 4. Scanned Leaf (d="M160 300c6-50 36-84 82-88 2 50-26 84-74 92z")
    final leafPath = Path()
      ..moveTo(160, 300)
      ..cubicTo(166, 250, 196, 216, 242, 212)
      ..cubicTo(244, 262, 216, 296, 168, 304)
      ..close();

    final leafFill = Paint()
      ..color = const Color(0xFF3A8350)
      ..style = PaintingStyle.fill;
    canvas.drawPath(leafPath, leafFill);

    final leafStroke = Paint()
      ..color = const Color(0xFF1E4D2B)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawPath(leafPath, leafStroke);

    // 5. Leaf Vein (d="M168 292c28-16 52-38 72-72")
    final veinPaint = Paint()
      ..color = const Color(0xFF7DB88A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round;
    final veinPath = Path()
      ..moveTo(168, 292)
      ..cubicTo(196, 276, 220, 254, 240, 220);
    canvas.drawPath(veinPath, veinPaint);

    // 6. Yellow Pest / Disease Spots on Leaf
    final spotFill = Paint()
      ..color = const Color(0xFFF2B134)
      ..style = PaintingStyle.fill;
    final spotStroke = Paint()
      ..color = const Color(0xFF8A5600)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;

    canvas.drawCircle(const Offset(196, 262), 6, spotFill);
    canvas.drawCircle(const Offset(196, 262), 6, spotStroke);

    canvas.drawCircle(const Offset(218, 242), 5, spotFill);
    canvas.drawCircle(const Offset(218, 242), 5, spotStroke);

    canvas.drawCircle(const Offset(188, 238), 4, spotFill);
    canvas.drawCircle(const Offset(188, 238), 4, spotStroke);

    // 7. Yellow Viewfinder Brackets
    // (Corners: Top-Left, Top-Right, Bottom-Right, Bottom-Left)
    final bracketPaint = Paint()
      ..color = const Color(0xFFF2B134)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.4
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Top-Left: M150 112v-14a4 4 0 0 1 4-4h14
    final tl = Path()
      ..moveTo(150, 112)
      ..lineTo(150, 98)
      ..arcToPoint(const Offset(154, 94), radius: const Radius.circular(4))
      ..lineTo(168, 94);
    canvas.drawPath(tl, bracketPaint);

    // Top-Right: M222 94h14a4 4 0 0 1 4 4v14
    final tr = Path()
      ..moveTo(222, 94)
      ..lineTo(236, 94)
      ..arcToPoint(const Offset(240, 98), radius: const Radius.circular(4))
      ..lineTo(240, 112);
    canvas.drawPath(tr, bracketPaint);

    // Bottom-Right: M240 176v14a4 4 0 0 1-4 4h-14
    final br = Path()
      ..moveTo(240, 176)
      ..lineTo(240, 190)
      ..arcToPoint(const Offset(236, 194), radius: const Radius.circular(4))
      ..lineTo(222, 194);
    canvas.drawPath(br, bracketPaint);

    // Bottom-Left: M168 194h-14a4 4 0 0 1-4-4v-14
    final bl = Path()
      ..moveTo(168, 194)
      ..lineTo(154, 194)
      ..arcToPoint(const Offset(150, 190), radius: const Radius.circular(4))
      ..lineTo(150, 176);
    canvas.drawPath(bl, bracketPaint);

    canvas.restore(); // Restore clip

    // 8. Bottom Grass Blades (d="M30 440l6-50 M48 440l-2-40 M360 440l-6-54 M342 440l4-40")
    final grassPaint = Paint()
      ..color = const Color(0xFF2B6A3E)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(const Offset(30, 440), const Offset(36, 390), grassPaint);
    canvas.drawLine(const Offset(48, 440), const Offset(46, 400), grassPaint);
    canvas.drawLine(const Offset(360, 440), const Offset(354, 386), grassPaint);
    canvas.drawLine(const Offset(342, 440), const Offset(346, 400), grassPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

