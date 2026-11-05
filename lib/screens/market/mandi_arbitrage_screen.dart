import 'package:flutter/material.dart';
import '../../l10n/app_strings.dart';
import '../../theme/app_theme.dart';

/// Smart Mandi Transport & Profit Arbitrage Calculator
/// Solves the real dilemma of Indian farmers: factoring in diesel transport fare
/// and mandi taxes to find which mandi yields the absolute highest TAKE-HOME cash.
class MandiArbitrageScreen extends StatefulWidget {
  const MandiArbitrageScreen({super.key});

  @override
  State<MandiArbitrageScreen> createState() => _MandiArbitrageScreenState();
}

class _MandiArbitrageScreenState extends State<MandiArbitrageScreen> {
  String _selectedCrop = 'Mustard';
  double _quantityQuintals = 15.0;
  String _selectedVehicle = 'Tractor Trolley'; // 'Tractor Trolley', 'Pickup 407', 'Tempo'
  bool get isHindi => AppLanguage().isHindi;

  final Map<String, Map<String, dynamic>> _cropData = {
    'Mustard': {
      'daltonganj': 6200.0,
      'garhwa': 6280.0,
      'ranchi': 6450.0,
    },
    'Wheat': {
      'daltonganj': 2350.0,
      'garhwa': 2380.0,
      'ranchi': 2490.0,
    },
    'Ashwagandha': {
      'daltonganj': 28500.0,
      'garhwa': 29200.0,
      'ranchi': 31000.0,
    },
    'Potato': {
      'daltonganj': 1400.0,
      'garhwa': 1450.0,
      'ranchi': 1580.0,
    },
  };

  final Map<String, double> _vehicleRatePerKm = {
    'Tractor Trolley': 18.0,
    'Pickup 407': 14.0,
    'Tempo': 9.0,
  };

  final List<Map<String, dynamic>> _mandis = [
    {'name': 'Daltonganj APMC', 'hi': 'डाल्टनगंज मुख्य मंडी', 'distanceKm': 12.0, 'key': 'daltonganj'},
    {'name': 'Garhwa APMC', 'hi': 'गढ़वा कृषि मंडी', 'distanceKm': 38.0, 'key': 'garhwa'},
    {'name': 'Ranchi APMC', 'hi': 'राँची थोक मंडी', 'distanceKm': 165.0, 'key': 'ranchi'},
  ];

  void _showSetAlertModal() {
    final isHindi = AppLanguage().isHindi;
    final alertPriceCtrl = TextEditingController(text: '6300');
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFDDD6C4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                isHindi ? 'भाव चेतावनी सेट करें' : 'Set Target Price Alert',
                style: TextStyle(
                  fontFamily: 'Mukta',
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                isHindi ? 'जब $_selectedCrop आपके लक्षित भाव पर पहुंचेगा, आपको तुरंत SMS मिलेगा।' : 'Receive an instant SMS when $_selectedCrop reaches your target selling price.',
                style: const TextStyle(fontFamily: 'Mukta', fontSize: 13, color: AppColors.textMuted),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: alertPriceCtrl,
                keyboardType: TextInputType.number,
                style: const TextStyle(fontFamily: 'Mukta', fontSize: 20, fontWeight: FontWeight.w600),
                decoration: InputDecoration(
                  labelText: isHindi ? 'लक्षित भाव (Target Rate ₹/Quintal)' : 'Target Rate (₹/Quintal)',
                  prefixText: '₹ ',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
              const SizedBox(height: 18),
              GestureDetector(
                onTap: () {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        isHindi ? '✓ भाव अलर्ट सेट: जब $_selectedCrop ₹${alertPriceCtrl.text}/qtl पहुंचेगा, आपको SMS मिलेगा!' : '✓ Target alert set: You will receive an SMS when $_selectedCrop reaches ₹${alertPriceCtrl.text}/qtl!',
                        style: const TextStyle(fontFamily: 'Mukta', fontWeight: FontWeight.w500),
                      ),
                      backgroundColor: AppColors.primaryGreen,
                    ),
                  );
                },
                child: Container(
                  width: double.infinity,
                  height: 48,
                  decoration: AppStyles.primaryButtonBox,
                  child: Center(
                    child: Text(
                      isHindi ? 'अलर्ट चालू करें' : 'Activate Price Alert',
                      style: TextStyle(fontFamily: 'Mukta', fontSize: 15, fontWeight: FontWeight.w500, color: Colors.white),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isHindi = AppLanguage().isHindi;
    final cropRates = _cropData[_selectedCrop]!;
    final ratePerKm = _vehicleRatePerKm[_selectedVehicle]!;

    // Compute net profit for each mandi
    final List<Map<String, dynamic>> calculated = _mandis.map((m) {
      final key = m['key'] as String;
      final rate = cropRates[key] as double;
      final distance = m['distanceKm'] as double;

      final grossEarnings = rate * _quantityQuintals;
      // Round trip fuel / transport calculation
      final transportCost = distance * 2 * ratePerKm;
      final mandiTax = grossEarnings * 0.01; // 1% APMC cess
      final netTakeHome = grossEarnings - transportCost - mandiTax;

      return {
        'name': m['name'],
        'hi': m['hi'],
        'distanceKm': distance,
        'rate': rate,
        'gross': grossEarnings,
        'transport': transportCost,
        'net': netTakeHome,
      };
    }).toList();

    // Find best net mandi
    calculated.sort((a, b) => (b['net'] as double).compareTo(a['net'] as double));
    final bestMandi = calculated.first;

    return Scaffold(
      backgroundColor: AppColors.creamBg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppStyles.pagePadding(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: AppStyles.backButtonBox,
                      child: const Center(
                        child: Icon(Icons.arrow_back_rounded, color: AppColors.textDark, size: 20),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('SMART MANDI ARBITRAGE', style: AppStyles.kicker),
                      Text(
                        isHindi ? 'मंडी मुनाफा व भाड़ा कैलकुलेटर' : 'Mandi Transport & Profit Calc',
                        style: const TextStyle(
                          fontFamily: 'Mukta',
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDark,
                          height: 1.1,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // 1. Selector Section: Crop, Quantity & Vehicle
              Container(
                padding: const EdgeInsets.all(16),
                decoration: AppStyles.cardBox,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isHindi ? 'फ़सल व मात्रा चुनें:' : 'Select Crop & Quantity:',
                      style: TextStyle(fontFamily: 'Mukta', fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textMuted),
                    ),
                    const SizedBox(height: 8),

                    // Crop buttons
                    Row(
                      children: _cropData.keys.map((c) {
                        final isSel = _selectedCrop == c;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: GestureDetector(
                            onTap: () => setState(() => _selectedCrop = c),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: isSel ? AppColors.primaryGreen : AppColors.creamBg,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: isSel ? AppColors.primaryGreen : const Color(0xFFDDD6C4)),
                              ),
                              child: Text(
                                c,
                                style: TextStyle(
                                  fontFamily: 'Mukta',
                                  fontSize: 12.5,
                                  fontWeight: isSel ? FontWeight.w500 : FontWeight.w400,
                                  color: isSel ? Colors.white : AppColors.textDark,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 14),

                    // Quantity Stepper Slider
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          isHindi ? 'बिक्री मात्रा:' : 'Harvest Quantity:',
                          style: TextStyle(fontFamily: 'Mukta', fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textDark),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.mintTint,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            isHindi ? '${_quantityQuintals.toStringAsFixed(0)} क्विंटल' : '${_quantityQuintals.toStringAsFixed(0)} Quintals',
                            style: const TextStyle(
                              fontFamily: 'Mukta',
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: AppColors.primaryGreen,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Slider(
                      value: _quantityQuintals,
                      min: 2,
                      max: 60,
                      divisions: 58,
                      activeColor: AppColors.primaryGreen,
                      inactiveColor: const Color(0xFFDDD6C4),
                      onChanged: (val) => setState(() => _quantityQuintals = val),
                    ),

                    // Transport Vehicle
                    Text(
                      isHindi ? 'परिवहन वाहन:' : 'Transport Vehicle Mode:',
                      style: TextStyle(fontFamily: 'Mukta', fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textMuted),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: _vehicleRatePerKm.keys.map((v) {
                        final isSel = _selectedVehicle == v;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(v, style: TextStyle(fontFamily: 'Mukta', fontSize: 12, fontWeight: isSel ? FontWeight.w500 : FontWeight.w400)),
                            selected: isSel,
                            selectedColor: AppColors.mintTint,
                            onSelected: (val) => setState(() => _selectedVehicle = v),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // 2. Winner Recommendation Insight Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF2B134).withOpacity(0.18),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.cardGold, width: 1.5),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.stars_rounded, color: Color(0xFF8A5600), size: 28),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isHindi ? 'सर्वाधिक बचत सिफारिश' : 'Best Take-Home Recommendation',
                            style: TextStyle(
                              fontFamily: 'Mukta',
                              fontSize: 14.5,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF8A5600),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            isHindi ? '${bestMandi['hi']} में बेचने पर आपको डीजल व भाड़ा काटकर शुद्ध ₹${(bestMandi['net'] as double).toStringAsFixed(0)} घर मिलेगा।' : 'Selling at ${bestMandi['name']} gives the highest net return of ₹${(bestMandi['net'] as double).toStringAsFixed(0)} after fuel and transport.',
                            style: const TextStyle(
                              fontFamily: 'Mukta',
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                              color: Color(0xFF5C3D00),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // 3. Comparison Cards
              Text(
                isHindi ? 'मंडीवार शुद्ध मुनाफा तुलना' : 'Mandi-wise Net Return Comparison',
                style: TextStyle(
                  fontFamily: 'Mukta',
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 8),

              ...calculated.map((item) {
                final isWinner = item == bestMandi;
                final net = item['net'] as double;
                final gross = item['gross'] as double;
                final transport = item['transport'] as double;
                final rate = item['rate'] as double;
                final dist = item['distanceKm'] as double;

                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: isWinner ? AppColors.primaryGreen : AppColors.borderLight,
                      width: isWinner ? 1.8 : 1.0,
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Text(
                                item['name'] as String,
                                style: const TextStyle(
                                  fontFamily: 'Mukta',
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textDark,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text('(${dist.toStringAsFixed(0)} km)', style: const TextStyle(fontFamily: 'Mukta', fontSize: 12, color: AppColors.textMuted)),
                            ],
                          ),
                          if (isWinner)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.mintTint,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                isHindi ? 'सर्वोत्तम बचत ✓' : 'Best Return ✓',
                                style: const TextStyle(fontFamily: 'Mukta', fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.primaryGreen),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(isHindi ? 'मंडी भाव: ₹${rate.toStringAsFixed(0)}/qtl' : 'Mandi Rate: ₹${rate.toStringAsFixed(0)}/qtl', style: const TextStyle(fontFamily: 'Mukta', fontSize: 12.5, color: AppColors.textMuted)),
                              Text(isHindi ? 'सकल मूल्य: ₹${gross.toStringAsFixed(0)}' : 'Gross Value: ₹${gross.toStringAsFixed(0)}', style: const TextStyle(fontFamily: 'Mukta', fontSize: 12.5, color: AppColors.textMuted)),
                              Text(isHindi ? 'डीजल भाड़ा: -₹${transport.toStringAsFixed(0)}' : 'Fuel / Freight: -₹${transport.toStringAsFixed(0)}', style: const TextStyle(fontFamily: 'Mukta', fontSize: 12, color: Color(0xFFB03A2E))),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(isHindi ? 'शुद्ध जेब में (Net Cash)' : 'Net Cash in Hand', style: const TextStyle(fontFamily: 'Mukta', fontSize: 11, color: AppColors.textMuted)),
                              Text(
                                '₹${net.toStringAsFixed(0)}',
                                style: TextStyle(
                                  fontFamily: 'Mukta',
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  color: isWinner ? AppColors.primaryGreen : AppColors.textDark,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }),

              const SizedBox(height: 10),

              // Target Alert Action
              GestureDetector(
                onTap: _showSetAlertModal,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColors.primaryGreen, width: 1.2),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.notifications_active_outlined, color: AppColors.primaryGreen, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        isHindi ? 'इस फ़सल पर भाव अलर्ट सेट करें' : 'Set Target Price Alert for this Crop →',
                        style: const TextStyle(
                          fontFamily: 'Mukta',
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.primaryGreen,
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

