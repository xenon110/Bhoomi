import 'package:flutter/material.dart';
import '../../l10n/app_strings.dart';
import '../../models/farmland_listing.dart';
import '../../services/storage_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/safe_local_image.dart';
import 'land_detail_screen.dart';

class LandMarketplaceScreen extends StatefulWidget {
  const LandMarketplaceScreen({Key? key}) : super(key: key);

  @override
  State<LandMarketplaceScreen> createState() => _LandMarketplaceScreenState();
}

class _LandMarketplaceScreenState extends State<LandMarketplaceScreen> {
  final StorageService _storage = StorageService();
  String _selectedFilter = 'All';
  String _searchQuery = '';
  final TextEditingController _searchCtrl = TextEditingController();
  bool get isHindi => AppLanguage().isHindi;

  final List<String> _filters = [
    'All',
    '< 3 Acres',
    '3 - 5 Acres',
    '> 5 Acres',
    'With Borewell',
  ];

  @override
  void initState() {
    super.initState();
    _storage.addListener(_onStorageChange);
  }

  @override
  void dispose() {
    _storage.removeListener(_onStorageChange);
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onStorageChange() {
    if (mounted) setState(() {});
  }

  void _showPostLandModal(BuildContext context) {
    final profile = _storage.getProfile();
    final titleCtrl = TextEditingController(text: '3.0 Acres Fertile Land in ${profile.village}');
    final acresCtrl = TextEditingController(text: '3.0');
    final pricePerAcreCtrl = TextEditingController(text: '7.5');
    final sellerCtrl = TextEditingController(text: profile.name);
    final phoneCtrl = TextEditingController(text: profile.phone);
    final villageCtrl = TextEditingController(text: profile.village);
    final isHindi = AppLanguage().isHindi;
    String waterSource = isHindi ? 'बोरवेल / सबमर्सिबल नल' : 'Borewell / Submersible';
    String soilType = isHindi ? 'काली दोमट' : 'Black Loam';
    String roadAccess = isHindi ? 'पक्की सड़क' : 'Direct Paved Road';
    String selectedPhoto = 'assets/images/farmland_sale.jpg';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (modalCtx, setModalState) {
          return Container(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 20,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
            ),
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
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFFDDD6C4),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    isHindi ? 'अपनी कृषि जमीन बिक्री के लिए जोड़ें' : 'Post Your Farmland for Sale',
                    style: const TextStyle(
                      fontFamily: 'Mukta',
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1B2A21),
                    ),
                  ),
                  Text(
                    isHindi ? 'अपनी कृषि जमीन बिक्री के लिए लिस्ट करें · 0% दलाली' : 'List your agricultural plot for direct buyers · 0% Commission',
                    style: const TextStyle(
                      fontFamily: 'Mukta',
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF55655A),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Title
                  TextField(
                    controller: titleCtrl,
                    decoration: InputDecoration(
                      labelText: 'Listing Title (e.g. 2.5 Acres Fertile Plot)',
                      labelStyle: const TextStyle(fontFamily: 'Mukta', fontSize: 13, color: Color(0xFF55655A)),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Acres & Price per Acre
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: acresCtrl,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: InputDecoration(
                            labelText: 'Total Area (Acres)',
                            labelStyle: const TextStyle(fontFamily: 'Mukta', fontSize: 13, color: Color(0xFF55655A)),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: pricePerAcreCtrl,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: InputDecoration(
                            labelText: 'Price / Acre (₹ Lakh)',
                            labelStyle: const TextStyle(fontFamily: 'Mukta', fontSize: 13, color: Color(0xFF55655A)),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Water Source
                  DropdownButtonFormField<String>(
                    value: waterSource,
                    decoration: InputDecoration(
                      labelText: isHindi ? 'सिंचाई / जल स्रोत' : 'Water & Irrigation Source',
                      labelStyle: const TextStyle(fontFamily: 'Mukta', fontSize: 13, color: Color(0xFF55655A)),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                    items: [
                      DropdownMenuItem(value: isHindi ? 'बोरवेल / सबमर्सिबल नल' : 'Borewell / Submersible', child: Text(isHindi ? 'बोरवेल / सबमर्सिबल' : 'Borewell / Submersible')),
                      DropdownMenuItem(value: isHindi ? 'नहर सिंचित' : 'Canal Irrigation', child: Text(isHindi ? 'नहर सिंचित' : 'Canal / River Irrigation')),
                      DropdownMenuItem(value: isHindi ? 'कुआं पंप' : 'Open Well with Pump', child: Text(isHindi ? 'कुआं पंप' : 'Open Well with Pump')),
                      DropdownMenuItem(value: isHindi ? 'वर्षा आधारित' : 'Rainfed Farmland', child: Text(isHindi ? 'वर्षा आधारित' : 'Rainfed Farmland')),
                    ],
                    onChanged: (val) {
                      if (val != null) setModalState(() => waterSource = val);
                    },
                  ),
                  const SizedBox(height: 12),

                  // Soil Type
                  DropdownButtonFormField<String>(
                    value: soilType,
                    decoration: InputDecoration(
                      labelText: isHindi ? 'मिट्टी का प्रकार' : 'Soil Type',
                      labelStyle: const TextStyle(fontFamily: 'Mukta', fontSize: 13, color: Color(0xFF55655A)),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                    items: [
                      DropdownMenuItem(value: isHindi ? 'काली दोमट' : 'Black Loam', child: Text(isHindi ? 'काली दोमट' : 'Black Loam')),
                      DropdownMenuItem(value: isHindi ? 'चिकनी मिट्टी' : 'Clay Loam', child: Text(isHindi ? 'चिकनी मिट्टी' : 'Clay Loam')),
                      DropdownMenuItem(value: isHindi ? 'जलोढ़ मिट्टी' : 'Alluvial Soil', child: Text(isHindi ? 'जलोढ़ मिट्टी' : 'Alluvial Soil')),
                      DropdownMenuItem(value: isHindi ? 'बलुई दोमट' : 'Sandy Loam', child: Text(isHindi ? 'बलुई दोमट' : 'Sandy Loam')),
                    ],
                    onChanged: (val) {
                      if (val != null) setModalState(() => soilType = val);
                    },
                  ),
                  const SizedBox(height: 12),

                  // Seller & Village
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: sellerCtrl,
                          decoration: InputDecoration(
                            labelText: 'Owner / Seller Name',
                            labelStyle: const TextStyle(fontFamily: 'Mukta', fontSize: 13, color: Color(0xFF55655A)),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: villageCtrl,
                          decoration: InputDecoration(
                            labelText: 'Village Name',
                            labelStyle: const TextStyle(fontFamily: 'Mukta', fontSize: 13, color: Color(0xFF55655A)),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  TextField(
                    controller: phoneCtrl,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: 'Mobile Phone for Direct Buyers',
                      labelStyle: const TextStyle(fontFamily: 'Mukta', fontSize: 13, color: Color(0xFF55655A)),
                      prefixIcon: const Icon(Icons.phone_outlined, color: Color(0xFF1E4D2B), size: 18),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Submit CTA
                  GestureDetector(
                    onTap: () async {
                      final title = titleCtrl.text.trim();
                      final acres = double.tryParse(acresCtrl.text) ?? 2.0;
                      final pricePerAcre = double.tryParse(pricePerAcreCtrl.text) ?? 8.0;
                      final totalPrice = acres * pricePerAcre;

                      final newLand = FarmlandListing(
                        id: 'land_${DateTime.now().millisecondsSinceEpoch}',
                        title: title.isNotEmpty ? title : '$acres Acres Plot in ${villageCtrl.text}',
                        totalAcres: acres,
                        pricePerAcreLakhs: pricePerAcre,
                        totalPriceLakhs: double.parse(totalPrice.toStringAsFixed(2)),
                        village: villageCtrl.text.trim().isNotEmpty ? villageCtrl.text.trim() : profile.village,
                        district: profile.district,
                        distanceKm: 1.2,
                        sellerName: sellerCtrl.text.trim().isNotEmpty ? sellerCtrl.text.trim() : profile.name,
                        sellerPhone: phoneCtrl.text.trim().isNotEmpty ? phoneCtrl.text.trim() : profile.phone,
                        waterSource: waterSource,
                        soilType: soilType,
                        roadAccess: roadAccess,
                        titleStatus: 'Clear Title · 100% Registry Ready',
                        imagePath: selectedPhoto,
                        description: 'Direct owner listing in ${villageCtrl.text}. Suitable for multi-crop rotation. Peaceful location with direct road approach.',
                        suitableCrops: ['Mustard', 'Wheat', 'Vegetables'],
                        isUserListed: true,
                      );

                      await _storage.addFarmlandListing(newLand);
                      Navigator.pop(ctx);

                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              '✓ Your ${newLand.totalAcres} Acres land in ${newLand.village} is now listed for sale!',
                              style: const TextStyle(fontFamily: 'Mukta', fontWeight: FontWeight.w500),
                            ),
                            backgroundColor: const Color(0xFF1E4D2B),
                            duration: const Duration(seconds: 3),
                          ),
                        );
                      }
                    },
                    child: Container(
                      width: double.infinity,
                      height: 50,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E4D2B),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0xFF123320),
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: const Text(
                        'Publish Land Listing →',
                        style: TextStyle(
                          fontFamily: 'Mukta',
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
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
    );
  }

  @override
  Widget build(BuildContext context) {
    final allLand = _storage.getFarmlandListings();
    final filtered = allLand.where((l) {
      bool matchesFilter = true;
      if (_selectedFilter == '< 3 Acres') matchesFilter = l.totalAcres < 3.0;
      if (_selectedFilter == '3 - 5 Acres') matchesFilter = l.totalAcres >= 3.0 && l.totalAcres <= 5.0;
      if (_selectedFilter == '> 5 Acres') matchesFilter = l.totalAcres > 5.0;
      if (_selectedFilter == 'With Borewell') matchesFilter = l.waterSource.toLowerCase().contains('borewell');

      final matchesSearch = _searchQuery.isEmpty ||
          l.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          l.village.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          l.soilType.toLowerCase().contains(_searchQuery.toLowerCase());

      return matchesFilter && matchesSearch;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.creamBg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 1,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isHindi ? 'किसान भूमि बाज़ार' : 'Farmland Marketplace',
              style: const TextStyle(
                fontFamily: 'Mukta',
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1B2A21),
              ),
            ),
            Text(
              isHindi ? 'कृषि जमीन खरीदें व बेचें · 0% दलाली' : 'Direct Farmland Trading · 0% Commission',
              style: const TextStyle(
                fontFamily: 'Mukta',
                fontSize: 11,
                fontWeight: FontWeight.w400,
                color: Color(0xFF55655A),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline_rounded, color: Color(0xFF1E4D2B)),
            tooltip: 'Sell Land',
            onPressed: () => _showPostLandModal(context),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Banner to post land
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1E4D2B), Color(0xFF15381F)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(22),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x331E4D2B),
                  offset: Offset(0, 4),
                  blurRadius: 8,
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Want to Sell Agricultural Land?',
                        style: TextStyle(
                          fontFamily: 'Mukta',
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Connect with genuine verified local buyers. Zero commission.',
                        style: TextStyle(
                          fontFamily: 'Mukta',
                          fontSize: 11.5,
                          fontWeight: FontWeight.w400,
                          color: Colors.white.withOpacity(0.85),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: () => _showPostLandModal(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF2B134),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Text(
                      '+ Sell Land',
                      style: TextStyle(
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

          const SizedBox(height: 14),

          // Search Bar
          Container(
            height: 46,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE6E0D2)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                const Icon(Icons.search_rounded, color: Color(0xFF55655A), size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _searchCtrl,
                    onChanged: (val) => setState(() => _searchQuery = val.trim()),
                    decoration: const InputDecoration(
                      hintText: 'Search village, acreage, borewell...',
                      hintStyle: TextStyle(fontFamily: 'Mukta', fontSize: 13, color: Color(0xFF88998C)),
                      border: InputBorder.none,
                      isDense: true,
                    ),
                  ),
                ),
                if (_searchQuery.isNotEmpty)
                  GestureDetector(
                    onTap: () {
                      _searchCtrl.clear();
                      setState(() => _searchQuery = '');
                    },
                    child: const Icon(Icons.close_rounded, size: 18, color: Color(0xFF55655A)),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _filters.map((flt) {
                final isSelected = _selectedFilter == flt;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedFilter = flt),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFF1E4D2B) : Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isSelected ? const Color(0xFF1E4D2B) : const Color(0xFFDDD6C4),
                        ),
                      ),
                      child: Text(
                        flt,
                        style: TextStyle(
                          fontFamily: 'Mukta',
                          fontSize: 12.5,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                          color: isSelected ? Colors.white : const Color(0xFF1B2A21),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 16),

          // Listings header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Available Farmland Plots (${filtered.length})',
                style: const TextStyle(
                  fontFamily: 'Mukta',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1B2A21),
                ),
              ),
              const Row(
                children: [
                  Icon(Icons.verified_rounded, size: 16, color: Color(0xFF1E4D2B)),
                  SizedBox(width: 4),
                  Text(
                    'Direct Sellers Only',
                    style: TextStyle(
                      fontFamily: 'Mukta',
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF1E4D2B),
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Land Cards
          ...filtered.map((land) => _buildLandCard(land)).toList(),

          if (filtered.isEmpty)
            Container(
              padding: const EdgeInsets.all(32),
              alignment: Alignment.center,
              child: const Column(
                children: [
                  Icon(Icons.terrain_rounded, size: 48, color: Color(0xFFBDC7BE)),
                  SizedBox(height: 10),
                  Text(
                    'No land listings matching your search',
                    style: TextStyle(
                      fontFamily: 'Mukta',
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF55655A),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLandCard(FarmlandListing land) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
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
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => LandDetailScreen(land: land),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image with Acreage Pill & Verified Status
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
                  child: SafeLocalImage(
                    imagePath: land.imagePath,
                    width: double.infinity,
                    height: 160,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E4D2B),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${land.totalAcres} Acres',
                      style: const TextStyle(
                        fontFamily: 'Mukta',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.92),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.location_on_rounded, size: 13, color: Color(0xFF1E4D2B)),
                        const SizedBox(width: 3),
                        Text(
                          '${land.distanceKm} km',
                          style: const TextStyle(
                            fontFamily: 'Mukta',
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1B2A21),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (land.isUserListed)
                  Positioned(
                    bottom: 10,
                    left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF2B134),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'Your Listing',
                        style: TextStyle(
                          fontFamily: 'Mukta',
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1B2A21),
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            // Card Body
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          land.title,
                          style: const TextStyle(
                            fontFamily: 'Mukta',
                            fontSize: 16.5,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1B2A21),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),

                  // Village & District
                  Text(
                    '${land.village}, ${land.district} · Owner: ${land.sellerName}',
                    style: const TextStyle(
                      fontFamily: 'Mukta',
                      fontSize: 12.5,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF55655A),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Feature badges
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFDDEBF3),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          land.waterSource.contains('Borewell') ? '💧 Borewell' : '💧 Irrigated',
                          style: const TextStyle(
                            fontFamily: 'Mukta',
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF18566F),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE2EFDF),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          '🛣️ Road Access',
                          style: TextStyle(
                            fontFamily: 'Mukta',
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF1E4D2B),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFCEFD0),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          '📜 Clear Title',
                          style: TextStyle(
                            fontFamily: 'Mukta',
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF8A5600),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // Price & Action Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '₹${land.pricePerAcreLakhs} Lakh / Acre',
                            style: const TextStyle(
                              fontFamily: 'Mukta',
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1E4D2B),
                            ),
                          ),
                          Text(
                            'Total: ₹${land.totalPriceLakhs} Lakh',
                            style: const TextStyle(
                              fontFamily: 'Mukta',
                              fontSize: 11,
                              fontWeight: FontWeight.w400,
                              color: Color(0xFF55655A),
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E4D2B),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Row(
                          children: [
                            Text(
                              'View Details',
                              style: TextStyle(
                                fontFamily: 'Mukta',
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(width: 4),
                            Icon(Icons.arrow_forward_rounded, size: 14, color: Colors.white),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

