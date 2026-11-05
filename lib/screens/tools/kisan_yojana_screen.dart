import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../l10n/app_strings.dart';
import '../../theme/app_theme.dart';
import '../claim/crop_loss_claim_screen.dart';

class KisanYojanaScreen extends StatefulWidget {
  const KisanYojanaScreen({Key? key}) : super(key: key);

  @override
  State<KisanYojanaScreen> createState() => _KisanYojanaScreenState();
}

class _KisanYojanaScreenState extends State<KisanYojanaScreen> {
  String _selectedCategory = 'All';
  bool get isHindi => AppLanguage().isHindi;

  final List<Map<String, dynamic>> _schemes = [
    {
      'id': 'pm_kisan',
      'category': 'Income Support',
      'title': 'PM-Kisan Samman Nidhi',
      'sub': '₹6,000 / year Direct Cash Transfer',
      'benefit': '₹2,000 transferred in 3 equal installments directly to bank account via DBT.',
      'eligibility': 'Small & marginal landholding farmer families with cultivable land.',
      'docs': ['Aadhaar Card', 'Land Record (Khatauni/Khasra)', 'Aadhaar-seeded Bank Passbook', 'Active e-KYC'],
      'helpline': '155261 / 1800-115-526',
      'portal': 'pmkisan.gov.in',
      'badge': 'Active · 17th Installment',
      'color': const Color(0xFF1E4D2B),
      'bgColor': const Color(0xFFE2EFDF),
      'icon': Icons.currency_rupee_rounded,
    },
    {
      'id': 'pmfby',
      'category': 'Insurance',
      'title': 'PM Fasal Bima Yojana (PMFBY)',
      'sub': 'Comprehensive Crop Loss Protection',
      'benefit': 'Only 1.5% premium for Rabi, 2% for Kharif. 100% loss compensation for drought, unseasonal rain, hailstorm.',
      'eligibility': 'All farmers growing notified crops (loanee & non-loanee).',
      'docs': ['Sowing Certificate / Patwari Report', 'Land Ownership Slip (LPC / 7/12)', 'Damage Geotagged Photos within 72 hrs'],
      'helpline': '1800-180-1551',
      'portal': 'pmfby.gov.in',
      'badge': 'Report in 72 Hrs',
      'color': const Color(0xFFB03A2E),
      'bgColor': const Color(0xFFFDE8E8),
      'icon': Icons.security_rounded,
    },
    {
      'id': 'pmksy',
      'category': 'Irrigation',
      'title': 'PM Krishi Sinchayee Yojana (Drip & Sprinkler)',
      'sub': '55% to 80% Subsidy on Micro-Irrigation',
      'benefit': 'Saves 40-50% water, increases yield by 30%. Government covers up to 80% cost of drip and sprinkler installation.',
      'eligibility': 'All farmers with verified continuous water source (borewell/pond/well).',
      'docs': ['Land Records (Jamabandi)', 'Electricity/Borewell verification', 'Soil & Water test report'],
      'helpline': '011-23382012',
      'portal': 'pmksy.gov.in',
      'badge': 'Save 50% Water',
      'color': const Color(0xFF18566F),
      'bgColor': const Color(0xFFDDEBF3),
      'icon': Icons.water_drop_outlined,
    },
    {
      'id': 'smam',
      'category': 'Machinery',
      'title': 'SMAM (Farm Machinery Subsidy)',
      'sub': '40% to 50% Subsidy on Tractors & Implements',
      'benefit': 'Subsidies on buying Rotavators, Super Seeders, Laser Land Levellers, Power Tillers, and establishing Custom Hiring Centers.',
      'eligibility': 'Individual farmers, Farmer Producer Organizations (FPOs), Panchayats.',
      'docs': ['Aadhaar', 'Caste Certificate (for additional subsidy)', 'Land papers', 'Bank Passbook'],
      'helpline': '1800-180-1551',
      'portal': 'agrimachinery.nic.in',
      'badge': 'Up to 50% Off',
      'color': const Color(0xFF8A5600),
      'bgColor': const Color(0xFFFCEFD0),
      'icon': Icons.agriculture_rounded,
    },
    {
      'id': 'kcc',
      'category': 'Credit & Loan',
      'title': 'Kisan Credit Card (KCC Loan)',
      'sub': '4% Subsidized Interest Rate Farm Loan',
      'benefit': 'Up to ₹1.60 Lakh collateral-free loan, and up to ₹3 Lakh at 4% subsidized interest with timely yearly repayment.',
      'eligibility': 'Owner cultivators, tenant farmers, sharecroppers, and SHGs.',
      'docs': ['Identity & Address proof', 'Land record verified by Patwari/Tehsildar', 'No-dues certificate'],
      'helpline': '1800-11-22-11 (SBI)',
      'portal': 'myscheme.gov.in',
      'badge': 'Low 4% Interest',
      'color': const Color(0xFF2E7D32),
      'bgColor': const Color(0xFFE8F5E9),
      'icon': Icons.credit_card_rounded,
    },
    {
      'id': 'kusum',
      'category': 'Irrigation',
      'title': 'PM-KUSUM Solar Pump Scheme',
      'sub': '60% to 90% Subsidy for Solar Irrigation',
      'benefit': 'Replace costly diesel pump sets with solar water pumps (3 HP to 10 HP). Farmer pays only 10% of total system cost.',
      'eligibility': 'Farmers, cooperatives, water user associations with farmland requiring irrigation.',
      'docs': ['Farmland Title', 'Source of water certification', 'Aadhaar Card', 'Bank account copy'],
      'helpline': '1800-180-3333',
      'portal': 'pmkusum.mnre.gov.in',
      'badge': 'Zero Diesel Bill',
      'color': const Color(0xFFC98F1C),
      'bgColor': const Color(0xFFFFF7E6),
      'icon': Icons.wb_sunny_rounded,
    },
    {
      'id': 'soil_card',
      'category': 'Income Support',
      'title': 'Soil Health Card Scheme',
      'sub': 'Free 12-Parameter Lab Soil Test',
      'benefit': 'Free testing of soil nutrient health (N, P, K, pH, Zinc, Sulphur) with personalized dosage advisory every 2 years.',
      'eligibility': 'All farm land owners across all states.',
      'docs': ['Khasra Number', 'Representative 500g dry soil sample'],
      'helpline': '1800-180-1551',
      'portal': 'soilhealth.dac.gov.in',
      'badge': 'Free Testing',
      'color': const Color(0xFF55655A),
      'bgColor': const Color(0xFFF6F2E9),
      'icon': Icons.eco_rounded,
    },
  ];

  void _showSchemeModal(Map<String, dynamic> scheme) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(22),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFDDD6C4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: scheme['bgColor'] as Color,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Center(
                      child: Icon(scheme['icon'] as IconData, color: scheme['color'] as Color, size: 24),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          scheme['title'] as String,
                          style: const TextStyle(
                            fontFamily: 'Mukta',
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1B2A21),
                          ),
                        ),
                        Text(
                          scheme['sub'] as String,
                          style: TextStyle(
                            fontFamily: 'Mukta',
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: scheme['color'] as Color,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(color: Color(0xFFEEE8DA)),
              const SizedBox(height: 12),

              // Benefit
              Text(
                isHindi ? 'योजना के लाभ' : 'Scheme Benefits',
                style: TextStyle(fontFamily: 'Mukta', fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1B2A21)),
              ),
              const SizedBox(height: 4),
              Text(
                scheme['benefit'] as String,
                style: const TextStyle(fontFamily: 'Mukta', fontSize: 13, fontWeight: FontWeight.w400, color: Color(0xFF55655A)),
              ),
              const SizedBox(height: 12),

              // Eligibility
              Text(
                isHindi ? 'पात्रता' : 'Who Can Apply',
                style: TextStyle(fontFamily: 'Mukta', fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1B2A21)),
              ),
              const SizedBox(height: 4),
              Text(
                scheme['eligibility'] as String,
                style: const TextStyle(fontFamily: 'Mukta', fontSize: 13, fontWeight: FontWeight.w400, color: Color(0xFF55655A)),
              ),
              const SizedBox(height: 12),

              // Required Documents Checklist
              Text(
                isHindi ? 'जरूरी दस्तावेज' : 'Required Documents',
                style: TextStyle(fontFamily: 'Mukta', fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1B2A21)),
              ),
              const SizedBox(height: 6),
              ...(scheme['docs'] as List<String>).map((doc) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle_rounded, color: Color(0xFF1E4D2B), size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          doc,
                          style: const TextStyle(fontFamily: 'Mukta', fontSize: 12.5, fontWeight: FontWeight.w400, color: Color(0xFF1B2A21)),
                        ),
                      ),
                    ],
                  ),
                );
              }),

              const SizedBox(height: 16),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF1E4D2B),
                        side: const BorderSide(color: Color(0xFF1E4D2B)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: 'Scheme: ${scheme['title']} | Helpline: ${scheme['helpline']} | Portal: https://${scheme['portal']}'));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Helpline & Portal details copied for ${scheme['title']}'),
                            backgroundColor: const Color(0xFF1E4D2B),
                          ),
                        );
                      },
                      icon: const Icon(Icons.call_outlined, size: 18),
                      label: Text(
                        scheme['helpline'] as String,
                        style: const TextStyle(fontFamily: 'Mukta', fontSize: 12.5, fontWeight: FontWeight.w500),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E4D2B),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () {
                        Navigator.pop(ctx);
                        if (scheme['id'] == 'pmfby') {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const CropLossClaimScreen()));
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Opening official portal: https://${scheme['portal']}'),
                              backgroundColor: const Color(0xFF1E4D2B),
                            ),
                          );
                        }
                      },
                      icon: Icon(scheme['id'] == 'pmfby' ? Icons.file_present_rounded : Icons.open_in_new_rounded, size: 18),
                      label: Text(
                        scheme['id'] == 'pmfby' ? 'File Claim Now' : 'Apply on Portal',
                        style: const TextStyle(fontFamily: 'Mukta', fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final lang = AppLanguage();
    final isHindi = lang.isHindi;

    final categories = ['All', 'Income Support', 'Insurance', 'Irrigation', 'Machinery', 'Credit & Loan'];

    final filteredSchemes = _selectedCategory == 'All'
        ? _schemes
        : _schemes.where((s) => s['category'] == _selectedCategory).toList();

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
                          isHindi ? 'सरकारी कृषि योजनाएं व सब्सिडी' : 'GOVERNMENT SCHEMES & SUBSIDIES',
                          style: const TextStyle(
                            fontFamily: 'Mukta',
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.1,
                            color: Color(0xFF3A6B4A),
                          ),
                        ),
                        Text(
                          isHindi ? 'किसान सरकारी योजनाएं' : 'Kisan Schemes Navigator',
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
                    ? 'पीएम किसान, फसल बीमा, ड्रिप सिंचाई और ट्रैक्टर सब्सिडी की पात्रता और आवेदन की पूरी जानकारी।'
                    : 'Verified central and state government schemes, subsidy eligibility, and application document checklists.',
                style: const TextStyle(
                  fontFamily: 'Mukta',
                  fontSize: 13.5,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF55655A),
                ),
              ),

              const SizedBox(height: 16),

              // Kisan Call Center Helpline Banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E4D2B),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0xFF123320),
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.18),
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Icon(Icons.support_agent_rounded, color: Colors.white, size: 22),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isHindi ? 'किसान कॉल सेंटर (टोल फ्री)' : 'Kisan Call Center (Toll-Free)',
                            style: const TextStyle(
                              fontFamily: 'Mukta',
                              fontSize: 14.5,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          const Text(
                            '1800-180-1551 (6:00 AM – 10:00 PM)',
                            style: TextStyle(
                              fontFamily: 'Mukta',
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              color: Color(0xFFD4EAD0),
                            ),
                          ),
                        ],
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        Clipboard.setData(const ClipboardData(text: '18001801551'));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Toll-free 1800-180-1551 copied! Calling...'),
                            backgroundColor: Color(0xFF1E4D2B),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF2B134),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Text(
                          isHindi ? 'कॉल करें' : 'Call Now',
                          style: const TextStyle(
                            fontFamily: 'Mukta',
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1B2A21),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Category Filter Chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: categories.map((cat) {
                    final isSel = _selectedCategory == cat;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: InkWell(
                        onTap: () => setState(() => _selectedCategory = cat),
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                          decoration: BoxDecoration(
                            color: isSel ? const Color(0xFF1E4D2B) : Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isSel ? const Color(0xFF1E4D2B) : const Color(0xFFDDD6C4),
                            ),
                          ),
                          child: Text(
                            cat,
                            style: TextStyle(
                              fontFamily: 'Mukta',
                              fontSize: 13,
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

              const SizedBox(height: 16),

              // Schemes List
              ...filteredSchemes.map((scheme) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: scheme['bgColor'] as Color,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Center(
                                  child: Icon(scheme['icon'] as IconData, color: scheme['color'] as Color, size: 20),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                scheme['category'] as String,
                                style: const TextStyle(
                                  fontFamily: 'Mukta',
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF7A887E),
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                            decoration: BoxDecoration(
                              color: scheme['bgColor'] as Color,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              scheme['badge'] as String,
                              style: TextStyle(
                                fontFamily: 'Mukta',
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: scheme['color'] as Color,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        scheme['title'] as String,
                        style: const TextStyle(
                          fontFamily: 'Mukta',
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1B2A21),
                        ),
                      ),
                      Text(
                        scheme['sub'] as String,
                        style: TextStyle(
                          fontFamily: 'Mukta',
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: scheme['color'] as Color,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        scheme['benefit'] as String,
                        style: const TextStyle(
                          fontFamily: 'Mukta',
                          fontSize: 12.5,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF55655A),
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 12),
                      const Divider(color: Color(0xFFEEE8DA)),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.file_copy_outlined, size: 14, color: Color(0xFF7A887E)),
                              const SizedBox(width: 4),
                              Text(
                                '${(scheme['docs'] as List).length} Documents needed',
                                style: const TextStyle(
                                  fontFamily: 'Mukta',
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w400,
                                  color: Color(0xFF7A887E),
                                ),
                              ),
                            ],
                          ),
                          InkWell(
                            onTap: () => _showSchemeModal(scheme),
                            borderRadius: BorderRadius.circular(10),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              child: Row(
                                children: [
                                  Text(
                                    isHindi ? 'विवरण व आवेदन' : 'Details & Apply',
                                    style: const TextStyle(
                                      fontFamily: 'Mukta',
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF1E4D2B),
                                    ),
                                  ),
                                  const SizedBox(width: 2),
                                  const Icon(Icons.arrow_forward_rounded, size: 14, color: Color(0xFF1E4D2B)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}

