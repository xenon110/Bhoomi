import 'package:flutter/material.dart';
import '../../l10n/app_strings.dart';
import '../../models/farm.dart';
import '../../services/storage_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/safe_local_image.dart';
import 'boundary_canvas_screen.dart';

class FarmPlannerScreen extends StatefulWidget {
  const FarmPlannerScreen({Key? key}) : super(key: key);

  @override
  State<FarmPlannerScreen> createState() => _FarmPlannerScreenState();
}

class _FarmPlannerScreenState extends State<FarmPlannerScreen> {
  final StorageService _storage = StorageService();
  double _landArea = 2.0;
  String _selectedCrop = 'Mustard';

  final Map<String, Map<String, dynamic>> _cropGuides = {
    'Mustard': {
      'name': 'Yellow Mustard',
      'hiName': 'पीली सरसों',
      'variety': 'Varuna (T-59) / Pusa Bold',
      'season': 'Rabi Season (Oct – Nov)',
      'photo': 'assets/images/mustard_crop.jpg',
      'seedRate': 1.8, // kg per acre
      'rowSpacing': '45 cm (1.5 ft)',
      'plantSpacing': '15 cm (6 inches)',
      'depth': '3 to 4 cm',
      'bedType': 'Broad Bed & Furrow (BBF)',
      'furrows': 'Raised beds (1 m wide) with 30 cm drainage furrows',
      'orientation': 'East to West (for maximum solar absorption)',
      'waterStage': '2 light irrigations (at 25 days & 55 days)',
      'basalDose': 'DAP 40 kg + MOP 15 kg + Sulphur 10 kg / acre',
      'topDress': 'Urea 30 kg / acre at first irrigation',
      'harvestDays': '105 – 120 Days',
      'yieldMin': 8.0,
      'yieldMax': 11.0,
      'pricePerQtl': 6200.0,
      'costPerAcre': 11000.0,
      'proTip': 'Sow when soil temperature drops below 30°C. Adding elemental Sulphur increases oil content by up to 3%.',
    },
    'Wheat': {
      'name': 'Sharbati Wheat',
      'hiName': 'शरबती गेहूं',
      'variety': 'HD-2967 / PBW-502',
      'season': 'Rabi Season (Nov – Dec)',
      'photo': 'assets/images/wheat_crop.jpg',
      'seedRate': 40.0, // kg per acre
      'rowSpacing': '20 cm (8 inches)',
      'plantSpacing': 'Continuous line sowing (5 cm)',
      'depth': '4 to 5 cm',
      'bedType': 'Flat beds with border irrigation strips',
      'furrows': 'Long flat beds (4 m x 25 m) along natural contour',
      'orientation': 'North to South (for uniform canopy sunlight)',
      'waterStage': '4-5 irrigations (CRI root stage at 21 days is vital)',
      'basalDose': 'DAP 55 kg + MOP 20 kg / acre at sowing',
      'topDress': 'Urea 35 kg / acre at 21 days & 45 days',
      'harvestDays': '125 – 135 Days',
      'yieldMin': 18.0,
      'yieldMax': 22.0,
      'pricePerQtl': 2350.0,
      'costPerAcre': 14000.0,
      'proTip': 'Never delay the CRI stage irrigation (Day 21). Use a seed-cum-fertilizer drill to ensure precise 4 cm depth.',
    },
    'Potato': {
      'name': 'Potato',
      'hiName': 'आलू',
      'variety': 'Kufri Pukhraj / Jyoti',
      'season': 'Rabi Season (Oct – Nov)',
      'photo': 'assets/images/farmer_field.jpg',
      'seedRate': 600.0, // kg per acre
      'rowSpacing': '60 cm (2 ft)',
      'plantSpacing': '20 cm (8 inches)',
      'depth': '5 to 7 cm',
      'bedType': 'Ridge & Furrow system',
      'furrows': 'Raised ridges of 25 cm height for free tuber expansion',
      'orientation': 'Slope direction for rapid drainage',
      'waterStage': 'Light irrigation every 8 to 10 days',
      'basalDose': 'DAP 80 kg + MOP 50 kg + Zinc 10 kg / acre',
      'topDress': 'Earthing up at 30 days with Urea',
      'harvestDays': '85 – 100 Days',
      'yieldMin': 90.0,
      'yieldMax': 120.0,
      'pricePerQtl': 1400.0,
      'costPerAcre': 28000.0,
      'proTip': 'Ensure soil is friable and well-aerated. Avoid standing water to protect against late blight fungal rot.',
    },
    'Gram': {
      'name': 'Chickpea / Gram',
      'hiName': 'देसी चना',
      'variety': 'JG-14 / Radhey',
      'season': 'Rabi Season (Oct – Nov)',
      'photo': 'assets/images/farmer_field.jpg',
      'seedRate': 30.0, // kg per acre
      'rowSpacing': '30 cm (1 ft)',
      'plantSpacing': '10 cm (4 inches)',
      'depth': '5 to 6 cm',
      'bedType': 'Broad beds with moisture trapping channels',
      'furrows': 'Contour furrows to trap winter morning dew',
      'orientation': 'East to West orientation',
      'waterStage': '1-2 light irrigations (pre-flowering stage)',
      'basalDose': 'DAP 35 kg + Rhizobium bio-fertilizer treat',
      'topDress': 'Foliar spray of 2% Urea at pod development',
      'harvestDays': '110 – 125 Days',
      'yieldMin': 7.0,
      'yieldMax': 9.5,
      'pricePerQtl': 5800.0,
      'costPerAcre': 9500.0,
      'proTip': 'Nipping (pinching off the top shoot tips at 30 days) doubles lateral branches and total pods per plant.',
    },
    'Paddy': {
      'name': 'Paddy / Rice',
      'hiName': 'धान',
      'variety': 'IR-64 / Pusa 1509',
      'season': 'Kharif Season (Jun – Jul)',
      'photo': 'assets/images/farmer_field.jpg',
      'seedRate': 15.0, // kg per acre
      'rowSpacing': '20 cm (8 inches)',
      'plantSpacing': '15 cm (6 inches)',
      'depth': '2 to 3 cm in puddled bed',
      'bedType': 'Puddled basins with bunds',
      'furrows': 'Water retention bunds with 5 cm standing water',
      'orientation': 'Along the contour for even water retention',
      'waterStage': 'Continuous shallow water (3-5 cm) until 15 days before harvest',
      'basalDose': 'DAP 50 kg + MOP 30 kg + Zinc Sulphate 10 kg / acre',
      'topDress': 'Urea 35 kg / acre at tillering & panicle initiation',
      'harvestDays': '115 – 130 Days',
      'yieldMin': 22.0,
      'yieldMax': 28.0,
      'pricePerQtl': 2300.0,
      'costPerAcre': 16000.0,
      'proTip': 'Transplant 21-25 day old seedlings. Zinc deficiency causes khaira disease — apply Zinc Sulphate at basal stage.',
    },
    'Maize': {
      'name': 'Maize / Corn',
      'hiName': 'मक्का',
      'variety': 'Pioneer 3396 / Ganga-11',
      'season': 'Kharif & Rabi (Year round)',
      'photo': 'assets/images/wheat_crop.jpg',
      'seedRate': 8.0, // kg per acre
      'rowSpacing': '60 cm (2 ft)',
      'plantSpacing': '20 cm (8 inches)',
      'depth': '4 to 5 cm',
      'bedType': 'Ridge & Furrow system',
      'furrows': 'Plant on side of 20 cm ridges to avoid water stagnation',
      'orientation': 'North to South for maximum leaf solar exposure',
      'waterStage': 'Critical at knee-high, tasseling & silking stages',
      'basalDose': 'DAP 60 kg + MOP 25 kg + Zinc 10 kg / acre',
      'topDress': 'Urea 40 kg / acre at knee-high stage',
      'harvestDays': '95 – 110 Days',
      'yieldMin': 25.0,
      'yieldMax': 35.0,
      'pricePerQtl': 2250.0,
      'costPerAcre': 13500.0,
      'proTip': 'Maize cannot tolerate waterlogging. Sowing on ridges ensures rapid excess water drainage during heavy rains.',
    },
  };

  void _saveToMyFarm() async {
    final guide = _cropGuides[_selectedCrop]!;
    final primary = _storage.getPrimaryFarm();

    final newField = Field(
      name: '${_selectedCrop} Plot (${_landArea.toStringAsFixed(1)} Ac)',
      area: _landArea,
      crop: guide['name'] as String,
      sowingDate: DateTime.now(),
    );

    primary.fields.add(newField);
    await _storage.updatePrimaryFarm(primary);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '✓ ${_selectedCrop} field layout saved to your farm!',
            style: const TextStyle(fontFamily: 'Mukta', fontWeight: FontWeight.w500),
          ),
          backgroundColor: const Color(0xFF1E4D2B),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isHindi = AppLanguage().isHindi;
    final guide = _cropGuides[_selectedCrop]!;
    final totalSeedKg = ((guide['seedRate'] as num) * _landArea);
    final totalDAP = ((_selectedCrop == 'Potato' ? 80 : 45) * _landArea).round();
    final totalYieldMin = ((guide['yieldMin'] as num) * _landArea).toStringAsFixed(0);
    final totalYieldMax = ((guide['yieldMax'] as num) * _landArea).toStringAsFixed(0);
    final estGross = (((guide['yieldMin'] as num) + (guide['yieldMax'] as num)) / 2 * _landArea * (guide['pricePerQtl'] as num)).round();
    final estCost = ((guide['costPerAcre'] as num) * _landArea).round();
    final estNetProfit = estGross - estCost;
    final roiPercent = estCost > 0 ? ((estNetProfit / estCost) * 100).round() : 0;

    String formatInr(int val) {
      return val.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},');
    }

    return Scaffold(
      backgroundColor: AppColors.creamBg,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Top Header
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
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x10000000),
                            offset: Offset(0, 2),
                            blurRadius: 3,
                          ),
                        ],
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
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'FIELD LAYOUT & PLANTING GUIDE',
                          style: TextStyle(
                            fontFamily: 'Mukta',
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.1,
                            color: Color(0xFF3A6B4A),
                          ),
                        ),
                        Text(
                          'Design My Land',
                          style: TextStyle(
                            fontFamily: 'Mukta',
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textDark,
                            height: 1.15,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              const Text(
                'Select your land size and crop to get an exact planting and field organization guide.',
                style: TextStyle(
                  fontFamily: 'Mukta',
                  fontSize: 13.5,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF55655A),
                ),
              ),

              const SizedBox(height: 16),

              // 2. Step 1: Select Land Size & Crop
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: const Color(0xFFE6E0D2)),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0xFFE9E2D1),
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Section Title
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          '1. Enter Land Size',
                          style: TextStyle(
                            fontFamily: 'Mukta',
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1B2A21),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE2EFDF),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '~${(_landArea * 3.2).toStringAsFixed(1)} Bigha (${(_landArea * 64).toStringAsFixed(0)} Katha)',
                            style: const TextStyle(
                              fontFamily: 'Mukta',
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF1E4D2B),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Land Size Stepper & Quick Chips
                    Row(
                      children: [
                        // +/- Stepper for exact increments
                        Container(
                          height: 38,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF6F2E9),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFDDD6C4)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              InkWell(
                                onTap: () {
                                  if (_landArea > 0.5) {
                                    setState(() => _landArea = ((_landArea - 0.5) * 10).round() / 10);
                                  }
                                },
                                borderRadius: const BorderRadius.horizontal(left: Radius.circular(12)),
                                child: const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  child: Icon(Icons.remove, size: 16, color: Color(0xFF1E4D2B)),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                color: Colors.white,
                                child: Text(
                                  '${_landArea.toStringAsFixed(1)} Ac',
                                  style: const TextStyle(
                                    fontFamily: 'Mukta',
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF1E4D2B),
                                  ),
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  if (_landArea < 50.0) {
                                    setState(() => _landArea = ((_landArea + 0.5) * 10).round() / 10);
                                  }
                                },
                                borderRadius: const BorderRadius.horizontal(right: Radius.circular(12)),
                                child: const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  child: Icon(Icons.add, size: 16, color: Color(0xFF1E4D2B)),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),

                        // Quick Acre Selector Chips
                        Expanded(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            physics: const BouncingScrollPhysics(),
                            child: Row(
                              children: [1.0, 1.5, 2.0, 2.5, 3.0, 5.0].map((area) {
                                final isSel = _landArea == area;
                                return Padding(
                                  padding: const EdgeInsets.only(right: 6),
                                  child: InkWell(
                                    onTap: () => setState(() => _landArea = area),
                                    borderRadius: BorderRadius.circular(12),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
                                      decoration: BoxDecoration(
                                        color: isSel ? const Color(0xFF1E4D2B) : const Color(0xFFF6F2E9),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: isSel ? const Color(0xFF1E4D2B) : const Color(0xFFDDD6C4),
                                        ),
                                      ),
                                      child: Text(
                                        '${area.toStringAsFixed(area.truncateToDouble() == area ? 0 : 1)} Ac',
                                        style: TextStyle(
                                          fontFamily: 'Mukta',
                                          fontSize: 12.5,
                                          fontWeight: isSel ? FontWeight.w600 : FontWeight.w400,
                                          color: isSel ? Colors.white : const Color(0xFF1B2A21),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),
                    const Divider(color: Color(0xFFEEE8DA)),
                    const SizedBox(height: 12),

                    // Step 2: Choose Crop
                    const Text(
                      '2. Select Crop to Plant',
                      style: TextStyle(
                        fontFamily: 'Mukta',
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1B2A21),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Crop Selection Horizontal Row with Real Photos
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      child: Row(
                        children: _cropGuides.keys.map((cropKey) {
                          final isSel = _selectedCrop == cropKey;
                          final cData = _cropGuides[cropKey]!;
                          return GestureDetector(
                            onTap: () => setState(() => _selectedCrop = cropKey),
                            child: Container(
                              width: 135,
                              margin: const EdgeInsets.only(right: 10),
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: isSel ? const Color(0xFFFCEFD0) : Colors.white,
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(
                                  color: isSel ? const Color(0xFFC98F1C) : const Color(0xFFE6E0D2),
                                  width: isSel ? 2 : 1,
                                ),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0xFFE9E2D1),
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: SizedBox(
                                      height: 60,
                                      width: double.infinity,
                                      child: SafeLocalImage(
                                        imagePath: cData['photo'] as String,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    cropKey,
                                    style: TextStyle(
                                      fontFamily: 'Mukta',
                                      fontSize: 14,
                                      fontWeight: isSel ? FontWeight.w600 : FontWeight.w500,
                                      color: const Color(0xFF1B2A21),
                                    ),
                                  ),
                                  Text(
                                    cData['variety'].split('/')[0].trim(),
                                    style: const TextStyle(
                                      fontFamily: 'Mukta',
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w400,
                                      color: Color(0xFF55655A),
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // 3. OPTIMIZED FARMLAND LAYOUT (CLEAN IMAGE - NO TEXT ON IMAGE)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFFE6E0D2)),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0xFFE9E2D1),
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: const Color(0xFFE2EFDF),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Center(
                                child: Icon(Icons.grid_view_rounded, color: Color(0xFF1E4D2B), size: 18),
                              ),
                            ),
                            const SizedBox(width: 10),
                            const Text(
                              'Optimized Farmland Layout',
                              style: TextStyle(
                                fontFamily: 'Mukta',
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1B2A21),
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF6F2E9),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFFDDD6C4)),
                          ),
                          child: Text(
                            '$_landArea Acres · Smart Layout',
                            style: const TextStyle(
                              fontFamily: 'Mukta',
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF1B2A21),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // PURE OPTIMIZED FARMLAND IMAGE - ABSOLUTELY ZERO TEXT OVERLAYS
                    ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: Container(
                        width: double.infinity,
                        height: 195,
                        color: const Color(0xFFE2EFDF),
                        child: const SafeLocalImage(
                          imagePath: 'assets/images/optimized_farmland.jpg',
                          width: double.infinity,
                          height: 195,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Quick visual measurement badges below image
                    Row(
                      children: [
                        Expanded(
                          child: _buildFeaturePill(
                            icon: Icons.straighten_rounded,
                            label: 'Row Spacing',
                            val: guide['rowSpacing'],
                            color: const Color(0xFF1E4D2B),
                            bg: const Color(0xFFE2EFDF),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildFeaturePill(
                            icon: Icons.spa_rounded,
                            label: 'Plant Spacing',
                            val: guide['plantSpacing'],
                            color: const Color(0xFF8A5600),
                            bg: const Color(0xFFFCEFD0),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildFeaturePill(
                            icon: Icons.vertical_align_bottom_rounded,
                            label: 'Sowing Depth',
                            val: guide['depth'],
                            color: const Color(0xFF18566F),
                            bg: const Color(0xFFDDEBF3),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // 4. FARMER OUTPUT & PROFIT DASHBOARD (DIRECT OUTPUT NUMBERS - NO TEXT OVERLOAD)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Direct Output & Returns',
                    style: TextStyle(
                      fontFamily: 'Mukta',
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1B2A21),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE2EFDF),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '$_landArea Acres Output',
                      style: const TextStyle(
                        fontFamily: 'Mukta',
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF1E4D2B),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // BIG NET CASH PROFIT HERO CARD (What farmers care about most)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1E4D2B), Color(0xFF15381F)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x331E4D2B),
                      offset: Offset(0, 6),
                      blurRadius: 12,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.account_balance_wallet_outlined, color: Color(0xFFF2B134), size: 18),
                            const SizedBox(width: 8),
                            Text(
                              isHindi ? 'शुद्ध कमाई (Net Profit)' : 'NET PROFIT IN HAND',
                              style: const TextStyle(
                                fontFamily: 'Mukta',
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFFE2EFDF),
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF2B134),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '+$roiPercent% ROI',
                            style: const TextStyle(
                              fontFamily: 'Mukta',
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1B2A21),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '₹${formatInr(estNetProfit)}',
                      style: const TextStyle(
                        fontFamily: 'Mukta',
                        fontSize: 32,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isHindi ? 'बीज, खाद व जुताई खर्च काटकर अनुमानित शुद्ध बचत' : 'Estimated net take-home savings after all seeds, fertilizer & cost',
                      style: TextStyle(
                        fontFamily: 'Mukta',
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: Colors.white.withOpacity(0.85),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // 4 KEY OUTPUT TILES (2x2 Grid)
              Row(
                children: [
                  Expanded(
                    child: _buildOutputTile(
                      label: isHindi ? 'अनुमानित उपज' : 'Expected Yield',
                      value: '$totalYieldMin – $totalYieldMax Qtl',
                      sub: '@ ₹${(guide['pricePerQtl'] as num).round()}/Qtl rate',
                      icon: Icons.eco_rounded,
                      color: const Color(0xFF1E4D2B),
                      bg: const Color(0xFFE2EFDF),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildOutputTile(
                      label: isHindi ? 'कुल मंडी बिक्री' : 'Total Mandi Sales',
                      value: '₹${formatInr(estGross)}',
                      sub: isHindi ? 'सकल राजस्व' : 'Gross revenue',
                      icon: Icons.storefront_rounded,
                      color: const Color(0xFF8A5600),
                      bg: const Color(0xFFFCEFD0),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _buildOutputTile(
                      label: isHindi ? 'कुल लागत' : 'Total Cost',
                      value: '₹${formatInr(estCost)}',
                      sub: isHindi ? 'बीज, खाद, सिंचाई' : 'Seeds, DAP, irrigation',
                      icon: Icons.receipt_long_rounded,
                      color: const Color(0xFFB03A2E),
                      bg: const Color(0xFFFDE8E8),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildOutputTile(
                      label: isHindi ? 'कुल आवश्यक बीज' : 'Total Seed Needed',
                      value: '${totalSeedKg.toStringAsFixed(1)} kg',
                      sub: isHindi ? '$_landArea एकड़ जमीन हेतु' : 'For $_landArea acres land',
                      icon: Icons.inventory_2_rounded,
                      color: const Color(0xFF18566F),
                      bg: const Color(0xFFDDEBF3),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // HARVEST DURATION PILL
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF4ECE1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2D6C3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.timer_outlined, color: Color(0xFF8A5600), size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Harvest in ${guide['harvestDays']} days after sowing',
                        style: const TextStyle(
                          fontFamily: 'Mukta',
                          fontSize: 12.5,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF1B2A21),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'Broad Bed & Furrow',
                        style: TextStyle(
                          fontFamily: 'Mukta',
                          fontSize: 10.5,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF1E4D2B),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // 5. ACTION BUTTON - SAVE TO MY FARM
              GestureDetector(
                onTap: _saveToMyFarm,
                child: Container(
                  width: double.infinity,
                  height: 52,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E4D2B),
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0xFF123320),
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.check_circle_outline_rounded, color: Colors.white, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Save ${_selectedCrop} Layout to My Farm →',
                          style: const TextStyle(
                            fontFamily: 'Mukta',
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Satellite Boundary Canvas shortcut
              Center(
                child: TextButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => BoundaryCanvasScreen(initialArea: _landArea)),
                    );
                  },
                  icon: const Icon(Icons.architecture_rounded, size: 16, color: Color(0xFF1E4D2B)),
                  label: const Text(
                    'Calibrate Exact Field Boundary Coordinates on Satellite Canvas',
                    style: TextStyle(
                      fontFamily: 'Mukta',
                      fontSize: 12.5,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF1E4D2B),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeaturePill({
    required IconData icon,
    required String label,
    required String val,
    required Color color,
    required Color bg,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(height: 3),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Mukta',
              fontSize: 10,
              fontWeight: FontWeight.w400,
              color: color,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            val,
            style: TextStyle(
              fontFamily: 'Mukta',
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildOutputTile({
    required String label,
    required String value,
    required String sub,
    required IconData icon,
    required Color color,
    required Color bg,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE6E0D2)),
        boxShadow: const [
          BoxShadow(
            color: Color(0xFFE9E2D1),
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 16, color: color),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontFamily: 'Mukta',
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF55655A),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Mukta',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          Text(
            sub,
            style: const TextStyle(
              fontFamily: 'Mukta',
              fontSize: 10.5,
              fontWeight: FontWeight.w400,
              color: Color(0xFF55655A),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
