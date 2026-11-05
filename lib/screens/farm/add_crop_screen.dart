import 'package:flutter/material.dart';
import '../../l10n/app_strings.dart';
import '../../models/crop.dart';
import '../../models/farm.dart';
import '../../theme/app_theme.dart';

class AddCropScreen extends StatefulWidget {
  final Farm farm;
  const AddCropScreen({Key? key, required this.farm}) : super(key: key);

  @override
  State<AddCropScreen> createState() => _AddCropScreenState();
}

class _AddCropScreenState extends State<AddCropScreen> {
  String _selectedCrop = 'Ashwagandha';
  double _allocatedAcres = 1.0;
  String _selectedStage = 'Early growth';

  final List<Map<String, dynamic>> _cropOptions = [
    {
      'name': 'Ashwagandha',
      'bgColor': const Color(0xFFE2EFDF),
      'iconColor': const Color(0xFF1E4D2B),
      'iconType': _CropType.sprout,
    },
    {
      'name': 'Tulsi',
      'bgColor': const Color(0xFFFBE3A6),
      'iconColor': const Color(0xFFC06A3C),
      'iconType': _CropType.tulsi,
    },
    {
      'name': 'Wheat',
      'bgColor': const Color(0xFFFCEFD0),
      'iconColor': const Color(0xFF8A5600),
      'iconType': _CropType.wheat,
    },
    {
      'name': 'Mustard',
      'bgColor': const Color(0xFFFDF1D6),
      'iconColor': const Color(0xFFB8860B),
      'iconType': _CropType.mustard,
    },
    {
      'name': 'Gram',
      'bgColor': const Color(0xFFF3D3C4),
      'iconColor': const Color(0xFF8E3F20),
      'iconType': _CropType.gram,
    },
    {
      'name': 'Other',
      'bgColor': const Color(0xFFDDEBF3),
      'iconColor': const Color(0xFF18566F),
      'iconType': _CropType.other,
    },
  ];

  final List<String> _growthStages = [
    'Sowing',
    'Early growth',
    'Vegetative',
    'Flowering',
    'Harvest',
  ];

  void _saveCrop() {
    final crop = Crop(
      name: _selectedCrop,
      variety: 'Standard / High-yield',
      growthStage: _selectedStage,
      sowingDate: DateTime.now().subtract(const Duration(days: 30)),
      expectedHarvestDate: DateTime.now().add(const Duration(days: 90)),
      notes: 'Allocated area: $_allocatedAcres ${_allocatedAcres == 1 ? "acre" : "acres"}. Stage: $_selectedStage.',
    );
    Navigator.of(context).pop(crop);
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
                          isHindi ? 'फसल विस्तार' : 'GROW MORE',
                          style: const TextStyle(
                            fontFamily: 'Mukta',
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.8,
                            color: Color(0xFF3A6B4A),
                          ),
                        ),
                        Text(
                          isHindi ? 'फसल जोड़ें' : 'Add Crop',
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
                isHindi
                    ? 'एक फसल चुनें और उसकी जानकारी दें।'
                    : 'Choose a crop and tell us about it.',
                style: const TextStyle(
                  fontFamily: 'Mukta',
                  fontSize: 14.5,
                  color: AppColors.textMuted, fontWeight: FontWeight.w400,
                ),
              ),

              const SizedBox(height: 16),

              // 2. Section: Choose crop
              Text(
                isHindi ? 'फसल चुनें' : 'Choose crop',
                style: const TextStyle(
                  fontFamily: 'Mukta',
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
              ),

              const SizedBox(height: 10),

              // 6 Crop Grid (3 columns x 2 rows)
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _cropOptions.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 0.98,
                ),
                itemBuilder: (context, index) {
                  final opt = _cropOptions[index];
                  final name = opt['name'] as String;
                  final isSelected = _selectedCrop == name;
                  final bgColor = opt['bgColor'] as Color;
                  final iconType = opt['iconType'] as _CropType;

                  return GestureDetector(
                    onTap: () => setState(() => _selectedCrop = name),
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFFE2EFDF) : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected ? AppColors.primaryGreen : AppColors.borderLight,
                          width: isSelected ? 2.0 : 1.0,
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: AppColors.cardShadow,
                            offset: Offset(0, 3),
                            blurRadius: 0,
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          // Centered Icon & Label
                          Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: bgColor,
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Center(
                                    child: SizedBox(
                                      width: 26,
                                      height: 26,
                                      child: CustomPaint(
                                        painter: _CropMiniIconPainter(type: iconType),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  name,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontFamily: 'Mukta',
                                    fontSize: 14,
                                    fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
                                    color: isSelected ? AppColors.primaryGreen : AppColors.textDark,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Selected Checkmark Badge (top right)
                          if (isSelected)
                            Positioned(
                              top: 6,
                              right: 6,
                              child: Container(
                                width: 18,
                                height: 18,
                                decoration: const BoxDecoration(
                                  color: AppColors.primaryGreen,
                                  shape: BoxShape.circle,
                                ),
                                child: const Center(
                                  child: Icon(
                                    Icons.check_rounded,
                                    size: 13,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 18),

              // 3. Section: Land for this crop
              Text(
                isHindi ? 'इस फसल के लिए जमीन' : 'Land for this crop',
                style: const TextStyle(
                  fontFamily: 'Mukta',
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
              ),

              const SizedBox(height: 8),

              // Counter Bar (.c, height: 58)
              Container(
                height: 58,
                padding: const EdgeInsets.symmetric(horizontal: 14),
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
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Minus Button
                    GestureDetector(
                      onTap: () {
                        if (_allocatedAcres > 0.5) {
                          setState(() => _allocatedAcres -= 0.5);
                        }
                      },
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: const Color(0xFFDDEFD9),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.remove_rounded,
                            size: 22,
                            color: AppColors.primaryGreen,
                          ),
                        ),
                      ),
                    ),

                    // Label: "1 acre"
                    Text(
                      '${_allocatedAcres % 1 == 0 ? _allocatedAcres.toInt() : _allocatedAcres} ${_allocatedAcres == 1 ? "acre" : "acres"}',
                      style: const TextStyle(
                        fontFamily: 'Mukta',
                        fontSize: 19,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textDark,
                      ),
                    ),

                    // Plus Button
                    GestureDetector(
                      onTap: () {
                        setState(() => _allocatedAcres += 0.5);
                      },
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: const Color(0xFFDDEFD9),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.add_rounded,
                            size: 22,
                            color: AppColors.primaryGreen,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // 4. Section: Growth stage
              Text(
                isHindi ? 'विकास की अवस्था' : 'Growth stage',
                style: const TextStyle(
                  fontFamily: 'Mukta',
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
              ),

              const SizedBox(height: 10),

              // Growth Stage Pills
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _growthStages.map((stage) {
                  final isSelected = _selectedStage == stage;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedStage = stage),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primaryGreen : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: isSelected
                            ? null
                            : Border.all(color: AppColors.borderLight, width: 1),
                        boxShadow: isSelected
                            ? const [
                                BoxShadow(
                                  color: AppColors.primaryDark,
                                  offset: Offset(0, 3),
                                  blurRadius: 0,
                                ),
                              ]
                            : null,
                      ),
                      child: Text(
                        stage,
                        style: TextStyle(
                          fontFamily: 'Mukta',
                          fontSize: 14,
                          fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
                          color: isSelected ? Colors.white : AppColors.textDark,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 28),

              // 5. Bottom Full-Width "Save crop →" Button
              GestureDetector(
                onTap: _saveCrop,
                child: Container(
                  width: double.infinity,
                  height: 52,
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen,
                    borderRadius: BorderRadius.circular(26),
                    boxShadow: const [
                      BoxShadow(
                        color: AppColors.primaryDark,
                        offset: Offset(0, 4),
                        blurRadius: 0,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        isHindi ? 'फसल सहेजें →' : 'Save crop →',
                        style: const TextStyle(
                          fontFamily: 'Mukta',
                          fontSize: 17,
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
    );
  }
}

enum _CropType { sprout, tulsi, wheat, mustard, gram, other }

class _CropMiniIconPainter extends CustomPainter {
  final _CropType type;
  _CropMiniIconPainter({required this.type});

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 24.0;
    canvas.scale(scale, scale);

    final stemPaint = Paint()
      ..color = const Color(0xFF1E4D2B)
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final leafFill = Paint()
      ..color = const Color(0xFF3A8350)
      ..style = PaintingStyle.fill;

    switch (type) {
      case _CropType.sprout:
      case _CropType.mustard:
      case _CropType.gram:
      case _CropType.other:
        canvas.drawLine(const Offset(12, 21), const Offset(12, 10), stemPaint);
        final leftLeaf = Path()
          ..moveTo(12, 14)
          ..cubicTo(8, 14, 5, 10, 5, 7)
          ..cubicTo(9, 7, 12, 10, 12, 14)
          ..close();
        canvas.drawPath(leftLeaf, leafFill);
        final rightLeaf = Path()
          ..moveTo(12, 11)
          ..cubicTo(12, 7, 15, 5, 19, 5)
          ..cubicTo(19, 9, 16, 11, 12, 11)
          ..close();
        canvas.drawPath(rightLeaf, leafFill);
        break;

      case _CropType.tulsi:
        // Pot
        final pot = Path()
          ..moveTo(7, 16)
          ..lineTo(17, 16)
          ..lineTo(15, 21)
          ..lineTo(9, 21)
          ..close();
        final potPaint = Paint()..color = const Color(0xFFC06A3C);
        canvas.drawPath(pot, potPaint);
        canvas.drawLine(const Offset(12, 16), const Offset(12, 8), stemPaint);
        final left = Path()
          ..moveTo(12, 12)
          ..cubicTo(8, 12, 6, 9, 6, 6)
          ..cubicTo(10, 6, 12, 9, 12, 12)
          ..close();
        canvas.drawPath(left, leafFill);
        break;

      case _CropType.wheat:
        canvas.drawLine(const Offset(12, 22), const Offset(12, 4), stemPaint);
        final grainPaint = Paint()..color = const Color(0xFFD4931A);
        canvas.drawOval(Rect.fromCenter(center: const Offset(9, 8), width: 6, height: 4), grainPaint);
        canvas.drawOval(Rect.fromCenter(center: const Offset(15, 8), width: 6, height: 4), grainPaint);
        canvas.drawOval(Rect.fromCenter(center: const Offset(9, 13), width: 6, height: 4), grainPaint);
        canvas.drawOval(Rect.fromCenter(center: const Offset(15, 13), width: 6, height: 4), grainPaint);
        break;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
