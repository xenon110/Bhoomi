import 'package:flutter/material.dart';
import '../../l10n/app_strings.dart';
import '../../models/rental_equipment.dart';
import '../../services/storage_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/safe_local_image.dart';
import 'equipment_detail_screen.dart';

class EquipmentRentalScreen extends StatefulWidget {
  const EquipmentRentalScreen({Key? key}) : super(key: key);

  @override
  State<EquipmentRentalScreen> createState() => _EquipmentRentalScreenState();
}

class _EquipmentRentalScreenState extends State<EquipmentRentalScreen> {
  final StorageService _storage = StorageService();
  String _selectedCategory = 'All';
  String _searchQuery = '';
  final TextEditingController _searchCtrl = TextEditingController();
  bool get isHindi => AppLanguage().isHindi;

  final List<String> _categories = [
    'All',
    'Tractor',
    'Harvester',
    'Tillage',
    'Drone',
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

  void _showAddEquipmentModal(BuildContext context) {
    final profile = _storage.getProfile();
    final nameCtrl = TextEditingController();
    String category = 'Tractor';
    final hourlyCtrl = TextEditingController(text: '500');
    final dailyCtrl = TextEditingController(text: '3800');
    final ownerCtrl = TextEditingController(text: profile.name);
    final phoneCtrl = TextEditingController(text: profile.phone);
    final villageCtrl = TextEditingController(text: profile.village);
    final isHindi = AppLanguage().isHindi;
    bool withDriver = true;
    String dieselPolicy = isHindi ? 'Diesel provided by farmer (डीजल किसान का)' : 'Diesel provided by farmer';
    String selectedPhoto = 'assets/images/tractor_rental.jpg';

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
                    isHindi ? 'अपना कृषि यंत्र किराये पर चढ़ाएं' : 'List Your Farm Equipment for Rent',
                    style: const TextStyle(
                      fontFamily: 'Mukta',
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1B2A21),
                    ),
                  ),
                  Text(
                    isHindi ? 'अपना कृषि यंत्र किराये पर चढ़ाएं और अतिरिक्त कमाई करें' : 'Rent out your machinery to earn extra income',
                    style: const TextStyle(
                      fontFamily: 'Mukta',
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF55655A),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Machine Name
                  TextField(
                    controller: nameCtrl,
                    decoration: InputDecoration(
                      labelText: isHindi ? 'यंत्र का नाम व मॉडल (उदा. Swaraj 744 FE 48 HP)' : 'Equipment Name & Model (e.g. Swaraj 744 FE 48 HP)',
                      labelStyle: const TextStyle(fontFamily: 'Mukta', fontSize: 13, color: Color(0xFF55655A)),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Category Selector
                  DropdownButtonFormField<String>(
                    value: category,
                    decoration: InputDecoration(
                      labelText: isHindi ? 'यंत्र श्रेणी' : 'Equipment Category',
                      labelStyle: const TextStyle(fontFamily: 'Mukta', fontSize: 13, color: Color(0xFF55655A)),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                    items: [
                      DropdownMenuItem(value: 'Tractor', child: Text(isHindi ? 'Tractor (ट्रैक्टर)' : 'Tractor')),
                      DropdownMenuItem(value: 'Harvester', child: Text(isHindi ? 'Combine Harvester (हार्वेस्टर)' : 'Combine Harvester')),
                      DropdownMenuItem(value: 'Tillage', child: Text(isHindi ? 'Rotavator / Cultivator (जुताई यंत्र)' : 'Rotavator / Cultivator')),
                      DropdownMenuItem(value: 'Drone', child: Text(isHindi ? 'Spraying Drone (ड्रोन)' : 'Spraying Drone')),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        setModalState(() {
                          category = val;
                          if (val == 'Tractor' || val == 'Tillage') {
                            selectedPhoto = 'assets/images/tractor_rental.jpg';
                          } else if (val == 'Harvester') {
                            selectedPhoto = 'assets/images/farmer_field.jpg';
                          } else {
                            selectedPhoto = 'assets/images/optimized_farmland.jpg';
                          }
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 12),

                  // Rates
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: hourlyCtrl,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Rate / Hour (₹)',
                            labelStyle: const TextStyle(fontFamily: 'Mukta', fontSize: 13, color: Color(0xFF55655A)),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: dailyCtrl,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Rate / Day (₹)',
                            labelStyle: const TextStyle(fontFamily: 'Mukta', fontSize: 13, color: Color(0xFF55655A)),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Owner Details
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: ownerCtrl,
                          decoration: InputDecoration(
                            labelText: 'Owner Name',
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
                      labelText: 'Contact Phone Number',
                      labelStyle: const TextStyle(fontFamily: 'Mukta', fontSize: 13, color: Color(0xFF55655A)),
                      prefixIcon: const Icon(Icons.phone_outlined, color: Color(0xFF1E4D2B), size: 18),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // With Driver Switch
                  SwitchListTile(
                    title: Text(
                      isHindi ? 'चालक सहित (Driver Included)' : 'Driver / Operator Included',
                      style: const TextStyle(fontFamily: 'Mukta', fontSize: 13.5, fontWeight: FontWeight.w500),
                    ),
                    value: withDriver,
                    activeColor: const Color(0xFF1E4D2B),
                    contentPadding: EdgeInsets.zero,
                    onChanged: (val) => setModalState(() => withDriver = val),
                  ),
                  const SizedBox(height: 16),

                  // Submit CTA
                  GestureDetector(
                    onTap: () async {
                      final name = nameCtrl.text.trim();
                      if (name.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please enter equipment name')),
                        );
                        return;
                      }

                      final newEq = RentalEquipment(
                        id: 'eq_${DateTime.now().millisecondsSinceEpoch}',
                        name: name,
                        category: category,
                        ratePerHour: int.tryParse(hourlyCtrl.text) ?? 500,
                        ratePerDay: int.tryParse(dailyCtrl.text) ?? 3800,
                        ownerName: ownerCtrl.text.trim().isNotEmpty ? ownerCtrl.text.trim() : profile.name,
                        ownerPhone: phoneCtrl.text.trim().isNotEmpty ? phoneCtrl.text.trim() : profile.phone,
                        village: villageCtrl.text.trim().isNotEmpty ? villageCtrl.text.trim() : profile.village,
                        district: profile.district,
                        distanceKm: 0.8,
                        imagePath: selectedPhoto,
                        rating: 5.0,
                        totalBookings: 1,
                        withDriver: withDriver,
                        dieselPolicy: dieselPolicy,
                        description: 'Recently listed by farmer in ${villageCtrl.text.trim()}. Available for immediate rental booking.',
                        specs: {
                          'Status': 'Verified Local Listing',
                          'Driver': withDriver ? 'Driver Included' : 'Self Operated',
                          'Fuel': 'Diesel by renter',
                        },
                        isUserListed: true,
                      );

                      await _storage.addRentalEquipment(newEq);
                      Navigator.pop(ctx);

                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              '✓ ${newEq.name} is now listed for rent in ${newEq.village}!',
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
                        'Publish Rental Listing →',
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
    final allEquipment = _storage.getRentalEquipment();
    final filtered = allEquipment.where((eq) {
      final matchesCategory = _selectedCategory == 'All' || eq.category.toLowerCase() == _selectedCategory.toLowerCase();
      final matchesSearch = _searchQuery.isEmpty ||
          eq.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          eq.village.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          eq.category.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
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
              isHindi ? 'कृषि यंत्र किराया' : 'Equipment Rental Hub',
              style: const TextStyle(
                fontFamily: 'Mukta',
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1B2A21),
              ),
            ),
            Text(
              isHindi ? 'कृषि यंत्र किराया · डायरेक्ट किसान से' : 'Farm Equipment Rental · Direct from Owners',
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
            tooltip: 'Add Equipment',
            onPressed: () => _showAddEquipmentModal(context),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Banner to add equipment
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
                        'Have a Tractor or Harvester?',
                        style: TextStyle(
                          fontFamily: 'Mukta',
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Rent it out to nearby farmers & earn ₹2,000–₹5,000 daily.',
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
                  onTap: () => _showAddEquipmentModal(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF2B134),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Text(
                      '+ Rent Out',
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
                      hintText: 'Search tractor, harvester, drone, village...',
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

          // Category Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _categories.map((cat) {
                final isSelected = _selectedCategory == cat;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedCategory = cat),
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
                        cat,
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
                'Available Equipment (${filtered.length})',
                style: const TextStyle(
                  fontFamily: 'Mukta',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1B2A21),
                ),
              ),
              const Row(
                children: [
                  Icon(Icons.tune_rounded, size: 16, color: Color(0xFF1E4D2B)),
                  SizedBox(width: 4),
                  Text(
                    'Palamu District',
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

          // Equipment Card List
          ...filtered.map((eq) => _buildEquipmentCard(eq)).toList(),

          if (filtered.isEmpty)
            Container(
              padding: const EdgeInsets.all(32),
              alignment: Alignment.center,
              child: const Column(
                children: [
                  Icon(Icons.agriculture_rounded, size: 48, color: Color(0xFFBDC7BE)),
                  SizedBox(height: 10),
                  Text(
                    'No equipment matching your criteria',
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

  Widget _buildEquipmentCard(RentalEquipment eq) {
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
              builder: (_) => EquipmentDetailScreen(equipment: eq),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image with Category Pill & Distance
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
                  child: SafeLocalImage(
                    imagePath: eq.imagePath,
                    width: double.infinity,
                    height: 155,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E4D2B),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      eq.category,
                      style: const TextStyle(
                        fontFamily: 'Mukta',
                        fontSize: 11,
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
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.location_on_rounded, size: 13, color: Color(0xFF1E4D2B)),
                        const SizedBox(width: 3),
                        Text(
                          '${eq.distanceKm} km',
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
                if (eq.isUserListed)
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
                          eq.name,
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
                      Row(
                        children: [
                          const Icon(Icons.star_rounded, color: Color(0xFFF2B134), size: 16),
                          const SizedBox(width: 2),
                          Text(
                            '${eq.rating}',
                            style: const TextStyle(
                              fontFamily: 'Mukta',
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1B2A21),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),

                  // Owner & Village
                  Text(
                    '${eq.ownerName} · ${eq.village}',
                    style: const TextStyle(
                      fontFamily: 'Mukta',
                      fontSize: 12.5,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF55655A),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Rate & Action Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '₹${eq.ratePerHour} / hr',
                            style: const TextStyle(
                              fontFamily: 'Mukta',
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1E4D2B),
                            ),
                          ),
                          Text(
                            'or ₹${eq.ratePerDay}/day',
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
                              'View & Book',
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

