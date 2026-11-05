import 'package:flutter/material.dart';
import '../../main.dart';

class IntroAdviceScreen extends StatelessWidget {
  final VoidCallback? onNext;

  const IntroAdviceScreen({Key? key, this.onNext}) : super(key: key);

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
                  // 1. Top Illustration Section (440px high, warm gold background #FCEFD0)
                  Container(
                    width: 390,
                    height: 440,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFCEFD0),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(44),
                        bottomRight: Radius.circular(44),
                      ),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Stack(
                      children: [
                        const CustomPaint(
                          painter: _IntroAdviceIllustrationPainter(),
                          size: Size(390, 440),
                        ),

                        // Center White "Today's Advice" Card
                        Positioned(
                          left: 48,
                          right: 48,
                          top: 125,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(color: const Color(0xFFE6E0D2)),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x10000000),
                                  offset: Offset(0, 4),
                                  blurRadius: 10,
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.fromLTRB(20, 16, 16, 18),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Card Header: Title + Speaker Icon
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Expanded(
                                      child: Text(
                                        "Today's Advice",
                                        style: TextStyle(
                                          fontFamily: 'Mukta',
                                          fontSize: 20,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF1B2A21),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      width: 44,
                                      height: 44,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFF1E4D2B),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Center(
                                        child: Icon(
                                          Icons.volume_up_rounded,
                                          color: Colors.white,
                                          size: 22,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),

                                // Checklist Item 1: Check soil moisture
                                _buildCheckItem('Check soil moisture'),
                                const SizedBox(height: 10),

                                // Checklist Item 2: Remove weeds
                                _buildCheckItem('Remove weeds'),
                                const SizedBox(height: 10),

                                // Checklist Item 3: Inspect the leaves
                                _buildCheckItem('Inspect the leaves'),
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
                            'Advice for your farm,\nin your language',
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
                            'Daily weather and crop tips. Listen to them in Hindi anytime.',
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
                              // 3 Pagination Pills (Step 2 Active)
                              Row(
                                children: [
                                  // Inactive Dot 1
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFCFC8B5),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  // Active Pill (Step 2)
                                  Container(
                                    width: 26,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF1E4D2B),
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

  Widget _buildCheckItem(String title) {
    return Row(
      children: [
        Container(
          width: 22,
          height: 22,
          decoration: const BoxDecoration(
            color: Color(0xFFDDEFD9),
            shape: BoxShape.circle,
          ),
          child: const Center(
            child: Icon(
              Icons.check_rounded,
              color: Color(0xFF2E9B4F),
              size: 14,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontFamily: 'Mukta',
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1B2A21),
            ),
          ),
        ),
      ],
    );
  }
}

/// Custom painter for Sun, Cloud, and Bottom Plants in Advice Screen
class _IntroAdviceIllustrationPainter extends CustomPainter {
  const _IntroAdviceIllustrationPainter();

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Top-Left Golden Sun (cx: 60, cy: 70, outer r: 54, inner r: 32)
    final sunHalo = Paint()
      ..color = const Color(0xFFF2B134).withOpacity(0.25)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(const Offset(60, 70), 54, sunHalo);

    final sunCore = Paint()
      ..color = const Color(0xFFF2B134)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(const Offset(60, 70), 32, sunCore);

    // 2. Top-Right White Cloud (path d="M250 92h70a18 18 0 0 0 0-36 26 26 0 0 0-50-5 20 20 0 0 0-20 41z")
    final cloudPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    final cloudPath = Path()
      ..moveTo(250, 92)
      ..lineTo(320, 92)
      ..arcToPoint(const Offset(320, 56), radius: const Radius.circular(18), clockwise: false)
      ..arcToPoint(const Offset(270, 51), radius: const Radius.circular(26), clockwise: false)
      ..arcToPoint(const Offset(250, 92), radius: const Radius.circular(20), clockwise: false)
      ..close();
    canvas.drawPath(cloudPath, cloudPaint);

    // 3. Bottom Plant Stems at Base
    void drawPlant(Offset pos) {
      canvas.save();
      canvas.translate(pos.dx, pos.dy);

      // Stem (d="M60 440V396")
      final stemPaint = Paint()
        ..color = const Color(0xFF2B6A3E)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.0
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(const Offset(60, 440), const Offset(60, 396), stemPaint);

      // Leaves: Left leaf (d="M60 410c-14 0-20-8-20-18 12 0 20 6 20 18z")
      final leftLeaf = Path()
        ..moveTo(60, 410)
        ..cubicTo(46, 410, 40, 402, 40, 392)
        ..cubicTo(52, 392, 60, 398, 60, 410)
        ..close();

      // Right leaf (d="M60 402c0-10 8-16 20-16 0 12-8 16-20 16z")
      final rightLeaf = Path()
        ..moveTo(60, 402)
        ..cubicTo(60, 392, 68, 386, 80, 386)
        ..cubicTo(80, 398, 72, 402, 60, 402)
        ..close();

      final leafFill = Paint()
        ..color = const Color(0xFF3A8350)
        ..style = PaintingStyle.fill;
      final leafStroke = Paint()
        ..color = const Color(0xFF1E4D2B)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;

      canvas.drawPath(leftLeaf, leafFill);
      canvas.drawPath(leftLeaf, leafStroke);

      canvas.drawPath(rightLeaf, leafFill);
      canvas.drawPath(rightLeaf, leafStroke);

      canvas.restore();
    }

    drawPlant(Offset.zero);
    drawPlant(const Offset(210, 0)); // translates x from 60 to 270 (330)
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

