import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../l10n/app_strings.dart';
import '../services/mandi_service.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';
import 'market/mandi_arbitrage_screen.dart';

class MarketScreen extends StatefulWidget {
  final VoidCallback? onBackToHome;
  const MarketScreen({Key? key, this.onBackToHome}) : super(key: key);

  @override
  State<MarketScreen> createState() => _MarketScreenState();
}

class _MarketScreenState extends State<MarketScreen> {
  final MandiService _mandiService = MandiService();
  final StorageService _storage = StorageService();

  String _selectedCrop = 'Ashwagandha';
  int _activeTab = 0; // 0: Mandi Prices, 1: Sell My Crop, 2: Verified Buyers
  List<MandiPrice> _prices = [];
  bool _isLoading = false;
  bool get isHindi => AppLanguage().isHindi;

  @override
  void initState() {
    super.initState();
    _fetchPrices();
    _storage.addListener(_onStorageChanged);
  }

  @override
  void dispose() {
    _storage.removeListener(_onStorageChanged);
    super.dispose();
  }

  void _onStorageChanged() {
    if (mounted) setState(() {});
  }

  void _showPostBatchModal(bool isHindi) {
    final profile = _storage.getProfile();
    String selectedCrop = 'Yellow Mustard';
    final qtyCtrl = TextEditingController();
    final priceCtrl = TextEditingController();
    final userLoc = [profile.village, profile.district].where((s) => s.isNotEmpty).join(', ');
    final locCtrl = TextEditingController(text: userLoc);
    final userPhone = profile.phone.replaceAll('+91 ', '').replaceAll('+91', '').trim();
    final phoneCtrl = TextEditingController(text: userPhone);

    final availableCrops = ['Yellow Mustard', 'Sharbati Wheat', 'Potato', 'Gram / Chickpea', 'Paddy / Rice', 'Maize'];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (modalCtx, setModalState) {
            final bottomInset = MediaQuery.of(modalCtx).viewInsets.bottom;
            return Container(
              padding: EdgeInsets.fromLTRB(20, 20, 20, bottomInset > 0 ? bottomInset + 20 : 28),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: SingleChildScrollView(
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
                    Text(
                      isHindi ? 'फसल उपज बिक्री हेतु लिस्ट करें' : 'Post Crop Batch for Sale',
                      style: const TextStyle(
                        fontFamily: 'Mukta',
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1B2A21),
                      ),
                    ),
                    Text(
                      isHindi
                          ? 'सीधे सत्यापित व्यापारियों और मिल मालिकों से संपर्क पाएं'
                          : 'Receive direct inquiry calls from verified millers & traders',
                      style: const TextStyle(
                        fontFamily: 'Mukta',
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF55655A),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Crop Selection
                    Text(
                      isHindi ? 'फसल चुनें' : 'Select Crop',
                      style: const TextStyle(fontFamily: 'Mukta', fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1B2A21)),
                    ),
                    const SizedBox(height: 6),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      child: Row(
                        children: availableCrops.map((c) {
                          final isSel = selectedCrop == c;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: InkWell(
                              onTap: () => setModalState(() => selectedCrop = c),
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: isSel ? const Color(0xFF1E4D2B) : const Color(0xFFF6F2E9),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: isSel ? const Color(0xFF1E4D2B) : const Color(0xFFDDD6C4)),
                                ),
                                child: Text(
                                  c,
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

                    const SizedBox(height: 14),

                    // Quantity & Price
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isHindi ? 'मात्रा (क्विंटल)' : 'Quantity (Quintals)',
                                style: const TextStyle(fontFamily: 'Mukta', fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1B2A21)),
                              ),
                              const SizedBox(height: 6),
                              TextField(
                                controller: qtyCtrl,
                                keyboardType: TextInputType.number,
                                style: const TextStyle(fontFamily: 'Mukta', fontSize: 14),
                                decoration: InputDecoration(
                                  hintText: 'e.g. 40',
                                  suffixText: 'Qtl',
                                  filled: true,
                                  fillColor: const Color(0xFFF6F2E9),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isHindi ? 'अपेक्षित भाव (₹/Qtl)' : 'Target Price (₹/Qtl)',
                                style: const TextStyle(fontFamily: 'Mukta', fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1B2A21)),
                              ),
                              const SizedBox(height: 6),
                              TextField(
                                controller: priceCtrl,
                                keyboardType: TextInputType.number,
                                style: const TextStyle(fontFamily: 'Mukta', fontSize: 14),
                                decoration: InputDecoration(
                                  hintText: 'e.g. 6200',
                                  prefixText: '₹ ',
                                  filled: true,
                                  fillColor: const Color(0xFFF6F2E9),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    // Location
                    Text(
                      isHindi ? 'स्थान / मंडी (Pickup Location)' : 'Pickup Location / Mandi',
                      style: const TextStyle(fontFamily: 'Mukta', fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1B2A21)),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: locCtrl,
                      style: const TextStyle(fontFamily: 'Mukta', fontSize: 14),
                      decoration: InputDecoration(
                        hintText: isHindi ? 'उदा. गांव का नाम / नजदीकी मंडी' : 'e.g. Village or nearest mandi',
                        filled: true,
                        fillColor: const Color(0xFFF6F2E9),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      ),
                    ),

                    const SizedBox(height: 14),

                    // Contact Phone
                    Text(
                      isHindi ? 'संपर्क मोबाइल नंबर (Contact Number)' : 'Contact Phone Number',
                      style: const TextStyle(fontFamily: 'Mukta', fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1B2A21)),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: phoneCtrl,
                      keyboardType: TextInputType.phone,
                      style: const TextStyle(fontFamily: 'Mukta', fontSize: 14),
                      decoration: InputDecoration(
                        hintText: 'e.g. 9876543210',
                        prefixText: '+91 ',
                        filled: true,
                        fillColor: const Color(0xFFF6F2E9),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      ),
                    ),

                    const SizedBox(height: 18),

                    // Publish Button
                    GestureDetector(
                      onTap: () async {
                        if (qtyCtrl.text.trim().isEmpty || priceCtrl.text.trim().isEmpty) return;
                        final newListing = {
                          'id': DateTime.now().millisecondsSinceEpoch.toString(),
                          'crop': selectedCrop,
                          'quantity': '${qtyCtrl.text.trim()} Quintals',
                          'price': '₹${priceCtrl.text.trim()} / Qtl',
                          'location': locCtrl.text.trim().isNotEmpty
                              ? locCtrl.text.trim()
                              : (profile.village.isNotEmpty ? profile.village : 'Local Mandi'),
                          'date': 'Today',
                          'phone': phoneCtrl.text.trim(),
                        };
                        await _storage.addMarketListing(newListing);
                        Navigator.pop(ctx);
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                isHindi ? '✓ आपकी $selectedCrop की लिस्टिंग लाइव हो गई है!' : '✓ $selectedCrop batch listed successfully!',
                                style: const TextStyle(fontFamily: 'Mukta'),
                              ),
                              backgroundColor: const Color(0xFF1E4D2B),
                            ),
                          );
                        }
                      },
                      child: Container(
                        width: double.infinity,
                        height: 48,
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
                        child: Center(
                          child: Text(
                            isHindi ? 'लिस्टिंग प्रकाशित करें (Publish)' : 'Publish Batch For Sale →',
                            style: const TextStyle(
                              fontFamily: 'Mukta',
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _shareListing(Map<String, dynamic> item) {
    final text = '🌾 Crop For Sale on Bhoomi App: ${item['crop']}, Quantity: ${item['quantity']}, Expected Price: ${item['price']}, Location: ${item['location']}, Contact: ${item['phone']}';
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Listing copied! You can paste and share it on WhatsApp trader groups.'),
        backgroundColor: Color(0xFF1E4D2B),
      ),
    );
  }

  Future<void> _fetchPrices() async {
    setState(() => _isLoading = true);
    final p = await _mandiService.getPricesForCrop(_selectedCrop);
    if (mounted) {
      setState(() {
        _prices = p;
        _isLoading = false;
      });
    }
  }

  void _onSelectCrop(String crop) {
    setState(() {
      _selectedCrop = crop;
    });
    _fetchPrices();
  }

  void _showCropPicker() {
    final crops = _mandiService.getAvailableCrops();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Text(
                    isHindi ? 'फसल चुनें' : 'Select Crop',
                    style: const TextStyle(
                      fontFamily: 'Mukta',
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark,
                    ),
                  ),
                ),
                const Divider(),
                ...crops.map((c) {
                  final isSel = c == _selectedCrop;
                  return ListTile(
                    leading: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: isSel ? AppColors.mintTint : const Color(0xFFF3EFE4),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.grass_rounded,
                        color: isSel ? AppColors.primaryGreen : AppColors.textMuted,
                        size: 20,
                      ),
                    ),
                    title: Text(
                      c,
                      style: TextStyle(
                        fontFamily: 'Mukta',
                        fontSize: 16.5,
                        fontWeight: isSel ? FontWeight.w500 : FontWeight.w400,
                        color: isSel ? AppColors.primaryGreen : AppColors.textDark,
                      ),
                    ),
                    trailing: isSel
                        ? const Icon(Icons.check_circle_rounded, color: AppColors.primaryGreen)
                        : null,
                    onTap: () {
                      Navigator.pop(ctx);
                      _onSelectCrop(c);
                    },
                  );
                }).toList(),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final lang = AppLanguage();
    final isHindi = lang.isHindi;

    // Derived top price
    final double benchmarkPrice = _prices.isNotEmpty ? _prices.first.modalPrice.toDouble() : 6000.0;

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
              // 1. Header with back button
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: widget.onBackToHome ?? () => Navigator.maybePop(context),
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
                          isHindi ? 'मंडी भाव और बाजार' : 'KNOW YOUR MARKET',
                          style: const TextStyle(
                            fontFamily: 'Mukta',
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.8,
                            color: Color(0xFF3A6B4A),
                          ),
                        ),
                        Text(
                          isHindi ? 'बाजार भाव' : 'Market Prices',
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
                isHindi ? 'बेचने से पहले अनुमानित कीमतों की तुलना करें।' : 'Compare indicative prices before selling.',
                style: const TextStyle(
                  fontFamily: 'Mukta',
                  fontSize: 14.5,
                  color: AppColors.textMuted, fontWeight: FontWeight.w400,
                ),
              ),

              const SizedBox(height: 12),

              // 2. Sub Tabs (Mandi Prices, Sell My Crop, Verified Buyers)
              Row(
                children: [
                  _buildSubTab(
                    title: isHindi ? 'मंडी भाव' : 'Mandi Prices',
                    index: 0,
                    flex: 12,
                  ),
                  const SizedBox(width: 8),
                  _buildSubTab(
                    title: isHindi ? 'फसल बेचें' : 'Sell My Crop',
                    index: 1,
                    flex: 10,
                  ),
                  const SizedBox(width: 8),
                  _buildSubTab(
                    title: isHindi ? 'सत्यापित खरीदार' : 'Verified Buyers',
                    index: 2,
                    flex: 11,
                  ),
                ],
              ),

              const SizedBox(height: 14),

              if (_activeTab == 0) ...[
                // 3. Select crop label
                Text(
                  isHindi ? 'फसल चुनें' : 'Select crop',
                  style: const TextStyle(
                    fontFamily: 'Mukta',
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textMuted,
                  ),
                ),

                const SizedBox(height: 6),

                // 4. Crop selector button (.c, height: 60px)
                GestureDetector(
                  onTap: _showCropPicker,
                  child: Container(
                    height: 60,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: AppColors.borderLight, width: 1), // #E6E0D2
                      boxShadow: const [
                        BoxShadow(
                          color: AppColors.cardShadow, // #E9E2D1
                          offset: Offset(0, 3),
                          blurRadius: 0,
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        // Crop icon squircle (.k, #E2EFDF)
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.mintTint, // #E2EFDF
                            borderRadius: BorderRadius.circular(13),
                          ),
                          child: Center(
                            child: SizedBox(
                              width: 26,
                              height: 26,
                              child: CustomPaint(
                                painter: _CropSproutPainter(),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _selectedCrop,
                            style: const TextStyle(
                              fontFamily: 'Mukta',
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textDark,
                            ),
                          ),
                        ),
                        const Icon(
                          Icons.keyboard_arrow_down_rounded,
                          size: 24,
                          color: AppColors.textDark,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // 5. Hero Price Card (height: 128px, radius: 26px, bg: #1E4D2B, shadow: 0 4px 0 #123320)
                Container(
                  height: 128,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen, // #1E4D2B
                    borderRadius: BorderRadius.circular(26),
                    boxShadow: const [
                      BoxShadow(
                        color: AppColors.primaryDark, // #123320
                        offset: Offset(0, 4),
                        blurRadius: 0,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(26),
                    child: Stack(
                      children: [
                        // Coin SVG Graphic on the right
                        Positioned(
                          right: 0,
                          top: 0,
                          bottom: 0,
                          width: 140,
                          child: CustomPaint(
                            painter: _HeroCoinPainter(),
                          ),
                        ),
                        // Text on left
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isHindi ? 'अनुमानित बाजार भाव' : 'ILLUSTRATIVE PRICE',
                                style: TextStyle(
                                  fontFamily: 'Mukta',
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w400,
                                  letterSpacing: 0.8,
                                  color: Colors.white.withOpacity(0.85),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '\u20B9${benchmarkPrice.round()}',
                                style: const TextStyle(
                                  fontFamily: 'Mukta',
                                  fontSize: 44,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                  height: 1.1,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                isHindi ? 'प्रति क्विंटल · सांकेतिक केवल' : 'Per quintal · Sample only',
                                style: const TextStyle(
                                  fontFamily: 'Mukta',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // 5.5 SMART MANDI DIESEL & TRANSPORT PROFIT CALCULATOR
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const MandiArbitrageScreen()),
                    );
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.mintTint,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFC3DFC0), width: 1.2),
                      boxShadow: const [
                        BoxShadow(
                          color: AppColors.cardShadow,
                          offset: Offset(0, 3),
                          blurRadius: 0,
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppColors.primaryGreen,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Center(
                            child: Icon(Icons.calculate_outlined, color: Colors.white, size: 24),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    isHindi ? 'मंडी मुनाफा व भाड़ा कैलकुलेटर' : 'Mandi Transport & Profit Calc',
                                    style: const TextStyle(
                                      fontFamily: 'Mukta',
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.primaryGreen,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                    decoration: BoxDecoration(
                                      color: AppColors.cardGold,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      isHindi ? 'स्मार्ट टूल' : 'Smart Tool',
                                      style: const TextStyle(fontFamily: 'Mukta', fontSize: 10, fontWeight: FontWeight.w500, color: Color(0xFF5C3D00)),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                isHindi
                                    ? 'ट्रैक्टर डीजल खर्च काटकर पता करें किस मंडी में सबसे ज्यादा शुद्ध बचत होगी।'
                                    : 'Calculate take-home cash after tractor diesel & transport costs.',
                                style: const TextStyle(
                                  fontFamily: 'Mukta',
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right_rounded, color: AppColors.primaryGreen),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // 6. Section: Nearby markets
                Text(
                  isHindi ? 'निकटतम मंडियां' : 'Nearby markets',
                  style: const TextStyle(
                    fontFamily: 'Mukta',
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                  ),
                ),

                const SizedBox(height: 8),

                // 7. Markets Container (.c, padding: 2px 14px)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
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
                      if (_prices.isNotEmpty)
                        ..._prices.map((p) {
                          final isHighest = p == _prices.reduce((curr, next) => curr.modalPrice > next.modalPrice ? curr : next);
                          final isLast = p == _prices.last;
                          return _buildMarketRow(
                            name: p.mandiName,
                            distance: '${p.distance} · ${p.district}',
                            price: '\u20B9${p.modalPrice}',
                            isHighest: isHighest,
                            showDivider: !isLast,
                          );
                        }).toList()
                      else ...[
                        // Market Item 1: Daltonganj Mandi
                        _buildMarketRow(
                          name: isHindi ? 'डाल्टनगंज मंडी' : 'Daltonganj Mandi',
                          distance: isHindi ? '18 किमी · पलामू' : '18 km · Palamu',
                          price: '\u20B96000',
                          isHighest: false,
                          showDivider: true,
                        ),
                        // Market Item 2: Garhwa Mandi
                        _buildMarketRow(
                          name: isHindi ? 'गढ़वा मंडी' : 'Garhwa Mandi',
                          distance: isHindi ? '34 किमी · गढ़वा' : '34 km · Garhwa',
                          price: '\u20B95800',
                          isHighest: false,
                          showDivider: true,
                        ),
                        // Market Item 3: Ranchi Regional Hub (Highest)
                        _buildMarketRow(
                          name: isHindi ? 'राँची क्षेत्रीय हब' : 'Ranchi Regional Hub',
                          distance: isHindi ? '105 किमी · राँची' : '105 km · Ranchi',
                          price: '\u20B96200',
                          isHighest: true,
                          showDivider: false,
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                // Disclaimer caption
                Text(
                  isHindi
                      ? 'काल्पनिक नमूना मूल्य, वास्तविक लाइव मंडी डेटा नहीं।'
                      : 'Fictional sample prices, not live market data.',
                  style: const TextStyle(
                    fontFamily: 'Mukta',
                    fontSize: 12.5,
                    color: AppColors.textMuted, fontWeight: FontWeight.w400,
                  ),
                ),
              ] else if (_activeTab == 1) ...[
                // "Sell My Crop" tab
                _buildSellMyCropView(isHindi),
              ] else ...[
                // "Verified Buyers" tab
                _buildVerifiedBuyersView(isHindi),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubTab({
    required String title,
    required int index,
    required int flex,
  }) {
    final isSelected = _activeTab == index;

    return Expanded(
      flex: flex,
      child: GestureDetector(
        onTap: () => setState(() => _activeTab = index),
        child: Container(
          height: 46,
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryGreen : Colors.white,
            borderRadius: BorderRadius.circular(23),
            border: isSelected
                ? null
                : Border.all(color: const Color(0xFFDDD6C4), width: 1),
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
          child: Center(
            child: Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: 'Mukta',
                fontSize: 13.5,
                fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
                color: isSelected ? Colors.white : AppColors.textDark,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMarketRow({
    required String name,
    required String distance,
    required String price,
    required bool isHighest,
    required bool showDivider,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: showDivider
            ? const Border(bottom: BorderSide(color: Color(0xFFEEE8DA), width: 1))
            : null,
      ),
      child: Row(
        children: [
          // Pin Squircle (.k, #DDEBF3, #18566F)
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFDDEBF3),
              borderRadius: BorderRadius.circular(13),
            ),
            child: const Center(
              child: Icon(
                Icons.location_on_outlined,
                size: 22,
                color: Color(0xFF18566F),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontFamily: 'Mukta',
                    fontSize: 16.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                  ),
                ),
                Text(
                  distance,
                  style: const TextStyle(
                    fontFamily: 'Mukta',
                    fontSize: 13,
                    fontWeight: FontWeight.w400, color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                price,
                style: const TextStyle(
                  fontFamily: 'Mukta',
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryGreen,
                ),
              ),
              if (isHighest)
                Container(
                  margin: const EdgeInsets.only(top: 2),
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                  decoration: BoxDecoration(
                    color: AppColors.accentGold, // #F2B134
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Highest',
                    style: TextStyle(
                      fontFamily: 'Mukta',
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF2A1B00),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSellMyCropView(bool isHindi) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 8),
          padding: const EdgeInsets.all(16),
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
              Text(
                isHindi ? 'अपनी उपज सीधे व्यापारियों को बेचें' : 'Sell your harvest to direct buyers',
                style: const TextStyle(
                  fontFamily: 'Mukta',
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                isHindi
                    ? 'भूमि प्लेटफॉर्म के माध्यम से अपनी फसल की जानकारी पोस्ट करें और सीधे विश्वसनीय खरीदारों से उत्तम मूल्य प्राप्त करें।'
                    : 'List your crop batch on Bhoomi and receive verified trade inquiries directly without middleman cuts.',
                style: const TextStyle(
                  fontFamily: 'Mukta',
                  fontSize: 14,
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => _showPostBatchModal(isHindi),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.add_circle_outline_rounded, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      isHindi ? '+ नई फसल लिस्ट करें' : '+ Post New Batch For Sale',
                      style: const TextStyle(fontFamily: 'Mukta', fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 18),

        // Active Listings Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              isHindi ? 'आपकी सक्रिय फसल लिस्टिंग' : 'Your Active Sell Listings',
              style: const TextStyle(
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
                '${_storage.getMarketListings().length} Active',
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

        if (_storage.getMarketListings().isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE6E0D2)),
            ),
            child: Center(
              child: Text(
                isHindi ? 'कोई सक्रिय लिस्टिंग नहीं है। ऊपर बटन दबाकर फसल जोड़ें।' : 'No active listings. Tap above to list your harvest.',
                style: const TextStyle(fontFamily: 'Mukta', color: Color(0xFF7A887E)),
              ),
            ),
          )
        else
          ..._storage.getMarketListings().map((item) {
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE2EFDF),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'Live Listing ✓',
                              style: TextStyle(
                                fontFamily: 'Mukta',
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF1E4D2B),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            item['date'] as String,
                            style: const TextStyle(
                              fontFamily: 'Mukta',
                              fontSize: 11.5,
                              color: Color(0xFF7A887E),
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline_rounded, size: 20, color: Color(0xFFB03A2E)),
                        visualDensity: VisualDensity.compact,
                        padding: EdgeInsets.zero,
                        onPressed: () async {
                          await _storage.deleteMarketListing(item['id'] as String);
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Listing removed')),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item['crop'] as String,
                    style: const TextStyle(
                      fontFamily: 'Mukta',
                      fontSize: 16.5,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1B2A21),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFCEFD0),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          item['quantity'] as String,
                          style: const TextStyle(
                            fontFamily: 'Mukta',
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF8A5600),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Target: ${item['price']}',
                        style: const TextStyle(
                          fontFamily: 'Mukta',
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1E4D2B),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, size: 14, color: Color(0xFF7A887E)),
                      const SizedBox(width: 4),
                      Text(
                        item['location'] as String,
                        style: const TextStyle(
                          fontFamily: 'Mukta',
                          fontSize: 12,
                          color: Color(0xFF7A887E),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Divider(color: Color(0xFFEEE8DA)),
                  const SizedBox(height: 4),
                  GestureDetector(
                    onTap: () => _shareListing(item),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.share_rounded, size: 16, color: Color(0xFF1E4D2B)),
                        SizedBox(width: 6),
                        Text(
                          'Share Listing to WhatsApp Buyers',
                          style: TextStyle(
                            fontFamily: 'Mukta',
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1E4D2B),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
      ],
    );
  }

  Widget _buildVerifiedBuyersView(bool isHindi) {
    final buyers = [
      {'name': 'Palamu Organic Herbs Ltd.', 'crop': 'Ashwagandha', 'rating': '4.9', 'badge': 'Govt Certified', 'phone': '+91 94311 02938'},
      {'name': 'Ranchi Wellness Co-op', 'crop': 'Tulsi & Herbs', 'rating': '4.8', 'badge': 'Prompt Payer', 'phone': '+91 98350 49182'},
      {'name': 'Jharkhand Ayur Traders', 'crop': 'Medicinal Roots', 'rating': '4.7', 'badge': 'Bulk Buyer', 'phone': '+91 91223 88471'},
    ];

    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
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
        children: buyers.map((b) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: AppColors.mintTint,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Icon(Icons.verified_rounded, color: AppColors.primaryGreen, size: 22),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        b['name']!,
                        style: const TextStyle(
                          fontFamily: 'Mukta',
                          fontSize: 15.5,
                          fontWeight: FontWeight.w400,
                          color: AppColors.textDark,
                        ),
                      ),
                      Text(
                        'Buys: ${b['crop']} · \u2605 ${b['rating']}',
                        style: const TextStyle(
                          fontFamily: 'Mukta',
                          fontSize: 13,
                          fontWeight: FontWeight.w400, color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                InkWell(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: b['phone']!));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Calling buyer ${b['name']} (${b['phone']})...'),
                        backgroundColor: AppColors.primaryGreen,
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE2EFDF),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.call_rounded, size: 14, color: Color(0xFF1E4D2B)),
                        SizedBox(width: 4),
                        Text(
                          'Call',
                          style: TextStyle(
                            fontFamily: 'Mukta',
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1E4D2B),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

/// Sprout icon for crop selector (viewBox 0 0 52 52)
class _CropSproutPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 52.0;
    canvas.scale(scale, scale);

    final stemPaint = Paint()
      ..color = const Color(0xFF1E4D2B)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    canvas.drawLine(const Offset(26, 42), const Offset(26, 22), stemPaint);

    final leafFill = Paint()
      ..color = const Color(0xFF3A8350)
      ..style = PaintingStyle.fill;
    final leafStroke = Paint()
      ..color = const Color(0xFF1E4D2B)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final leftLeaf = Path()
      ..moveTo(26, 30)
      ..cubicTo(18, 30, 15, 25, 15, 19)
      ..cubicTo(22, 19, 26, 23, 26, 30)
      ..close();
    canvas.drawPath(leftLeaf, leafFill);
    canvas.drawPath(leftLeaf, leafStroke);

    final rightLeaf = Path()
      ..moveTo(26, 26)
      ..cubicTo(26, 20, 30, 16, 37, 16)
      ..cubicTo(37, 23, 33, 26, 26, 26)
      ..close();
    canvas.drawPath(rightLeaf, leafFill);
    canvas.drawPath(rightLeaf, leafStroke);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Golden Coin with Rupee symbol for Hero Card:
/// viewBox 0 0 140 128
/// circle cx: 86, cy: 64, r: 48, #F2B134 opacity .2
/// circle cx: 86, cy: 64, r: 34, #F2B134, stroke #8A5600 width 3
/// circle cx: 86, cy: 64, r: 26, stroke #8A5600 width 1.6
/// text x: 86, y: 76, center, font-size 34, #8A5600, font Mukta
class _HeroCoinPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // 1. Halo: cx 86, cy 64, r 48
    final haloPaint = Paint()
      ..color = const Color(0xFFF2B134).withOpacity(0.2)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(const Offset(86, 64), 48, haloPaint);

    // 2. Outer coin disc: cx 86, cy 64, r 34
    final coinFill = Paint()
      ..color = const Color(0xFFF2B134)
      ..style = PaintingStyle.fill;
    final coinStroke = Paint()
      ..color = const Color(0xFF8A5600)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(const Offset(86, 64), 34, coinFill);
    canvas.drawCircle(const Offset(86, 64), 34, coinStroke);

    // 3. Inner engraved circle: cx 86, cy 64, r 26
    final innerStroke = Paint()
      ..color = const Color(0xFF8A5600)
      ..strokeWidth = 1.6
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(const Offset(86, 64), 26, innerStroke);

    // 4. Rupee symbol: ₹
    final textPainter = TextPainter(
      text: const TextSpan(
        text: '\u20B9',
        style: TextStyle(
          fontFamily: 'Mukta',
          fontSize: 34,
          fontWeight: FontWeight.w600,
          color: Color(0xFF8A5600),
          height: 1.0,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(86 - (textPainter.width / 2), 64 - (textPainter.height / 2) + 1),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
