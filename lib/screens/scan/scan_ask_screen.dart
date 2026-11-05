import 'package:flutter/material.dart';
import '../../l10n/app_strings.dart';
import '../../models/diary_entry.dart';
import '../../services/storage_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/safe_local_image.dart';

class ScanAskScreen extends StatefulWidget {
  const ScanAskScreen({Key? key}) : super(key: key);

  @override
  State<ScanAskScreen> createState() => _ScanAskScreenState();
}

class _ScanAskScreenState extends State<ScanAskScreen> {
  final StorageService _storage = StorageService();
  bool _isSpeaking = false;
  bool _isScanning = false;
  String _selectedCrop = 'Ashwagandha leaf';
  bool get isHindi => AppLanguage().isHindi;

  void _simulateSpeech() {
    setState(() => _isSpeaking = true);
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.volume_up_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                isHindi
                    ? 'पत्तियों पर पीले धब्बे: ज्यादा नमी के कारण लीफ स्पॉट फफूंद हो सकती है...'
                    : 'Yellow leaf spots: Potential fungal leaf spot from excess moisture...',
                style: const TextStyle(fontFamily: 'Mukta', fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.primaryGreen,
        duration: const Duration(seconds: 3),
      ),
    );
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) setState(() => _isSpeaking = false);
    });
  }

  void _addToDiary() async {
    final entry = DiaryEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: 'Scanned: Leaf Spot Identified',
      category: 'Pest Control',
      date: 'Today, Just now',
      notes: 'Observed yellow-brown spots on Ashwagandha leaf. Plan to remove spotted leaves and avoid wetting foliage.',
    );
    await _storage.addDiaryEntry(entry);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isHindi ? '✓ खेत डायरी में जोड़ दिया गया' : '✓ Added to Farm Diary!',
            style: const TextStyle(fontFamily: 'Mukta', fontWeight: FontWeight.w500),
          ),
          backgroundColor: AppColors.primaryGreen,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _scanAgain() {
    setState(() => _isScanning = true);
    Future.delayed(const Duration(milliseconds: 700), () {
      if (mounted) {
        setState(() => _isScanning = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isHindi ? 'नया स्कैन पूरा हुआ' : 'Leaf scan refreshed!',
              style: const TextStyle(fontFamily: 'Mukta'),
            ),
            backgroundColor: AppColors.primaryGreen,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final lang = AppLanguage();
    final isHindi = lang.isHindi;

    return Scaffold(
      backgroundColor: AppColors.creamBg, // #F6F2E9
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Header with Circular Back Button
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.maybePop(context),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: const Color(0xFFDDD6C4), width: 1),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.chevron_left_rounded,
                          size: 26,
                          color: AppColors.textDark,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isHindi ? 'फसल जांच परिणाम' : 'YOUR CROP CHECK',
                          style: const TextStyle(
                            fontFamily: 'Mukta',
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.8,
                            color: Color(0xFF3A6B4A),
                          ),
                        ),
                        Text(
                          isHindi ? 'स्कैन परिणाम' : 'Scan Result',
                          style: const TextStyle(
                            fontFamily: 'Mukta',
                            fontSize: 32,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textDark,
                            height: 1.05,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                isHindi ? 'जांच में यह पाया गया।' : 'Here is what we found.',
                style: const TextStyle(
                  fontFamily: 'Mukta',
                  fontSize: 14.5,
                  color: AppColors.textMuted, fontWeight: FontWeight.w400,
                ),
              ),

              const SizedBox(height: 14),

              // 2. Leaf Preview Hero Card with Viewfinder
              Container(
                height: 180,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFF1E4D2B),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: const [
                    BoxShadow(
                      color: AppColors.cardShadow,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Real Crop Photography Focus
                      const SafeLocalImage(
                        imagePath: 'assets/images/mustard_crop.jpg',
                        fit: BoxFit.cover,
                      ),
                      // Translucent Focus Overlay
                      Container(
                        color: Colors.black.withOpacity(0.20),
                      ),
                      // Viewfinder graphic overlay
                      Positioned.fill(
                        child: CustomPaint(
                          painter: _LeafScanPreviewPainter(),
                        ),
                      ),
                      // "Ashwagandha leaf" tag at bottom left
                      Positioned(
                        left: 14,
                        bottom: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x20000000),
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF2E7D32),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                isHindi ? 'सरसों पत्ती (AI स्कैन)' : 'Crop Leaf (AI Lens Active)',
                                style: const TextStyle(
                                  fontFamily: 'Mukta',
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textDark,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (_isScanning)
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.4),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: const Center(
                            child: CircularProgressIndicator(
                              color: AppColors.primaryGreen,
                              strokeWidth: 3,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 14),

              // 3. Diagnosis Card (.c, padding: 14)
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: AppColors.borderLight, width: 1),
                  boxShadow: const [
                    BoxShadow(
                      color: AppColors.cardShadow,
                      offset: Offset(0, 3),
                      blurRadius: 0,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Tag: "POSSIBLE ISSUE · SAMPLE"
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.accentGoldLight, // #FCEFD0
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            isHindi ? 'संभावित समस्या · नमूना' : 'POSSIBLE ISSUE · SAMPLE',
                            style: const TextStyle(
                              fontFamily: 'Mukta',
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.6,
                              color: Color(0xFF7A4D00),
                            ),
                          ),
                        ),
                        // Listen Audio Button
                        GestureDetector(
                          onTap: _simulateSpeech,
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: _isSpeaking ? AppColors.accentGold : AppColors.mintTint,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Center(
                              child: Icon(
                                _isSpeaking ? Icons.volume_up_rounded : Icons.volume_up_outlined,
                                size: 20,
                                color: _isSpeaking ? Colors.white : AppColors.primaryGreen,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      isHindi ? 'लीफ स्पॉट (पत्ती धब्बा रोग)' : 'Leaf spot',
                      style: const TextStyle(
                        fontFamily: 'Mukta',
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textDark,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFAFAFA),
                        border: Border.all(color: const Color(0xFF8BB5DF), width: 1.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        isHindi
                            ? 'पत्तियों पर छोटे पीले-भूरे धब्बे, जो अक्सर अत्यधिक नमी के कारण होते हैं।'
                            : 'Small yellow-brown spots on the leaves, often linked to too much moisture.',
                        style: const TextStyle(
                          fontFamily: 'Mukta',
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDark,
                          height: 1.25,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // 4. Section: What you can do
              Text(
                isHindi ? 'आप क्या कर सकते हैं' : 'What you can do',
                style: const TextStyle(
                  fontFamily: 'Mukta',
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
              ),

              const SizedBox(height: 8),

              // 5. Action Checklist Card (.c, numbered 1, 2, 3)
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: AppColors.borderLight, width: 1),
                  boxShadow: const [
                    BoxShadow(
                      color: AppColors.cardShadow,
                      offset: Offset(0, 3),
                      blurRadius: 0,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildStepRow(
                      stepNumber: '1',
                      text: isHindi
                          ? 'अधिक प्रभावित धब्बेदार पत्तियों को हटा दें।'
                          : 'Remove badly spotted leaves.',
                      showDivider: true,
                    ),
                    _buildStepRow(
                      stepNumber: '2',
                      text: isHindi
                          ? 'पत्तियों पर नहीं, पौधों की जड़ में पानी दें।'
                          : 'Water at the base, not on the leaves.',
                      showDivider: true,
                    ),
                    _buildStepRow(
                      stepNumber: '3',
                      text: isHindi
                          ? 'हवा के संचार के लिए पौधों के बीच दूरी रखें।'
                          : 'Keep space between plants for air.',
                      showDivider: false,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // 6. Action Buttons Row: [+ Add to Diary] & [Scan again]
              Row(
                children: [
                  Expanded(
                    flex: 12,
                    child: GestureDetector(
                      onTap: _addToDiary,
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.primaryGreen,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: const [
                            BoxShadow(
                              color: AppColors.primaryDark,
                              offset: Offset(0, 4),
                              blurRadius: 0,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            isHindi ? '+ डायरी में जोड़ें' : '+ Add to Diary',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontFamily: 'Mukta',
                              fontSize: 15.5,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 10,
                    child: GestureDetector(
                      onTap: _scanAgain,
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: AppColors.primaryGreen, width: 1.5),
                        ),
                        child: Center(
                          child: Text(
                            isHindi ? 'पुनः स्कैन करें' : 'Scan again',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontFamily: 'Mukta',
                              fontSize: 15.5,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primaryGreen,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // 7. Disclaimer Box
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.accentGoldLight, // #FCEFD0
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 2, right: 10),
                      child: Icon(
                        Icons.info_outline_rounded,
                        size: 18,
                        color: Color(0xFF5C3D00),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        isHindi
                            ? 'केवल सांकेतिक परिणाम। अपनी फसल के उपचार से पहले कृषि विशेषज्ञ से सलाह लें।'
                            : 'Sample result only. Consult an agricultural expert before treating your crop.',
                        style: const TextStyle(
                          fontFamily: 'Mukta',
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF5C3D00),
                          height: 1.3,
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
    );
  }

  Widget _buildStepRow({
    required String stepNumber,
    required String text,
    required bool showDivider,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        border: showDivider
            ? const Border(bottom: BorderSide(color: Color(0xFFEEE8DA), width: 1))
            : null,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Dark green circle with number
          Container(
            width: 26,
            height: 26,
            decoration: const BoxDecoration(
              color: AppColors.primaryGreen,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                stepNumber,
                style: const TextStyle(
                  fontFamily: 'Mukta',
                  fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: Colors.white,
                  height: 1.0,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontFamily: 'Mukta',
                fontSize: 14.5,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Custom painter for the scanned leaf illustration + yellow spots + viewfinder brackets
class _LeafScanPreviewPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // 1. Leaf Shape (Left / Center)
    final leafPaint = Paint()
      ..color = const Color(0xFF488B58)
      ..style = PaintingStyle.fill;

    final leafPath = Path();
    leafPath.moveTo(40, 115);
    leafPath.cubicTo(60, 45, 140, 25, 230, 25);
    leafPath.cubicTo(190, 85, 130, 125, 40, 115);
    leafPath.close();
    canvas.drawPath(leafPath, leafPaint);

    // Leaf Midrib Vein
    final veinPaint = Paint()
      ..color = const Color(0xFF265633)
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    canvas.drawLine(const Offset(40, 115), const Offset(230, 25), veinPaint);

    // 2. Yellow/Orange Infection Spots on leaf
    final spotFill = Paint()
      ..color = const Color(0xFFF2B134)
      ..style = PaintingStyle.fill;
    final spotStroke = Paint()
      ..color = const Color(0xFFC07A10)
      ..strokeWidth = 1.4
      ..style = PaintingStyle.stroke;

    final spots = [
      const Offset(85, 75),
      const Offset(115, 60),
      const Offset(135, 90),
      const Offset(165, 55),
      const Offset(185, 80),
      const Offset(150, 40),
    ];

    for (final s in spots) {
      canvas.drawCircle(s, 5.0, spotFill);
      canvas.drawCircle(s, 5.0, spotStroke);
    }

    // 3. Viewfinder Brackets on Right (Width ~100, Height ~100)
    final bracketPaint = Paint()
      ..color = const Color(0xFF1E4D2B)
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final double bx = (size.width - 120).clamp(10.0, 500.0);
    const double by = 25.0;
    const double bw = 100.0;
    const double bh = 105.0;
    const double len = 20.0;

    // Top-Left bracket
    canvas.drawLine(Offset(bx, by), Offset(bx + len, by), bracketPaint);
    canvas.drawLine(Offset(bx, by), Offset(bx, by + len), bracketPaint);

    // Top-Right bracket
    canvas.drawLine(Offset(bx + bw, by), Offset(bx + bw - len, by), bracketPaint);
    canvas.drawLine(Offset(bx + bw, by), Offset(bx + bw, by + len), bracketPaint);

    // Bottom-Left bracket
    canvas.drawLine(Offset(bx, by + bh), Offset(bx + len, by + bh), bracketPaint);
    canvas.drawLine(Offset(bx, by + bh), Offset(bx, by + bh - len), bracketPaint);

    // Bottom-Right bracket
    canvas.drawLine(Offset(bx + bw, by + bh), Offset(bx + bw - len, by + bh), bracketPaint);
    canvas.drawLine(Offset(bx + bw, by + bh), Offset(bx + bw, by + bh - len), bracketPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
