import 'package:flutter/material.dart';
import '../auth/language_selection_screen.dart';

class IntroPriceScreen extends StatelessWidget {
  final VoidCallback? onNext;

  const IntroPriceScreen({Key? key, this.onNext}) : super(key: key);

  void _handleNext(BuildContext context) {
    if (onNext != null) {
      onNext!();
    } else {
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
                  // 1. Top Illustration Section (440px high, warm terracotta #F6E0D6)
                  Container(
                    width: 390,
                    height: 440,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF6E0D6),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(44),
                        bottomRight: Radius.circular(44),
                      ),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Stack(
                      children: [
                        const CustomPaint(
                          painter: _IntroPriceIllustrationPainter(),
                          size: Size(390, 440),
                        ),

                        // Badge 1: ₹5800
                        Positioned(
                          left: 36,
                          top: 356,
                          child: Container(
                            constraints: const BoxConstraints(minWidth: 86),
                            height: 38,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(19),
                              border: Border.all(color: const Color(0xFFE6E0D2)),
                            ),
                            alignment: Alignment.center,
                            child: const Text(
                              '₹5800',
                              style: TextStyle(
                                fontFamily: 'Mukta',
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1B2A21),
                              ),
                            ),
                          ),
                        ),

                        // Badge 2: ₹6000
                        Positioned(
                          left: 148,
                          top: 376,
                          child: Container(
                            constraints: const BoxConstraints(minWidth: 86),
                            height: 38,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(19),
                              border: Border.all(color: const Color(0xFFE6E0D2)),
                            ),
                            alignment: Alignment.center,
                            child: const Text(
                              '₹6000',
                              style: TextStyle(
                                fontFamily: 'Mukta',
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1B2A21),
                              ),
                            ),
                          ),
                        ),

                        // Badge 3 (Best Price Selected): ₹6200
                        Positioned(
                          left: 260,
                          top: 356,
                          child: Container(
                            constraints: const BoxConstraints(minWidth: 86),
                            height: 38,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E4D2B),
                              borderRadius: BorderRadius.circular(19),
                              border: Border.all(color: const Color(0xFFE6E0D2)),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x25000000),
                                  offset: Offset(0, 3),
                                  blurRadius: 6,
                                ),
                              ],
                            ),
                            alignment: Alignment.center,
                            child: const Text(
                              '₹6200',
                              style: TextStyle(
                                fontFamily: 'Mukta',
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
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
                            'Know the price\nbefore you sell',
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
                            'Compare nearby mandi prices and choose the best place to sell.',
                            style: TextStyle(
                              fontFamily: 'Mukta',
                              fontSize: 16.5,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF55655A),
                              height: 1.35,
                            ),
                          ),

                          const Spacer(),

                          // Bottom Row: [Pill Indicators] and [Get started Button]
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // 3 Pagination Pills (Step 3 Active)
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
                                  // Active Pill (Step 3)
                                  Container(
                                    width: 26,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF1E4D2B),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                ],
                              ),

                              // "Get started →" Button
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
                                        'Get started',
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

/// Custom painter for the Mandi Gold Coin, Bar Chart, Trendline & Map Pin
class _IntroPriceIllustrationPainter extends CustomPainter {
  const _IntroPriceIllustrationPainter();

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Large Golden Rupee Coin at top right (cx: 280, cy: 150)
    // Outer golden glow halo (r: 96)
    final coinGlow = Paint()
      ..color = const Color(0xFFF2B134).withOpacity(0.28)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(const Offset(280, 150), 96, coinGlow);

    // Main Coin body (r: 66, fill #F2B134, stroke #8A5600 width 4)
    final coinFill = Paint()
      ..color = const Color(0xFFF2B134)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(const Offset(280, 150), 66, coinFill);

    final coinBorder = Paint()
      ..color = const Color(0xFF8A5600)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0;
    canvas.drawCircle(const Offset(280, 150), 66, coinBorder);

    // Inner Coin Ring (r: 50, stroke #8A5600 width 2)
    final coinInnerRing = Paint()
      ..color = const Color(0xFF8A5600)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawCircle(const Offset(280, 150), 50, coinInnerRing);

    // Rupee Symbol "₹" centered in coin
    final textPainter = TextPainter(
      text: const TextSpan(
        text: '₹',
        style: TextStyle(
          fontFamily: 'Mukta',
          fontSize: 62,
          fontWeight: FontWeight.w700,
          color: Color(0xFF8A5600),
          height: 1.0,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(280 - textPainter.width / 2, 150 - textPainter.height / 2 - 2),
    );

    // 2. White Card Container for Chart (x: 44, y: 190, w: 220, h: 140, rx: 26)
    final cardRRect = RRect.fromRectAndRadius(
      const Rect.fromLTWH(44, 190, 220, 140),
      const Radius.circular(26),
    );
    canvas.drawRRect(cardRRect, Paint()..color = Colors.white);
    canvas.drawRRect(
      cardRRect,
      Paint()
        ..color = const Color(0xFFE6E0D2)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0,
    );

    // 3. Four Green Mandi Comparison Bars inside Card
    // Bar 1: x: 70, y: 240, w: 34, h: 60, rx: 10, fill #7DB88A
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(70, 240, 34, 60), const Radius.circular(10)),
      Paint()..color = const Color(0xFF7DB88A),
    );

    // Bar 2: x: 118, y: 210, w: 34, h: 90, rx: 10, fill #5DAA6E
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(118, 210, 34, 90), const Radius.circular(10)),
      Paint()..color = const Color(0xFF5DAA6E),
    );

    // Bar 3: x: 166, y: 230, w: 34, h: 70, rx: 10, fill #7DB88A
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(166, 230, 34, 70), const Radius.circular(10)),
      Paint()..color = const Color(0xFF7DB88A),
    );

    // Bar 4 (Peak Price): x: 214, y: 180, w: 34, h: 120, rx: 10, fill #3A8350
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(214, 180, 34, 120), const Radius.circular(10)),
      Paint()..color = const Color(0xFF3A8350),
    );

    // 4. Trend Line (d="M74 238l48-30 44 18 56-52" stroke="#8E3F20" stroke-width="3.4")
    final trendPaint = Paint()
      ..color = const Color(0xFF8E3F20)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.4
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final trendPath = Path()
      ..moveTo(74, 238)
      ..lineTo(122, 208)
      ..lineTo(166, 226)
      ..lineTo(222, 174);
    canvas.drawPath(trendPath, trendPaint);

    // 5. Map Pin Marker at x=86, y=344 (d="M86 346l-8-10a10 10 0 1 1 16 0z")
    final pinPaint = Paint()
      ..color = const Color(0xFF8E3F20)
      ..style = PaintingStyle.fill;

    final pinPath = Path()
      ..moveTo(86, 344)
      ..lineTo(78, 334)
      ..arcToPoint(const Offset(94, 334), radius: const Radius.circular(10))
      ..close();
    canvas.drawPath(pinPath, pinPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
