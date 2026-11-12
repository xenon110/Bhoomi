import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../l10n/app_strings.dart';
import '../services/gemini_service.dart';
import '../services/mandi_service.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';
import 'market/mandi_arbitrage_screen.dart';

class MarketScreen extends StatefulWidget {
  final VoidCallback? onBackToHome;
  final String? initialCrop;
  const MarketScreen({Key? key, this.onBackToHome, this.initialCrop}) : super(key: key);

  @override
  State<MarketScreen> createState() => _MarketScreenState();
}

class _MarketScreenState extends State<MarketScreen> {
  final MandiService _mandiService = MandiService();
  final StorageService _storage = StorageService();
  final TextEditingController _searchController = TextEditingController();

  String _selectedCrop = 'Mustard';
  int _activeTab = 0; // 0: Mandi Prices, 1: Sell My Crop, 2: Verified Buyers
  bool _showAllPlaces = false;
  String _buyerFilter = 'all';

  List<MandiPrice> _prices = [];
  bool _isLoading = false;
  GeminiMandiAdvice? _aiMandiAdvice;
  bool _isLoadingAiAdvice = false;
  List<String> _searchResults = [];

  bool get isHindi => AppLanguage().isHindi;

  static const List<String> _quickCrops = [
    'Mustard',
    'Wheat',
    'Paddy',
    'Potato',
    'Tomato',
    'Maize',
    'Gram',
    'Soybean',
    'Onion',
    'Garlic',
    'Ashwagandha',
    'Tulsi',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.initialCrop != null && widget.initialCrop!.isNotEmpty) {
      _selectedCrop = widget.initialCrop!;
    }
    _fetchPrices();
    _fetchAiAdvice();
    _storage.addListener(_onStorageChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _storage.removeListener(_onStorageChanged);
    super.dispose();
  }

  void _onStorageChanged() {
    if (mounted) setState(() {});
  }

  void _onSearchChanged(String query) {
    if (query.trim().isEmpty) {
      setState(() => _searchResults = []);
      return;
    }
    final results = _mandiService.searchCrops(query);
    setState(() => _searchResults = results);
  }

  void _performSearch(String query) {
    final clean = query.trim();
    if (clean.isEmpty) return;
    final results = _mandiService.searchCrops(clean);
    if (results.isNotEmpty) {
      _onSelectCrop(results.first);
    } else {
      _onSelectCrop(clean);
    }
    _searchController.clear();
    setState(() => _searchResults = []);
  }

  void _onSelectCrop(String crop) {
    setState(() {
      _selectedCrop = crop;
    });
    _fetchPrices();
    _fetchAiAdvice();
  }

  Future<void> _fetchPrices() async {
    setState(() => _isLoading = true);
    final p = await _mandiService.getPricesForCrop(_selectedCrop, allPlaces: _showAllPlaces);
    if (mounted) {
      setState(() {
        _prices = p;
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchAiAdvice() async {
    setState(() => _isLoadingAiAdvice = true);
    final advice = await GeminiService().getMandiAdvice(cropName: _selectedCrop);
    if (mounted) {
      setState(() {
        _aiMandiAdvice = advice;
        _isLoadingAiAdvice = false;
      });
    }
  }

  String _formatCropChip(String crop, bool isHindi) {
    switch (crop.toLowerCase()) {
      case 'mustard':
        return isHindi ? 'सरसों' : 'Mustard';
      case 'wheat':
        return isHindi ? 'गेहूं' : 'Wheat';
      case 'paddy':
        return isHindi ? 'धान' : 'Paddy';
      case 'potato':
        return isHindi ? 'आलू' : 'Potato';
      case 'tomato':
        return isHindi ? 'टमाटर' : 'Tomato';
      case 'maize':
        return isHindi ? 'मक्का' : 'Maize';
      case 'gram':
        return isHindi ? 'चना' : 'Gram';
      case 'soybean':
        return isHindi ? 'सोयाबीन' : 'Soybean';
      case 'onion':
        return isHindi ? 'प्याज' : 'Onion';
      case 'garlic':
        return isHindi ? 'लहसुन' : 'Garlic';
      case 'ashwagandha':
        return isHindi ? 'अश्वगंधा' : 'Ashwagandha';
      case 'tulsi':
        return isHindi ? 'तुलसी' : 'Tulsi';
      default:
        return crop;
    }
  }

  String _formatCropName(String crop, bool isHindi) {
    switch (crop.toLowerCase()) {
      case 'mustard':
        return isHindi ? 'सरसों (Mustard)' : 'Mustard';
      case 'wheat':
        return isHindi ? 'गेहूं (Wheat)' : 'Wheat';
      case 'paddy':
        return isHindi ? 'धान / चावल (Paddy)' : 'Paddy / Rice';
      case 'potato':
        return isHindi ? 'आलू (Potato)' : 'Potato';
      case 'tomato':
        return isHindi ? 'टमाटर (Tomato)' : 'Tomato';
      case 'maize':
        return isHindi ? 'मक्का (Maize)' : 'Maize';
      case 'gram':
        return isHindi ? 'चना (Gram / Chana)' : 'Gram / Chickpea';
      case 'soybean':
        return isHindi ? 'सोयाबीन (Soybean)' : 'Soybean';
      case 'onion':
        return isHindi ? 'प्याज (Onion)' : 'Onion';
      case 'garlic':
        return isHindi ? 'लहसुन (Garlic)' : 'Garlic';
      case 'ashwagandha':
        return isHindi ? 'अश्वगंधा (Ashwagandha)' : 'Ashwagandha';
      case 'tulsi':
        return isHindi ? 'तुलसी (Tulsi / Basil)' : 'Tulsi (Holy Basil)';
      default:
        return crop;
    }
  }

  String _formatArrival(String arrival, bool isHindi) {
    if (isHindi) return arrival;
    return arrival
        .replaceAll('बोरी', 'Bags')
        .replaceAll('कैरेट', 'Crates')
        .replaceAll('कट्टे', 'Sacks')
        .replaceAll('क्विंटल', 'Quintals');
  }

  void _shareListing(Map<String, dynamic> item) {
    final text = '🌾 Crop For Sale on Bhoomi App: ${item['crop']}, Quantity: ${item['quantity']}, Expected Price: ${item['price']}, Location: ${item['location']}, Contact: ${item['phone']}';
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isHindi ? 'लिस्टिंग कॉपी की गई! आप इसे WhatsApp व्यापारी ग्रुप्स में साझा कर सकते हैं।' : 'Listing copied! Share it on WhatsApp trader groups.'),
        backgroundColor: AppColors.primaryGreen,
      ),
    );
  }

  // -------------------------------------------------------------
  // MODALS & BOTTOM SHEETS
  // -------------------------------------------------------------

  void _showPostBatchModal(bool isHindi, {String? targetMandi, String? targetBuyer}) {
    final profile = _storage.getProfile();
    String selectedCrop = _selectedCrop;
    final initialPrice = _mandiService.getBenchmarkPrice(_selectedCrop);
    final qtyCtrl = TextEditingController();
    final priceCtrl = TextEditingController(text: initialPrice > 0 ? '$initialPrice' : '5500');
    final userLoc = targetMandi ?? [profile.village, profile.district].where((s) => s.isNotEmpty).join(', ');
    final locCtrl = TextEditingController(text: userLoc);
    final userPhone = profile.phone.replaceAll('+91 ', '').replaceAll('+91', '').trim();
    final phoneCtrl = TextEditingController(text: userPhone);

    final availableCrops = _mandiService.getAvailableCrops();

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
                      targetBuyer != null
                          ? (isHindi ? '$targetBuyer को सीधे बेचें' : 'Sell Direct to $targetBuyer')
                          : (targetMandi != null
                              ? (isHindi ? '$targetMandi हेतु फसल लिस्ट करें' : 'Post Batch for $targetMandi')
                              : (isHindi ? 'फसल उपज बिक्री हेतु लिस्ट करें' : 'Post Crop Batch for Sale')),
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

                    // Crop Selection Chips
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
                          final isSel = selectedCrop.toLowerCase() == c.toLowerCase();
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: InkWell(
                              onTap: () {
                                setModalState(() {
                                  selectedCrop = c;
                                  final bp = _mandiService.getBenchmarkPrice(c);
                                  if (bp > 0) priceCtrl.text = '$bp';
                                });
                              },
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: isSel ? const Color(0xFF1E4D2B) : const Color(0xFFF6F2E9),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: isSel ? const Color(0xFF1E4D2B) : const Color(0xFFDDD6C4)),
                                ),
                                child: Text(
                                  _formatCropChip(c, isHindi),
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
                                  hintText: 'e.g. 5600',
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

                    // Location / Mandi
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

                    const SizedBox(height: 20),

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
                          'target': targetBuyer ?? targetMandi ?? 'All Buyers',
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

  void _showMandiContactSheet(MandiPrice mandi, bool isHindi) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
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
                      color: AppColors.mintTint,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Center(
                      child: Icon(Icons.storefront_rounded, color: AppColors.primaryGreen, size: 24),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          mandi.mandiName,
                          style: const TextStyle(
                            fontFamily: 'Mukta',
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textDark,
                          ),
                        ),
                        Text(
                          '${mandi.district}, ${mandi.state} · ${mandi.distance}',
                          style: const TextStyle(
                            fontFamily: 'Mukta',
                            fontSize: 13,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Mandi Info Card
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9F7F1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE5DFC9)),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          isHindi ? 'दैनिक नीलामी समय:' : 'Auction Timings:',
                          style: const TextStyle(fontFamily: 'Mukta', fontSize: 13, color: AppColors.textMuted),
                        ),
                        Text(
                          isHindi ? 'प्रातः 08:00 - दोपहर 02:00' : '08:00 AM - 02:00 PM',
                          style: const TextStyle(fontFamily: 'Mukta', fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textDark),
                        ),
                      ],
                    ),
                    const Divider(height: 14, color: Color(0xFFE5DFC9)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          isHindi ? 'सत्यापित लाइसेंसधारी आढ़ती:' : 'Licensed Traders:',
                          style: const TextStyle(fontFamily: 'Mukta', fontSize: 13, color: AppColors.textMuted),
                        ),
                        Text(
                          '${mandi.traderCount}+ आढ़ती सक्रिय',
                          style: const TextStyle(fontFamily: 'Mukta', fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.primaryGreen),
                        ),
                      ],
                    ),
                    const Divider(height: 14, color: Color(0xFFE5DFC9)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          isHindi ? 'आज का भाव (${mandi.cropName}):' : "Today's Rate:",
                          style: const TextStyle(fontFamily: 'Mukta', fontSize: 13, color: AppColors.textMuted),
                        ),
                        Text(
                          '₹${mandi.modalPrice}/Qtl · ${mandi.priceChange}',
                          style: const TextStyle(fontFamily: 'Mukta', fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFFB37400)),
                        ),
                      ],
                    ),
                    const Divider(height: 14, color: Color(0xFFE5DFC9)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          isHindi ? 'मंडी हेल्पडेस्क / संपर्क:' : 'Helpdesk / Contact:',
                          style: const TextStyle(fontFamily: 'Mukta', fontSize: 13, color: AppColors.textMuted),
                        ),
                        Text(
                          mandi.phone,
                          style: const TextStyle(fontFamily: 'Mukta', fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textDark),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: mandi.phone));
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              isHindi
                                  ? '${mandi.mandiName} नंबर (${mandi.phone}) कॉपी किया गया... डायल करें'
                                  : '${mandi.mandiName} contact (${mandi.phone}) copied to dialer',
                            ),
                            backgroundColor: AppColors.primaryGreen,
                          ),
                        );
                      },
                      icon: const Icon(Icons.call_rounded, size: 18),
                      label: Text(
                        isHindi ? 'कॉल करें' : 'Call Desk',
                        style: const TextStyle(fontFamily: 'Mukta', fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryGreen,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        elevation: 0,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(ctx);
                        _showPostBatchModal(isHindi, targetMandi: mandi.mandiName);
                      },
                      icon: const Icon(Icons.add_shopping_cart_rounded, size: 18),
                      label: Text(
                        isHindi ? 'यहाँ बेचें' : 'Sell Here',
                        style: const TextStyle(fontFamily: 'Mukta', fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primaryGreen,
                        side: const BorderSide(color: AppColors.primaryGreen, width: 1.5),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
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

  void _showMandiDetailsSheet(MandiPrice price, bool isHindi) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
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
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: AppColors.mintTint,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Center(
                      child: Icon(Icons.storefront_rounded, color: AppColors.primaryGreen, size: 26),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          price.mandiName,
                          style: const TextStyle(
                            fontFamily: 'Mukta',
                            fontSize: 19,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textDark,
                          ),
                        ),
                        Text(
                          '${price.district}, ${price.state} · ${price.distance}',
                          style: const TextStyle(
                            fontFamily: 'Mukta',
                            fontSize: 13,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9F7F1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE5DFC9), width: 1),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          isHindi ? 'दैनिक औसत (Modal Rate):' : 'Modal Rate:',
                          style: const TextStyle(fontFamily: 'Mukta', fontSize: 14, color: AppColors.textDark),
                        ),
                        Text(
                          '₹${price.modalPrice} / ${isHindi ? "क्विंटल" : "Quintal"}',
                          style: const TextStyle(fontFamily: 'Mukta', fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.primaryGreen),
                        ),
                      ],
                    ),
                    const Divider(height: 16, color: Color(0xFFE5DFC9)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          isHindi ? 'न्यूनतम - अधिकतम रेंज:' : 'Price Range:',
                          style: const TextStyle(fontFamily: 'Mukta', fontSize: 13, color: AppColors.textMuted),
                        ),
                        Text(
                          '₹${price.minPrice} - ₹${price.maxPrice}',
                          style: const TextStyle(fontFamily: 'Mukta', fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textDark),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          isHindi ? 'दैनिक आवक (Arrival):' : 'Daily Arrival:',
                          style: const TextStyle(fontFamily: 'Mukta', fontSize: 13, color: AppColors.textMuted),
                        ),
                        Text(
                          _formatArrival(price.arrival, isHindi),
                          style: const TextStyle(fontFamily: 'Mukta', fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textDark),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          isHindi ? 'किस्म / वैरायटी:' : 'Variety:',
                          style: const TextStyle(fontFamily: 'Mukta', fontSize: 13, color: AppColors.textMuted),
                        ),
                        Flexible(
                          child: Text(
                            price.variety,
                            style: const TextStyle(fontFamily: 'Mukta', fontSize: 13.5, fontWeight: FontWeight.w500, color: AppColors.textDark),
                            textAlign: TextAlign.end,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(ctx);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => MandiArbitrageScreen(initialCrop: price.cropName)),
                        );
                      },
                      icon: const Icon(Icons.calculate_rounded, size: 18),
                      label: Text(
                        isHindi ? 'मुनाफा कैलकुलेटर' : 'Profit Calc',
                        style: const TextStyle(fontFamily: 'Mukta', fontSize: 14, fontWeight: FontWeight.w500),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryGreen,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        elevation: 0,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(ctx);
                        _showMandiContactSheet(price, isHindi);
                      },
                      icon: const Icon(Icons.call_rounded, size: 18),
                      label: Text(
                        isHindi ? 'मंडी संपर्क' : 'Contact Mandi',
                        style: const TextStyle(fontFamily: 'Mukta', fontSize: 14, fontWeight: FontWeight.w500),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primaryGreen,
                        side: const BorderSide(color: AppColors.primaryGreen),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
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

  void _showBuyerContactSheet(Map<String, dynamic> buyer, bool isHindi) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
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
                      color: AppColors.mintTint,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Center(
                      child: Icon(Icons.verified_rounded, color: AppColors.primaryGreen, size: 24),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          buyer['name'] as String,
                          style: const TextStyle(fontFamily: 'Mukta', fontSize: 17, fontWeight: FontWeight.w600, color: AppColors.textDark),
                        ),
                        Text(
                          '${buyer['type']} · ${buyer['location']}',
                          style: const TextStyle(fontFamily: 'Mukta', fontSize: 12.5, color: AppColors.textMuted),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9F7F1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE5DFC9)),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(isHindi ? 'खरीद मांग:' : 'Buying Demand:', style: const TextStyle(fontFamily: 'Mukta', fontSize: 13, color: AppColors.textMuted)),
                        Text(buyer['demand'] as String, style: const TextStyle(fontFamily: 'Mukta', fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textDark)),
                      ],
                    ),
                    const Divider(height: 12, color: Color(0xFFE5DFC9)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(isHindi ? 'ऑफ़र भाव:' : 'Offer Rate:', style: const TextStyle(fontFamily: 'Mukta', fontSize: 13, color: AppColors.textMuted)),
                        Text(buyer['offerPrice'] as String, style: const TextStyle(fontFamily: 'Mukta', fontSize: 13.5, fontWeight: FontWeight.w600, color: Color(0xFF1E4D2B))),
                      ],
                    ),
                    const Divider(height: 12, color: Color(0xFFE5DFC9)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(isHindi ? 'हेल्पलाइन / फोन:' : 'Direct Phone:', style: const TextStyle(fontFamily: 'Mukta', fontSize: 13, color: AppColors.textMuted)),
                        Text(buyer['phone'] as String, style: const TextStyle(fontFamily: 'Mukta', fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textDark)),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: buyer['phone'] as String));
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(isHindi ? '${buyer['name']} नंबर (${buyer['phone']}) कॉपी किया गया... डायल करें' : '${buyer['name']} contact copied to dialer'),
                            backgroundColor: AppColors.primaryGreen,
                          ),
                        );
                      },
                      icon: const Icon(Icons.call_rounded, size: 18),
                      label: Text(isHindi ? 'कॉल करें' : 'Call Buyer', style: const TextStyle(fontFamily: 'Mukta', fontSize: 14, fontWeight: FontWeight.w600)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryGreen,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        elevation: 0,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(ctx);
                        _showRequestQuoteModal(buyer, isHindi);
                      },
                      icon: const Icon(Icons.chat_bubble_outline_rounded, size: 18),
                      label: Text(isHindi ? 'कोटेशन मांगें' : 'Request Quote', style: const TextStyle(fontFamily: 'Mukta', fontSize: 14, fontWeight: FontWeight.w600)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primaryGreen,
                        side: const BorderSide(color: AppColors.primaryGreen, width: 1.5),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
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

  void _showRequestQuoteModal(Map<String, dynamic> buyer, bool isHindi) {
    final qtyCtrl = TextEditingController(text: '30');
    final priceCtrl = TextEditingController(text: '${_mandiService.getBenchmarkPrice(_selectedCrop)}');
    final noteCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final bottomInset = MediaQuery.of(ctx).viewInsets.bottom;
        return Container(
          padding: EdgeInsets.fromLTRB(20, 20, 20, bottomInset > 0 ? bottomInset + 20 : 28),
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
              Text(
                isHindi ? '${buyer['name']} से भाव कोटेशन मांगें' : 'Request Quote from ${buyer['name']}',
                style: const TextStyle(fontFamily: 'Mukta', fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF1B2A21)),
              ),
              Text(
                isHindi ? 'अपनी फसल का विवरण भेजें, खरीदार सीधे आपको कॉल या WhatsApp पर भाव देगा' : 'Send your harvest lot info to receive direct verified trade quotation',
                style: const TextStyle(fontFamily: 'Mukta', fontSize: 12.5, color: Color(0xFF55655A)),
              ),
              const SizedBox(height: 14),

              // Quantity & Target Price
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(isHindi ? 'मात्रा (क्विंटल)' : 'Quantity (Qtl)', style: const TextStyle(fontFamily: 'Mukta', fontSize: 13, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 4),
                        TextField(
                          controller: qtyCtrl,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(fontFamily: 'Mukta', fontSize: 14),
                          decoration: InputDecoration(
                            hintText: '30',
                            suffixText: 'Qtl',
                            filled: true,
                            fillColor: const Color(0xFFF6F2E9),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                        Text(isHindi ? 'अपेक्षित भाव (₹/Qtl)' : 'Target Rate (₹/Qtl)', style: const TextStyle(fontFamily: 'Mukta', fontSize: 13, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 4),
                        TextField(
                          controller: priceCtrl,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(fontFamily: 'Mukta', fontSize: 14),
                          decoration: InputDecoration(
                            hintText: '5600',
                            prefixText: '₹ ',
                            filled: true,
                            fillColor: const Color(0xFFF6F2E9),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Notes
              Text(isHindi ? 'विशेष विवरण / ग्रेड (वैकल्पिक)' : 'Quality / Moisture Notes', style: const TextStyle(fontFamily: 'Mukta', fontSize: 13, fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              TextField(
                controller: noteCtrl,
                style: const TextStyle(fontFamily: 'Mukta', fontSize: 14),
                decoration: InputDecoration(
                  hintText: isHindi ? 'उदा. बोल्ड दाना, 42% तेल, सूखी फसल...' : 'e.g. Bold grain, moisture < 8%, Grade A',
                  filled: true,
                  fillColor: const Color(0xFFF6F2E9),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),

              const SizedBox(height: 18),

              ElevatedButton(
                onPressed: () async {
                  if (qtyCtrl.text.trim().isEmpty) return;
                  final inquiry = {
                    'id': DateTime.now().millisecondsSinceEpoch.toString(),
                    'buyerName': buyer['name'],
                    'buyerPhone': buyer['phone'],
                    'crop': _selectedCrop,
                    'quantity': '${qtyCtrl.text.trim()} Qtl',
                    'price': '₹${priceCtrl.text.trim()}',
                    'notes': noteCtrl.text.trim(),
                    'date': 'Today',
                    'status': isHindi ? 'प्रतीक्षारत (Pending Response)' : 'Pending Response',
                  };
                  await _storage.addBuyerInquiry(inquiry);
                  Navigator.pop(ctx);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          isHindi
                              ? '✓ कोटेशन अनुरोध ${buyer['name']} को भेजा गया! खरीदार 2-4 घंटे में संपर्क करेगा।'
                              : '✓ Quote request submitted to ${buyer['name']} successfully!',
                          style: const TextStyle(fontFamily: 'Mukta'),
                        ),
                        backgroundColor: AppColors.primaryGreen,
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 46),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: Text(
                  isHindi ? 'कोटेशन अनुरोध भेजें →' : 'Send Quote Request →',
                  style: const TextStyle(fontFamily: 'Mukta', fontSize: 15, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAskAiMarketModal() {
    final textController = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final bottomInset = MediaQuery.of(ctx).viewInsets.bottom;
        return StatefulBuilder(
          builder: (modalCtx, setModalState) {
            return Container(
              padding: EdgeInsets.fromLTRB(20, 20, 20, bottomInset > 0 ? bottomInset + 20 : 28),
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
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.accentGoldLight,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.psychology_rounded, color: Color(0xFF7A4D00), size: 24),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isHindi ? 'AI मंडी विशेषज्ञ से पूछें' : 'Ask AI Mandi Advisor',
                              style: const TextStyle(
                                fontFamily: 'Mukta',
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1B2A21),
                              ),
                            ),
                            Text(
                              isHindi ? 'फसल भाव, सही समय एवं तेजी-मंदी का पूर्वानुमान' : 'Live price forecast & selling strategy',
                              style: const TextStyle(fontFamily: 'Mukta', fontSize: 12.5, color: Color(0xFF55655A)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  if (_aiMandiAdvice != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF6F2E9),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFE5DFC9)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${_formatCropChip(_selectedCrop, isHindi)} · ${_aiMandiAdvice!.getTrend(isHindi)}',
                                style: const TextStyle(fontFamily: 'Mukta', fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1E4D2B)),
                              ),
                              Text(
                                _aiMandiAdvice!.mspRate,
                                style: const TextStyle(fontFamily: 'Mukta', fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF2E7D32)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _aiMandiAdvice!.getRecommendation(isHindi),
                            style: const TextStyle(fontFamily: 'Mukta', fontSize: 13.5, fontWeight: FontWeight.w600, color: AppColors.textDark),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _aiMandiAdvice!.getAnalysis(isHindi),
                            style: const TextStyle(fontFamily: 'Mukta', fontSize: 12, color: AppColors.textMuted),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],

                  TextField(
                    controller: textController,
                    style: const TextStyle(fontFamily: 'Mukta', fontSize: 14),
                    decoration: InputDecoration(
                      hintText: isHindi ? 'उदा. क्या मुझे अभी सरसों बेचनी चाहिए या 15 दिन रुकना चाहिए?' : 'e.g. Should I hold or sell my mustard now?',
                      filled: true,
                      fillColor: const Color(0xFFF6F2E9),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.all(12),
                    ),
                  ),
                  const SizedBox(height: 14),

                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      _fetchAiAdvice();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGreen,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 44),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      elevation: 0,
                    ),
                    child: Text(
                      isHindi ? 'AI से ताजा विश्लेषण पूछें' : 'Get Fresh AI Intel',
                      style: const TextStyle(fontFamily: 'Mukta', fontSize: 15, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // -------------------------------------------------------------
  // MAIN BUILD METHOD
  // -------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final isHindi = this.isHindi;
    final double benchmarkPrice = _prices.isNotEmpty ? _prices.first.modalPrice.toDouble() : 5520.0;

    return Scaffold(
      backgroundColor: AppColors.creamBg,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Sleek Header
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: widget.onBackToHome ?? () => Navigator.maybePop(context),
                    child: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(21),
                        border: Border.all(color: const Color(0xFFDDD6C4), width: 1),
                      ),
                      child: const Center(
                        child: Icon(Icons.chevron_left_rounded, size: 26, color: AppColors.textDark),
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
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.8,
                            color: Color(0xFF3A6B4A),
                          ),
                        ),
                        Text(
                          isHindi ? 'बाजार भाव' : 'Market Prices',
                          style: const TextStyle(
                            fontFamily: 'Mukta',
                            fontSize: 26,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textDark,
                            height: 1.1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // 2. Sub Tabs (Mandi Prices, Sell My Crop, Verified Buyers)
              Row(
                children: [
                  _buildSubTab(
                    title: isHindi ? 'मंडी भाव' : 'Mandi Rates',
                    index: 0,
                    flex: 11,
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
                    flex: 12,
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // Active Tab Content
              if (_activeTab == 0) ...[
                _buildMandiRatesView(isHindi, benchmarkPrice),
              ] else if (_activeTab == 1) ...[
                _buildSellMyCropView(isHindi),
              ] else ...[
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
          height: 42,
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryGreen : Colors.white,
            borderRadius: BorderRadius.circular(21),
            border: isSelected ? null : Border.all(color: const Color(0xFFDDD6C4), width: 1),
            boxShadow: isSelected
                ? const [
                    BoxShadow(
                      color: AppColors.primaryDark,
                      offset: Offset(0, 2),
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
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
                color: isSelected ? Colors.white : AppColors.textDark,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // -------------------------------------------------------------
  // TAB 0: MANDI RATES VIEW (CLEAN & BALANCED)
  // -------------------------------------------------------------

  Widget _buildMandiRatesView(bool isHindi, double benchmarkPrice) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Search Bar + "+ Add Batch / बेचें" Action Button Row
        Row(
          children: [
            Expanded(
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.borderLight, width: 1),
                  boxShadow: const [
                    BoxShadow(
                      color: AppColors.cardShadow,
                      offset: Offset(0, 2),
                      blurRadius: 0,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 12),
                    const Icon(Icons.search_rounded, color: AppColors.primaryGreen, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        style: const TextStyle(fontFamily: 'Mukta', fontSize: 14, color: AppColors.textDark),
                        decoration: InputDecoration(
                          hintText: isHindi ? 'फसल सर्च करें (उदा. सरसों, गेहूं, आलू...)' : 'Search crop (e.g. Mustard, Wheat...)',
                          hintStyle: const TextStyle(fontFamily: 'Mukta', fontSize: 13, color: AppColors.textMuted),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                        onChanged: _onSearchChanged,
                        onSubmitted: _performSearch,
                      ),
                    ),
                    if (_searchController.text.isNotEmpty)
                      IconButton(
                        icon: const Icon(Icons.close_rounded, size: 16, color: AppColors.textMuted),
                        onPressed: () {
                          _searchController.clear();
                          _onSearchChanged('');
                        },
                      ),
                    const SizedBox(width: 4),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            InkWell(
              onTap: () => _showPostBatchModal(isHindi),
              borderRadius: BorderRadius.circular(18),
              child: Container(
                height: 48,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: const [
                    BoxShadow(
                      color: AppColors.primaryDark,
                      offset: Offset(0, 3),
                      blurRadius: 0,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.add_rounded, color: Colors.white, size: 18),
                    const SizedBox(width: 4),
                    Text(
                      isHindi ? 'फसल बेचें' : '+ Sell Crop',
                      style: const TextStyle(
                        fontFamily: 'Mukta',
                        fontSize: 13.5,
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

        // Autocomplete Results Dropdown
        if (_searchResults.isNotEmpty && _searchController.text.isNotEmpty) ...[
          const SizedBox(height: 6),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.borderLight),
              boxShadow: const [
                BoxShadow(
                  color: AppColors.cardShadow,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: _searchResults.map((cropMatch) {
                final benchmark = _mandiService.getBenchmarkPrice(cropMatch);
                return ListTile(
                  dense: true,
                  leading: const Icon(Icons.grass_rounded, color: AppColors.primaryGreen, size: 18),
                  title: Text(
                    _formatCropName(cropMatch, isHindi),
                    style: const TextStyle(
                      fontFamily: 'Mukta',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark,
                    ),
                  ),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.mintTint,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '₹$benchmark/Qtl',
                      style: const TextStyle(
                        fontFamily: 'Mukta',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryGreen,
                      ),
                    ),
                  ),
                  onTap: () => _performSearch(cropMatch),
                );
              }).toList(),
            ),
          ),
        ],

        const SizedBox(height: 10),

        // 2. Horizontal Quick Crop Chips
        SizedBox(
          height: 36,
          child: ListView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            children: _quickCrops.map((c) {
              final isSel = c.toLowerCase() == _selectedCrop.toLowerCase();
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () => _onSelectCrop(c),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: isSel ? AppColors.primaryGreen : Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: isSel ? AppColors.primaryGreen : const Color(0xFFDDD6C4),
                        width: 1,
                      ),
                      boxShadow: isSel
                          ? const [
                              BoxShadow(
                                color: AppColors.primaryDark,
                                offset: Offset(0, 2),
                                blurRadius: 0,
                              ),
                            ]
                          : null,
                    ),
                    child: Center(
                      child: Text(
                        _formatCropChip(c, isHindi),
                        style: TextStyle(
                          fontFamily: 'Mukta',
                          fontSize: 12.5,
                          fontWeight: isSel ? FontWeight.w600 : FontWeight.w400,
                          color: isSel ? Colors.white : AppColors.textDark,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),

        const SizedBox(height: 12),

        // 3. Compact & Clean Hero Card (Rates + AI Intel + Quick Actions)
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.primaryGreen,
            borderRadius: BorderRadius.circular(22),
            boxShadow: const [
              BoxShadow(
                color: AppColors.primaryDark,
                offset: Offset(0, 4),
                blurRadius: 0,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Label Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: const BoxDecoration(
                          color: Color(0xFF55E685),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${_formatCropName(_selectedCrop, isHindi)} · ${isHindi ? "दैनिक APMC औसत भाव" : "LIVE APMC MODAL RATE"}',
                        style: TextStyle(
                          fontFamily: 'Mukta',
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.white.withOpacity(0.95),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _aiMandiAdvice?.mspRate ?? 'MSP: ₹5,650',
                      style: const TextStyle(
                        fontFamily: 'Mukta',
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 4),

              // Price & Trend Row
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    '₹${benchmarkPrice.round()}',
                    style: const TextStyle(
                      fontFamily: 'Mukta',
                      fontSize: 38,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isHindi ? '/ क्विंटल' : '/ Quintal',
                    style: TextStyle(
                      fontFamily: 'Mukta',
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Colors.white.withOpacity(0.85),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFF55E685),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _aiMandiAdvice?.getTrend(isHindi) ?? (isHindi ? 'तेजी (+₹45)' : 'Bullish (+₹45)'),
                      style: const TextStyle(
                        fontFamily: 'Mukta',
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF123320),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // AI Advice Line (Clean & Compact)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.psychology_rounded, size: 16, color: Color(0xFFF2B134)),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        _aiMandiAdvice?.getRecommendation(isHindi) ?? (isHindi ? '7-10 दिन रोकें (Hold): मांग बढ़ने से भाव में और सुधार संभव।' : 'Hold 7-10 days: Better prices expected due to rising demand.'),
                        style: const TextStyle(
                          fontFamily: 'Mukta',
                          fontSize: 12.5,
                          fontWeight: FontWeight.w400,
                          color: Colors.white,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    GestureDetector(
                      onTap: _showAskAiMarketModal,
                      child: Text(
                        isHindi ? 'विस्तार →' : 'Details →',
                        style: const TextStyle(
                          fontFamily: 'Mukta',
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFF2B134),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              // Two Quick Action Pills
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => MandiArbitrageScreen(initialCrop: _selectedCrop)),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.calculate_outlined, size: 16, color: AppColors.primaryGreen),
                            const SizedBox(width: 6),
                            Text(
                              isHindi ? 'भाड़ा व मुनाफा कैलकुलेटर' : 'Transport Calc',
                              style: const TextStyle(
                                fontFamily: 'Mukta',
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primaryGreen,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _showPostBatchModal(isHindi),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF2B134),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.add_shopping_cart_rounded, size: 16, color: Color(0xFF2A1B00)),
                            const SizedBox(width: 6),
                            Text(
                              isHindi ? 'फसल लिस्ट करें' : 'Post Batch',
                              style: const TextStyle(
                                fontFamily: 'Mukta',
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF2A1B00),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 14),

        // 4. Section: Mandis & Rates with "Nearby" vs "All Places Mandi" Toggle
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              isHindi ? 'मंडियां और आज के भाव' : 'Mandis & Today\'s Rates',
              style: const TextStyle(
                fontFamily: 'Mukta',
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
            ),

            // Toggle Pill: Nearby vs All Places
            Container(
              height: 32,
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: const Color(0xFFE8E2D2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      if (_showAllPlaces) {
                        setState(() => _showAllPlaces = false);
                        _fetchPrices();
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: !_showAllPlaces ? Colors.white : Colors.transparent,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(
                        isHindi ? 'निकटतम' : 'Nearby',
                        style: TextStyle(
                          fontFamily: 'Mukta',
                          fontSize: 11,
                          fontWeight: !_showAllPlaces ? FontWeight.w600 : FontWeight.w400,
                          color: !_showAllPlaces ? AppColors.primaryGreen : AppColors.textMuted,
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      if (!_showAllPlaces) {
                        setState(() => _showAllPlaces = true);
                        _fetchPrices();
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: _showAllPlaces ? AppColors.primaryGreen : Colors.transparent,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(
                        isHindi ? 'सभी जगह की मंडियां' : 'All Places Mandis',
                        style: TextStyle(
                          fontFamily: 'Mukta',
                          fontSize: 11,
                          fontWeight: _showAllPlaces ? FontWeight.w600 : FontWeight.w400,
                          color: _showAllPlaces ? Colors.white : AppColors.textMuted,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),

        // 5. Mandis Cards List
        if (_isLoading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 30),
            child: Center(
              child: CircularProgressIndicator(color: AppColors.primaryGreen, strokeWidth: 2.5),
            ),
          )
        else if (_prices.isNotEmpty)
          ..._prices.map((p) {
            final isHighest = p == _prices.reduce((curr, next) => curr.modalPrice > next.modalPrice ? curr : next);
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.borderLight, width: 1),
                boxShadow: const [
                  BoxShadow(
                    color: AppColors.cardShadow,
                    offset: Offset(0, 2),
                    blurRadius: 0,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Row: Mandi Name + Distance + Highest Badge
                  Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: isHighest ? const Color(0xFFFFF4D6) : const Color(0xFFDDEBF3),
                          borderRadius: BorderRadius.circular(11),
                        ),
                        child: Center(
                          child: Icon(
                            isHighest ? Icons.trending_up_rounded : Icons.location_on_outlined,
                            size: 19,
                            color: isHighest ? const Color(0xFFB37400) : const Color(0xFF18566F),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    p.mandiName,
                                    style: const TextStyle(
                                      fontFamily: 'Mukta',
                                      fontSize: 15.5,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textDark,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (isHighest) ...[
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                    decoration: BoxDecoration(
                                      color: AppColors.accentGold,
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    child: Text(
                                      isHindi ? 'सर्वोत्तम' : 'Highest',
                                      style: const TextStyle(
                                        fontFamily: 'Mukta',
                                        fontSize: 9.5,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF2A1B00),
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            Text(
                              '${p.district}, ${p.state} · ${p.distance}',
                              style: const TextStyle(
                                fontFamily: 'Mukta',
                                fontSize: 12,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '₹${p.modalPrice}',
                            style: const TextStyle(
                              fontFamily: 'Mukta',
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textDark,
                            ),
                          ),
                          Text(
                            p.priceChange,
                            style: TextStyle(
                              fontFamily: 'Mukta',
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: p.isUp ? const Color(0xFF2E7D32) : const Color(0xFFC62828),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Middle details row: Variety & Arrival
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0EBE0),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '${isHindi ? "आवक" : "Arrival"}: ${_formatArrival(p.arrival, isHindi)}',
                          style: const TextStyle(fontFamily: 'Mukta', fontSize: 11, color: Color(0xFF55655A)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${isHindi ? "किस्म" : "Variety"}: ${p.variety}',
                          style: const TextStyle(fontFamily: 'Mukta', fontSize: 11, color: Color(0xFF7A887E)),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),
                  const Divider(height: 1, color: Color(0xFFEEE8DA)),
                  const SizedBox(height: 8),

                  // Bottom Action Buttons: [📞 संपर्क (Contact)] [🌾 यहाँ बेचें (Sell Here)] [ℹ️ विवरण (Details)]
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () => _showMandiContactSheet(p, isHindi),
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.mintTint,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.call_rounded, size: 14, color: AppColors.primaryGreen),
                                const SizedBox(width: 4),
                                Text(
                                  isHindi ? 'संपर्क करें' : 'Contact Mandi',
                                  style: const TextStyle(
                                    fontFamily: 'Mukta',
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primaryGreen,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: InkWell(
                          onTap: () => _showPostBatchModal(isHindi, targetMandi: p.mandiName),
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF6F2E9),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: const Color(0xFFDDD6C4)),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.add_shopping_cart_rounded, size: 14, color: Color(0xFF1B2A21)),
                                const SizedBox(width: 4),
                                Text(
                                  isHindi ? 'यहाँ बेचें' : 'Sell Here',
                                  style: const TextStyle(
                                    fontFamily: 'Mukta',
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF1B2A21),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      InkWell(
                        onTap: () => _showMandiDetailsSheet(p, isHindi),
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFFDDD6C4)),
                          ),
                          child: const Icon(Icons.info_outline_rounded, size: 16, color: AppColors.textMuted),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }).toList()
        else
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Center(
              child: Text(
                isHindi ? 'मंडी भाव लोड हो रहे हैं...' : 'Loading mandi prices...',
                style: const TextStyle(fontFamily: 'Mukta', color: AppColors.textMuted),
              ),
            ),
          ),
      ],
    );
  }

  // -------------------------------------------------------------
  // TAB 1: SELL MY CROP VIEW
  // -------------------------------------------------------------

  Widget _buildSellMyCropView(bool isHindi) {
    final listings = _storage.getMarketListings();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Action Hero Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: AppColors.borderLight, width: 1),
            boxShadow: const [
              BoxShadow(
                color: AppColors.cardShadow,
                offset: Offset(0, 2),
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
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                isHindi
                    ? 'भूमि प्लेटफॉर्म पर अपनी फसल लिस्ट करें और बिना बिचौलियों के सीधे सत्यापित मिल मालिकों एवं थोक खरीदारों से सर्वोत्तम भाव पाएं।'
                    : 'List your crop batch on Bhoomi and connect directly with verified buyers without middleman commissions.',
                style: const TextStyle(
                  fontFamily: 'Mukta',
                  fontSize: 13,
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 14),
              ElevatedButton.icon(
                onPressed: () => _showPostBatchModal(isHindi),
                icon: const Icon(Icons.add_circle_outline_rounded, size: 18),
                label: Text(
                  isHindi ? '+ नई फसल बिक्री हेतु लिस्ट करें' : '+ Post New Crop Batch',
                  style: const TextStyle(fontFamily: 'Mukta', fontSize: 14.5, fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 44),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Active Listings Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              isHindi ? 'आपकी सक्रिय फसल लिस्टिंग' : 'Your Active Sell Listings',
              style: const TextStyle(
                fontFamily: 'Mukta',
                fontSize: 16,
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
                '${listings.length} Active',
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

        if (listings.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
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
          ...listings.map((item) {
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE2EFDF),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'Live Listing ✓',
                              style: TextStyle(
                                fontFamily: 'Mukta',
                                fontSize: 10.5,
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
                        icon: const Icon(Icons.delete_outline_rounded, size: 18, color: Color(0xFFB03A2E)),
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
                  const SizedBox(height: 4),
                  Text(
                    item['crop'] as String,
                    style: const TextStyle(
                      fontFamily: 'Mukta',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1B2A21),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFCEFD0),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          item['quantity'] as String,
                          style: const TextStyle(
                            fontFamily: 'Mukta',
                            fontSize: 12,
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
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1E4D2B),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Divider(color: Color(0xFFEEE8DA)),
                  GestureDetector(
                    onTap: () => _shareListing(item),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.share_rounded, size: 15, color: Color(0xFF1E4D2B)),
                        const SizedBox(width: 6),
                        Text(
                          isHindi ? 'WhatsApp व्यापारियों को शेयर करें' : 'Share to WhatsApp Buyers',
                          style: const TextStyle(
                            fontFamily: 'Mukta',
                            fontSize: 12.5,
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

  // -------------------------------------------------------------
  // TAB 2: VERIFIED BUYERS VIEW (LIVE, DYNAMIC, END-TO-END)
  // -------------------------------------------------------------

  Widget _buildVerifiedBuyersView(bool isHindi) {
    final inquiries = _storage.getBuyerInquiries();

    final List<Map<String, dynamic>> buyers = [
      {
        'id': 'b1',
        'name': isHindi ? 'श्री कृष्णा ऑयल मिल्स प्राइवेट लिमिटेड' : 'Shree Krishna Oil Mills Pvt Ltd',
        'type': isHindi ? 'प्रमुख तेल मिल व प्रोसेसर' : 'Major Oil Processor',
        'crop': isHindi ? 'सरसों, सोयाबीन, मूंगफली' : 'Mustard, Soybean, Groundnut',
        'cropCategory': 'oilseed',
        'rating': '4.8',
        'deals': '210+ किसान सौदे',
        'badge': isHindi ? '✓ GST व APMC लाइसेंस' : '✓ GST & APMC Licensed',
        'phone': '+91 94311 02938',
        'location': isHindi ? 'डाल्टनगंज औद्योगिक क्षेत्र, पलामू' : 'Daltonganj Industrial Area, Palamu',
        'demand': isHindi ? 'न्यूनतम: 25 क्विंटल | तुरंत DBT भुगतान' : 'Min: 25 Qtl | Instant DBT',
        'offerPrice': '₹5,580 - ₹5,680 / Qtl',
      },
      {
        'id': 'b2',
        'name': isHindi ? 'नेफेड (NAFED) सरकारी किसान खरीद केंद्र' : 'NAFED Govt Kisan Procurement Hub',
        'type': isHindi ? 'सरकारी नोडल एजेंसी (MSP)' : 'Govt Nodal Agency (MSP)',
        'crop': isHindi ? 'गेहूं, चना, सरसों, धान' : 'Wheat, Gram, Mustard, Paddy',
        'cropCategory': 'govt',
        'rating': '4.9',
        'deals': '1,450+ किसान',
        'badge': isHindi ? '✓ 100% सरकारी MSP खरीद' : '✓ 100% Govt MSP',
        'phone': '1800-180-1551',
        'location': isHindi ? 'पलामू APMC यार्ड' : 'Palamu APMC Yard',
        'demand': isHindi ? 'सरकारी समर्थन मूल्य (MSP) पर सीधी खरीद' : 'Direct purchase at MSP rate',
        'offerPrice': 'MSP Rate (₹5,650/₹2,425)',
      },
      {
        'id': 'b3',
        'name': isHindi ? 'अडानी विल्मर लिमिटेड (Fortune Hub)' : 'Adani Wilmar Ltd (Fortune Hub)',
        'type': isHindi ? 'कॉर्पोरेट थोक खरीदार' : 'Corporate Bulk Buyer',
        'crop': isHindi ? 'पीली व काली सरसों, सोयाबीन' : 'Mustard & Soybean Direct',
        'cropCategory': 'oilseed',
        'rating': '4.8',
        'deals': '380+ सौदे',
        'badge': isHindi ? '✓ 24 घंटे में बैंक DBT' : '✓ 24-hr Bank DBT',
        'phone': '+91 91223 88471',
        'location': isHindi ? 'सासाराम हब / रीजनल डिपो' : 'Sasaram Hub / Regional Depot',
        'demand': isHindi ? 'न्यूनतम: 40 क्विंटल | 42% तेल कंडीशन' : 'Min: 40 Qtl | 42% Oil Cond.',
        'offerPrice': '₹5,650 - ₹5,750 / Qtl',
      },
      {
        'id': 'b4',
        'name': isHindi ? 'सफल (मदर डेयरी) ताज़ा संकलन केंद्र' : 'Safal (Mother Dairy) Fresh Hub',
        'type': isHindi ? 'फल-सब्जी रिटेल चेन' : 'Fruit & Veg Retail Chain',
        'crop': isHindi ? 'टमाटर, आलू, प्याज, मौसमी सब्जियां' : 'Tomato, Potato, Onion & Veg',
        'cropCategory': 'vegetable',
        'rating': '4.9',
        'deals': '560+ किसान',
        'badge': isHindi ? '✓ दैनिक तौल व कैश/DBT' : '✓ Daily Weighing & DBT',
        'phone': '+91 94701 55290',
        'location': isHindi ? 'रांची-पलामू हाईवे कलेक्शन सेंटर' : 'Highway Collection Centre',
        'demand': isHindi ? 'ग्रेड A/B सब्जियां | दैनिक खरीद' : 'Grade A/B Fresh Veg | Daily',
        'offerPrice': '₹1,850 - ₹2,400 / Qtl',
      },
      {
        'id': 'b5',
        'name': isHindi ? 'पतंजलि ऑर्गेनिक खरीद व रिसर्च केंद्र' : 'Patanjali Organic Agro Hub',
        'type': isHindi ? 'आयुर्वेदिक व हर्बल प्रोसेसर' : 'Herbal & Ayurvedic Buyer',
        'crop': isHindi ? 'अश्वगंधा, तुलसी, लहसुन, औषधीय फसलें' : 'Ashwagandha, Tulsi, Garlic, Herbs',
        'cropCategory': 'commercial',
        'rating': '4.7',
        'deals': '125+ किसान',
        'badge': isHindi ? '✓ ऑर्गेनिक प्रीमियम बोनस' : '✓ Organic Premium Bonus',
        'phone': '+91 98350 49182',
        'location': isHindi ? 'हरिद्वार / झारखंड रीजनल डिपो' : 'Jharkhand Regional Depot',
        'demand': isHindi ? 'सूखी जड़ी-बूटियां व बायो-प्रमाणित' : 'Dry herbs & Certified lots',
        'offerPrice': '₹18,500 - ₹28,000 / Qtl',
      },
      {
        'id': 'b6',
        'name': isHindi ? 'पलामू कृषक उत्पादक कंपनी (Certified FPO)' : 'Palamu Farmer Producer Co. (FPO)',
        'type': isHindi ? 'किसान FPO सहकारी समिति' : 'Farmer Producer Org (FPO)',
        'crop': isHindi ? 'मक्का, दलहन, गेहूं, सरसों' : 'Maize, Pulses, Wheat, Mustard',
        'cropCategory': 'grain',
        'rating': '4.8',
        'deals': '490+ किसान सदस्य',
        'badge': isHindi ? '✓ बिना बिचौलिया सीधी खरीद' : '✓ Direct No Middleman',
        'phone': '+91 94311 02938',
        'location': isHindi ? 'गढ़वा रोड, पलामू' : 'Garhwa Road, Palamu',
        'demand': isHindi ? 'सभी सदस्यों व स्थानीय किसानों हेतु' : 'Open for all regional farmers',
        'offerPrice': 'मंडी भाव + ₹50 बोनस',
      },
    ];

    // Category Filter
    final filtered = buyers.where((b) {
      if (_buyerFilter == 'all') return true;
      return b['cropCategory'] == _buyerFilter;
    }).toList();

    // Dynamic prioritization of buyers matching currently selected crop
    filtered.sort((a, b) {
      final aCrop = a['crop'] as String;
      final bCrop = b['crop'] as String;
      final aMatch = aCrop.toLowerCase().contains(_selectedCrop.toLowerCase()) ||
          aCrop.toLowerCase().contains(_formatCropChip(_selectedCrop, isHindi).toLowerCase());
      final bMatch = bCrop.toLowerCase().contains(_selectedCrop.toLowerCase()) ||
          bCrop.toLowerCase().contains(_formatCropChip(_selectedCrop, isHindi).toLowerCase());
      if (aMatch && !bMatch) return -1;
      if (!aMatch && bMatch) return 1;
      return 0;
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Category Filters
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: [
              _buildBuyerFilterChip('all', isHindi ? 'सभी खरीदार' : 'All Buyers'),
              _buildBuyerFilterChip('oilseed', isHindi ? 'तिलहन (सरसों/सोया)' : 'Oilseeds'),
              _buildBuyerFilterChip('grain', isHindi ? 'अनाज (गेहूं/मक्का/धान)' : 'Grains'),
              _buildBuyerFilterChip('vegetable', isHindi ? 'सब्जियां (टमाटर/आलू)' : 'Vegetables'),
              _buildBuyerFilterChip('govt', isHindi ? 'सरकारी MSP / FPO' : 'Govt / FPO'),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // Active Farmer Inquiries Tracker (If farmer sent requests)
        if (inquiries.isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF9E6),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE5DFC9)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isHindi ? 'आपकी भेजी गई खरीद इंक्वायरी (${inquiries.length})' : 'Your Active Inquiries (${inquiries.length})',
                      style: const TextStyle(fontFamily: 'Mukta', fontSize: 13.5, fontWeight: FontWeight.w600, color: Color(0xFF8A5600)),
                    ),
                    const Icon(Icons.mark_email_read_rounded, size: 16, color: Color(0xFF8A5600)),
                  ],
                ),
                const SizedBox(height: 6),
                ...inquiries.take(2).map((inq) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            '• ${inq['buyerName']}: ${inq['crop']} (${inq['quantity']}) @ ${inq['price']}',
                            style: const TextStyle(fontFamily: 'Mukta', fontSize: 12, color: AppColors.textDark),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE2EFDF),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                inq['status'] as String,
                                style: const TextStyle(fontFamily: 'Mukta', fontSize: 9.5, fontWeight: FontWeight.w600, color: Color(0xFF1E4D2B)),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close_rounded, size: 14, color: AppColors.textMuted),
                              visualDensity: VisualDensity.compact,
                              padding: EdgeInsets.zero,
                              onPressed: () => _storage.deleteBuyerInquiry(inq['id'] as String),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],

        // Buyers Cards List
        ...filtered.map((b) {
          final bCrop = b['crop'] as String;
          final isCropMatch = bCrop.toLowerCase().contains(_selectedCrop.toLowerCase()) ||
              bCrop.toLowerCase().contains(_formatCropChip(_selectedCrop, isHindi).toLowerCase());

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: isCropMatch ? const Color(0xFFB37400).withOpacity(0.5) : AppColors.borderLight, width: isCropMatch ? 1.5 : 1),
              boxShadow: const [
                BoxShadow(
                  color: AppColors.cardShadow,
                  offset: Offset(0, 2),
                  blurRadius: 0,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row: Name + Star + Verified Badges
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: isCropMatch ? const Color(0xFFFFF4D6) : AppColors.mintTint,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Icon(
                          isCropMatch ? Icons.star_rounded : Icons.verified_rounded,
                          color: isCropMatch ? const Color(0xFFB37400) : AppColors.primaryGreen,
                          size: 22,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  b['name'] as String,
                                  style: const TextStyle(
                                    fontFamily: 'Mukta',
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textDark,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            '${b['type']} · ${b['location']}',
                            style: const TextStyle(
                              fontFamily: 'Mukta',
                              fontSize: 12,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE2EFDF),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star_rounded, size: 12, color: Color(0xFFB37400)),
                          const SizedBox(width: 2),
                          Text(
                            b['rating'] as String,
                            style: const TextStyle(fontFamily: 'Mukta', fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF1E4D2B)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // Demand & Offer Row
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9F7F1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          '${isHindi ? "खरीद" : "Buys"}: ${b['crop']}',
                          style: const TextStyle(fontFamily: 'Mukta', fontSize: 12, color: Color(0xFF435348)),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        b['offerPrice'] as String,
                        style: const TextStyle(fontFamily: 'Mukta', fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF1E4D2B)),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),
                const Divider(height: 1, color: Color(0xFFEEE8DA)),
                const SizedBox(height: 8),

                // 3 Action Buttons: [📞 कॉल करें] [💬 कोटेशन मांगें] [🌾 सीधे बेचें]
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () => _showBuyerContactSheet(b, isHindi),
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 7),
                          decoration: BoxDecoration(
                            color: AppColors.mintTint,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.call_rounded, size: 13, color: AppColors.primaryGreen),
                              const SizedBox(width: 4),
                              Text(
                                isHindi ? 'कॉल करें' : 'Call',
                                style: const TextStyle(fontFamily: 'Mukta', fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primaryGreen),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: InkWell(
                        onTap: () => _showRequestQuoteModal(b, isHindi),
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 7),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF4D6),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.chat_bubble_outline_rounded, size: 13, color: Color(0xFF8A5600)),
                              const SizedBox(width: 4),
                              Text(
                                isHindi ? 'कोटेशन मांगें' : 'Quote',
                                style: const TextStyle(fontFamily: 'Mukta', fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF8A5600)),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: InkWell(
                        onTap: () => _showPostBatchModal(isHindi, targetBuyer: b['name'] as String),
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 7),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF6F2E9),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFFDDD6C4)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.add_shopping_cart_rounded, size: 13, color: Color(0xFF1B2A21)),
                              const SizedBox(width: 4),
                              Text(
                                isHindi ? 'सीधे बेचें' : 'Sell Lot',
                                style: const TextStyle(fontFamily: 'Mukta', fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF1B2A21)),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildBuyerFilterChip(String key, String label) {
    final isSel = _buyerFilter == key;
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: GestureDetector(
        onTap: () => setState(() => _buyerFilter = key),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: isSel ? AppColors.primaryGreen : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: isSel ? AppColors.primaryGreen : const Color(0xFFDDD6C4)),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontFamily: 'Mukta',
              fontSize: 11.5,
              fontWeight: isSel ? FontWeight.w600 : FontWeight.w400,
              color: isSel ? Colors.white : AppColors.textDark,
            ),
          ),
        ),
      ),
    );
  }
}
