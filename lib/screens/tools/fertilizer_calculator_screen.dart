import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../l10n/app_strings.dart';
import '../../theme/app_theme.dart';

class FertilizerCalculatorScreen extends StatefulWidget {
  const FertilizerCalculatorScreen({Key? key}) : super(key: key);

  @override
  State<FertilizerCalculatorScreen> createState() => _FertilizerCalculatorScreenState();
}

class _FertilizerCalculatorScreenState extends State<FertilizerCalculatorScreen> {
  double _landArea = 2.0;
  String _selectedCrop = 'Wheat';

  // ICAR Agronomic standard nutrient requirements (kg per acre)
  final Map<String, Map<String, dynamic>> _cropFertilizerData = {
    'Wheat': {
      'name': 'Wheat',
      'ureaPerAcre': 2.4, // 45kg bags
      'dapPerAcre': 1.1,  // 50kg bags
      'mopPerAcre': 0.4,  // 50kg bags
      'zincPerAcre': 5.0, // kg
      'basalRatio': '100% DAP + 100% MOP + 1/3 Urea',
      'firstTopDress': '1/3 Urea at 21 days (CRI stage irrigation)',
      'secondTopDress': '1/3 Urea at 45 days (Tillering/Jointing)',
      'proTip': 'Never broadcast Urea on dry soil. Apply just before irrigation or on moist soil in evening.',
    },
    'Mustard': {
      'name': 'Mustard',
      'ureaPerAcre': 1.6,
      'dapPerAcre': 0.9,
      'mopPerAcre': 0.3,
      'zincPerAcre': 8.0, // Sulphur recommended
      'basalRatio': '100% DAP + 100% MOP + 1/2 Urea + Sulphur',
      'firstTopDress': '1/2 Urea at 30 days (First irrigation / Pre-flowering)',
      'secondTopDress': 'Foliar spray of 2% Urea if leaves pale',
      'proTip': 'Sulphur is crucial for mustard oil synthesis. 8-10 kg Sulphur per acre increases oil recovery by 2.5%.',
    },
    'Paddy': {
      'name': 'Paddy / Rice',
      'ureaPerAcre': 2.6,
      'dapPerAcre': 1.2,
      'mopPerAcre': 0.6,
      'zincPerAcre': 10.0,
      'basalRatio': '100% DAP + 50% MOP + 1/3 Urea + Zinc Sulphate',
      'firstTopDress': '1/3 Urea at tillering (20-25 days)',
      'secondTopDress': '1/3 Urea + 50% MOP at panicle initiation (45 days)',
      'proTip': 'Apply Zinc Sulphate at transplanting. Never mix Zinc Sulphate directly with DAP in same bag.',
    },
    'Potato': {
      'name': 'Potato',
      'ureaPerAcre': 3.5,
      'dapPerAcre': 1.8,
      'mopPerAcre': 1.2,
      'zincPerAcre': 10.0,
      'basalRatio': '100% DAP + 50% MOP + 1/2 Urea at planting',
      'firstTopDress': '1/2 Urea + remaining MOP at 30 days during earthing-up',
      'secondTopDress': 'Foliar Potassium Nitrate (13:0:45) at tuber bulking',
      'proTip': 'High potash improves tuber starch and shelf life. Earthing up prevents tuber greening.',
    },
    'Maize': {
      'name': 'Maize / Corn',
      'ureaPerAcre': 2.8,
      'dapPerAcre': 1.3,
      'mopPerAcre': 0.5,
      'zincPerAcre': 8.0,
      'basalRatio': '100% DAP + 100% MOP + 1/3 Urea at sowing',
      'firstTopDress': '1/3 Urea at knee-high stage (30 days)',
      'secondTopDress': '1/3 Urea at tasseling stage (50 days)',
      'proTip': 'Side-dress Urea 10 cm away from plant stems to avoid chemical leaf burn.',
    },
    'Gram': {
      'name': 'Gram / Chickpea',
      'ureaPerAcre': 0.6, // Legume fixes nitrogen
      'dapPerAcre': 0.8,
      'mopPerAcre': 0.3,
      'zincPerAcre': 4.0,
      'basalRatio': '100% DAP + 100% MOP + minimal starter Urea',
      'firstTopDress': 'Foliar spray of 2% Urea at pod initiation',
      'secondTopDress': 'Rhizobium biofertilizer seed treatment before sowing',
      'proTip': 'Chickpea root nodules fix atmospheric nitrogen. Excess urea causes vegetative overgrowth without pods.',
    },
    'Sugarcane': {
      'name': 'Sugarcane',
      'ureaPerAcre': 5.5,
      'dapPerAcre': 2.2,
      'mopPerAcre': 1.6,
      'zincPerAcre': 12.0,
      'basalRatio': '100% DAP + 1/3 MOP + 1/4 Urea in furrows',
      'firstTopDress': '1/4 Urea at 45 days (Tillering)',
      'secondTopDress': '1/2 Urea + 2/3 MOP split between 90 and 120 days',
      'proTip': 'Apply full phosphorus (DAP) at planting in the furrow under sett cuttings for vigorous root development.',
    },
  };

  // Official subsidized indicative rates per bag in India
  static const double pricePerUreaBag = 266.50; // 45 kg bag
  static const double pricePerDapBag = 1350.00; // 50 kg bag
  static const double pricePerMopBag = 1700.00; // 50 kg bag
  static const double pricePerKgZinc = 65.00;

  void _shareSlip() {
    final cropData = _cropFertilizerData[_selectedCrop]!;
    final ureaBags = ((cropData['ureaPerAcre'] as double) * _landArea).ceil();
    final dapBags = ((cropData['dapPerAcre'] as double) * _landArea).ceil();
    final mopBags = ((cropData['mopPerAcre'] as double) * _landArea).ceil();
    final zincKg = (((cropData['zincPerAcre'] as double) * _landArea)).round();
    final totalCost = (ureaBags * pricePerUreaBag) + (dapBags * pricePerDapBag) + (mopBags * pricePerMopBag) + (zincKg * pricePerKgZinc);

    final slip = '''
🌾 BHOOMI KISAN FERTILIZER SLIP
════════════════════════════════════
Crop: ${cropData['name']}
Land Area: ${_landArea.toStringAsFixed(1)} Acre (~${(_landArea * 3.2).toStringAsFixed(1)} Bigha)
Date: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}

REQUIRED FERTILIZER BAGS:
• Urea (45 kg): $ureaBags Bags (~₹${(ureaBags * pricePerUreaBag).round()})
• DAP (50 kg): $dapBags Bags (~₹${(dapBags * pricePerDapBag).round()})
• MOP Potash (50 kg): $mopBags Bags (~₹${(mopBags * pricePerMopBag).round()})
• Micronutrient: $zincKg kg (~₹${(zincKg * pricePerKgZinc).round()})
────────────────────────────────────
Estimated Total Cost: ₹${totalCost.round()}

APPLICATION TIMELINE:
1. Basal: ${cropData['basalRatio']}
2. 1st Top-Dress: ${cropData['firstTopDress']}
3. 2nd Top-Dress: ${cropData['secondTopDress']}

Shared via Bhoomi App
════════════════════════════════════''';

    Clipboard.setData(ClipboardData(text: slip));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          '✓ Fertilizer slip copied! You can paste and send it on WhatsApp to your cooperative/dealer.',
          style: TextStyle(fontFamily: 'Mukta', fontWeight: FontWeight.w500),
        ),
        backgroundColor: Color(0xFF1E4D2B),
        duration: Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lang = AppLanguage();
    final isHindi = lang.isHindi;
    final cropData = _cropFertilizerData[_selectedCrop]!;

    final ureaBags = ((cropData['ureaPerAcre'] as double) * _landArea).ceil();
    final dapBags = ((cropData['dapPerAcre'] as double) * _landArea).ceil();
    final mopBags = ((cropData['mopPerAcre'] as double) * _landArea).ceil();
    final zincKg = (((cropData['zincPerAcre'] as double) * _landArea)).round();

    final estUreaCost = (ureaBags * pricePerUreaBag).round();
    final estDapCost = (dapBags * pricePerDapBag).round();
    final estMopCost = (mopBags * pricePerMopBag).round();
    final estZincCost = (zincKg * pricePerKgZinc).round();
    final totalCost = estUreaCost + estDapCost + estMopCost + estZincCost;

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
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isHindi ? 'खाद व उर्वरक कैलकुलेटर' : 'FERTILIZER & BAG CALCULATOR',
                          style: const TextStyle(
                            fontFamily: 'Mukta',
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.1,
                            color: Color(0xFF3A6B4A),
                          ),
                        ),
                        Text(
                          isHindi ? 'खाद बोरी गणना' : 'Fertilizer Calculator',
                          style: const TextStyle(
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
              Text(
                isHindi
                    ? 'अपनी जमीन और फसल चुनें। यह टूल यूरिया, डीएपी और पोटाश की सही बोरी संख्या और समय बताएगा।'
                    : 'Calculate exact commercial bags of Urea, DAP, and Potash for your land size and crop.',
                style: const TextStyle(
                  fontFamily: 'Mukta',
                  fontSize: 13.5,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF55655A),
                ),
              ),

              const SizedBox(height: 16),

              // 2. Land Size & Crop Selector Card
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
                    // Land Size Title
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          isHindi ? '1. जमीन का आकार' : '1. Land Size',
                          style: const TextStyle(
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

                    // Stepper & Quick Chips
                    Row(
                      children: [
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

                    // Crop Selection Horizontal Chips
                    Text(
                      isHindi ? '2. फसल चुनें' : '2. Select Crop',
                      style: const TextStyle(
                        fontFamily: 'Mukta',
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1B2A21),
                      ),
                    ),
                    const SizedBox(height: 10),

                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      child: Row(
                        children: _cropFertilizerData.keys.map((cropKey) {
                          final isSel = _selectedCrop == cropKey;
                          final cData = _cropFertilizerData[cropKey]!;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: InkWell(
                              onTap: () => setState(() => _selectedCrop = cropKey),
                              borderRadius: BorderRadius.circular(14),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                decoration: BoxDecoration(
                                  color: isSel ? const Color(0xFF1E4D2B) : Colors.white,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: isSel ? const Color(0xFF1E4D2B) : const Color(0xFFDDD6C4),
                                    width: isSel ? 1.5 : 1,
                                  ),
                                ),
                                child: Text(
                                  cData['name'].toString().split('(')[0].trim(),
                                  style: TextStyle(
                                    fontFamily: 'Mukta',
                                    fontSize: 13.5,
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
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // 3. Commercial Bags Requirement (Direct Farmer Need)
              Text(
                isHindi ? 'आवश्यक खाद बोरियां (Commercial Bags)' : 'Required Commercial Bags',
                style: const TextStyle(
                  fontFamily: 'Mukta',
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1B2A21),
                ),
              ),
              const SizedBox(height: 10),

              Row(
                children: [
                  Expanded(
                    child: _buildBagTile(
                      title: isHindi ? 'यूरिया (Urea)' : 'Urea',
                      spec: '45 kg bag · 46% N',
                      bags: ureaBags,
                      cost: estUreaCost,
                      color: const Color(0xFF1E4D2B),
                      bgColor: const Color(0xFFE2EFDF),
                      icon: Icons.inventory_2_rounded,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildBagTile(
                      title: isHindi ? 'डीएपी (DAP)' : 'DAP',
                      spec: '50 kg bag · 18:46:0',
                      bags: dapBags,
                      cost: estDapCost,
                      color: const Color(0xFF8A5600),
                      bgColor: const Color(0xFFFCEFD0),
                      icon: Icons.grain_rounded,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _buildBagTile(
                      title: isHindi ? 'पोटाश (MOP)' : 'MOP Potash',
                      spec: '50 kg bag · 60% K₂O',
                      bags: mopBags,
                      cost: estMopCost,
                      color: const Color(0xFF18566F),
                      bgColor: const Color(0xFFDDEBF3),
                      icon: Icons.scatter_plot_rounded,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildBagTile(
                      title: 'Zinc / Micronutrient',
                      spec: 'Secondary Dose (kg)',
                      bags: zincKg,
                      isUnitKg: true,
                      cost: estZincCost,
                      color: const Color(0xFF6B3A82),
                      bgColor: const Color(0xFFF2E6F7),
                      icon: Icons.science_outlined,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              // 4. Split Application Schedule (When & How to Apply)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
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
                      children: [
                        const Icon(Icons.schedule_rounded, color: Color(0xFF1E4D2B), size: 20),
                        const SizedBox(width: 8),
                        Text(
                          isHindi ? 'खाद देने का सही समय व तरीका' : 'Application Split & Timing',
                          style: const TextStyle(
                            fontFamily: 'Mukta',
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1B2A21),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    _buildScheduleRow(
                      '1',
                      isHindi ? 'बुवाई के समय (Basal Dose)' : 'Basal Dose (At Sowing)',
                      cropData['basalRatio'],
                      const Color(0xFF1E4D2B),
                    ),
                    const SizedBox(height: 10),
                    _buildScheduleRow(
                      '2',
                      isHindi ? 'पहली सिंचाई / टॉप-ड्रेस' : '1st Top-Dress',
                      cropData['firstTopDress'],
                      const Color(0xFF18566F),
                    ),
                    const SizedBox(height: 10),
                    _buildScheduleRow(
                      '3',
                      isHindi ? 'दूसरी खुराक (2nd Top-Dress)' : '2nd Top-Dress',
                      cropData['secondTopDress'],
                      const Color(0xFF8A5600),
                    ),

                    const SizedBox(height: 14),
                    const Divider(color: Color(0xFFEEE8DA)),
                    const SizedBox(height: 8),

                    // Agronomist Pro-Tip
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.lightbulb_outline_rounded, color: Color(0xFFF2B134), size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            cropData['proTip'],
                            style: const TextStyle(
                              fontFamily: 'Mukta',
                              fontSize: 12.5,
                              fontWeight: FontWeight.w400,
                              color: Color(0xFF55655A),
                              height: 1.35,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // 5. Total Cost Summary & Copy Dealer Slip
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFFE2EFDF),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: const Color(0xFFCFE5CA)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          isHindi ? 'अनुमानित कुल खाद खर्च' : 'Estimated Fertilizer Budget',
                          style: const TextStyle(
                            fontFamily: 'Mukta',
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1E4D2B),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            'Subsidized MRP',
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
                    const SizedBox(height: 8),
                    Text(
                      '₹$totalCost',
                      style: const TextStyle(
                        fontFamily: 'Mukta',
                        fontSize: 28,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1E4D2B),
                        height: 1.1,
                      ),
                    ),
                    Text(
                      isHindi
                          ? 'कुल $_landArea एकड़ जमीन के लिए (यूरिया ₹$estUreaCost + डीएपी ₹$estDapCost + पोटाश ₹$estMopCost + जिंक ₹$estZincCost)'
                          : 'For $_landArea acres total (Urea ₹$estUreaCost + DAP ₹$estDapCost + MOP ₹$estMopCost + Micronutrient ₹$estZincCost)',
                      style: const TextStyle(
                        fontFamily: 'Mukta',
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF55655A),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // 6. Action Button: Copy Dealer Slip (खाद पर्ची)
              GestureDetector(
                onTap: _shareSlip,
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
                        const Icon(Icons.receipt_long_rounded, color: Colors.white, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          isHindi ? 'खाद दुकान पर्ची कॉपी करें (WhatsApp शेयर)' : 'Copy Dealer Slip for WhatsApp →',
                          style: const TextStyle(
                            fontFamily: 'Mukta',
                            fontSize: 15.5,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
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
    );
  }

  Widget _buildBagTile({
    required String title,
    required String spec,
    required int bags,
    bool isUnitKg = false,
    required int cost,
    required Color color,
    required Color bgColor,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
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
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Icon(icon, color: color, size: 18),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFF6F2E9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '~₹$cost',
                  style: const TextStyle(
                    fontFamily: 'Mukta',
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1B2A21),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            '$bags ${isUnitKg ? 'kg' : (bags == 1 ? 'Bag' : 'Bags')}',
            style: const TextStyle(
              fontFamily: 'Mukta',
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1B2A21),
              height: 1.1,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: TextStyle(
              fontFamily: 'Mukta',
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
          Text(
            spec,
            style: const TextStyle(
              fontFamily: 'Mukta',
              fontSize: 11,
              fontWeight: FontWeight.w400,
              color: Color(0xFF7A887E),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleRow(String stepNum, String title, String desc, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              stepNum,
              style: const TextStyle(
                fontFamily: 'Mukta',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontFamily: 'Mukta',
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1B2A21),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                desc,
                style: const TextStyle(
                  fontFamily: 'Mukta',
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF55655A),
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

