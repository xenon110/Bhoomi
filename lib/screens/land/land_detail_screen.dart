import 'package:flutter/material.dart';
import '../../l10n/app_strings.dart';
import '../../models/farmland_listing.dart';
import '../../theme/app_theme.dart';
import '../../widgets/safe_local_image.dart';

class LandDetailScreen extends StatelessWidget {
  final FarmlandListing land;
  bool get isHindi => AppLanguage().isHindi;

  const LandDetailScreen({Key? key, required this.land}) : super(key: key);

  void _callSeller(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Dialing seller ${land.sellerName} (${land.sellerPhone})...',
          style: const TextStyle(fontFamily: 'Mukta', fontWeight: FontWeight.w500),
        ),
        backgroundColor: const Color(0xFF1E4D2B),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _whatsappSeller(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Opening WhatsApp chat with ${land.sellerName}...',
          style: const TextStyle(fontFamily: 'Mukta', fontWeight: FontWeight.w500),
        ),
        backgroundColor: const Color(0xFF1E4D2B),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _scheduleVisit(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
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
              isHindi ? 'खेत निरीक्षण (Schedule Visit)' : 'Schedule Farmland Visit',
              style: const TextStyle(
                fontFamily: 'Mukta',
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1B2A21),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Visit ${land.totalAcres} Acres plot at ${land.village} directly with the owner.',
              style: const TextStyle(
                fontFamily: 'Mukta',
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: Color(0xFF55655A),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFE2EFDF),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Icon(Icons.verified_user_rounded, color: Color(0xFF1E4D2B), size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Zero Commission: Deal directly with farmer ${land.sellerName}. No middlemen or broker fee.',
                      style: const TextStyle(
                        fontFamily: 'Mukta',
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF1E4D2B),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            GestureDetector(
              onTap: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      '✓ Visit request sent to ${land.sellerName}! They will contact you shortly.',
                      style: const TextStyle(fontFamily: 'Mukta', fontWeight: FontWeight.w500),
                    ),
                    backgroundColor: const Color(0xFF1E4D2B),
                    duration: const Duration(seconds: 3),
                  ),
                );
              },
              child: Container(
                width: double.infinity,
                height: 50,
                decoration: BoxDecoration(
                  color: const Color(0xFF1E4D2B),
                  borderRadius: BorderRadius.circular(20),
                ),
                alignment: Alignment.center,
                child: const Text(
                  'Confirm Visit Request →',
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
  }

  @override
  Widget build(BuildContext context) {
    final isHindi = AppLanguage().isHindi;
    return Scaffold(
      backgroundColor: AppColors.creamBg,
      body: CustomScrollView(
        slivers: [
          // Hero Farmland Image
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: const Color(0xFF1E4D2B),
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: Colors.white70,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back_rounded, color: Color(0xFF1B2A21), size: 20),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: Colors.white70,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.share_outlined, color: Color(0xFF1B2A21), size: 20),
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Sharing farmland listing...')),
                  );
                },
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  SafeLocalImage(
                    imagePath: land.imagePath,
                    width: double.infinity,
                    height: 280,
                    fit: BoxFit.cover,
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    height: 70,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.black.withOpacity(0.6),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 12,
                    left: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E4D2B),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${land.totalAcres} Acres Farmland',
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
                    bottom: 12,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF2B134),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        'Verified Registry ✓',
                        style: TextStyle(
                          fontFamily: 'Mukta',
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1B2A21),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Content body
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Land Title
                  Text(
                    land.title,
                    style: const TextStyle(
                      fontFamily: 'Mukta',
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1B2A21),
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 6),

                  // Location
                  Row(
                    children: [
                      const Icon(Icons.location_on_rounded, size: 16, color: Color(0xFF1E4D2B)),
                      const SizedBox(width: 4),
                      Text(
                        '${land.village}, ${land.district} (${land.state}) · ${land.distanceKm} km away',
                        style: const TextStyle(
                          fontFamily: 'Mukta',
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF55655A),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Big Price Banner Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE2EFDF),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFCFE5CA)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isHindi ? 'प्रति एकड़ दर' : 'Price per Acre',
                              style: const TextStyle(
                                fontFamily: 'Mukta',
                                fontSize: 11.5,
                                fontWeight: FontWeight.w400,
                                color: Color(0xFF55655A),
                              ),
                            ),
                            Text(
                              '₹${land.pricePerAcreLakhs} Lakh / Acre',
                              style: const TextStyle(
                                fontFamily: 'Mukta',
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1E4D2B),
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text(
                              'Total Asking Price',
                              style: TextStyle(
                                fontFamily: 'Mukta',
                                fontSize: 11.5,
                                fontWeight: FontWeight.w400,
                                color: Color(0xFF55655A),
                              ),
                            ),
                            Text(
                              '₹${land.totalPriceLakhs} Lakh',
                              style: const TextStyle(
                                fontFamily: 'Mukta',
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1B2A21),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  // 4 Essential Land Features
                  const Text(
                    'Key Agricultural Land Details',
                    style: TextStyle(
                      fontFamily: 'Mukta',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1B2A21),
                    ),
                  ),
                  const SizedBox(height: 10),

                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFE6E0D2)),
                    ),
                    child: Column(
                      children: [
                        _buildFeatureRow(
                          icon: Icons.water_drop_rounded,
                          color: const Color(0xFF18566F),
                          bg: const Color(0xFFDDEBF3),
                          title: 'Water & Irrigation',
                          value: land.waterSource,
                        ),
                        const Divider(color: Color(0xFFEEE8DA)),
                        _buildFeatureRow(
                          icon: Icons.terrain_rounded,
                          color: const Color(0xFF8A5600),
                          bg: const Color(0xFFFCEFD0),
                          title: 'Soil Type & Quality',
                          value: land.soilType,
                        ),
                        const Divider(color: Color(0xFFEEE8DA)),
                        _buildFeatureRow(
                          icon: Icons.add_road_rounded,
                          color: const Color(0xFF1E4D2B),
                          bg: const Color(0xFFE2EFDF),
                          title: 'Road & Accessibility',
                          value: land.roadAccess,
                        ),
                        const Divider(color: Color(0xFFEEE8DA)),
                        _buildFeatureRow(
                          icon: Icons.verified_user_outlined,
                          color: const Color(0xFF2E7D32),
                          bg: const Color(0xFFE8F5E9),
                          title: 'Title & Registry Status',
                          value: land.titleStatus,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Suitable Crops
                  const Text(
                    'High Yield Suitable Crops',
                    style: TextStyle(
                      fontFamily: 'Mukta',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1B2A21),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: land.suitableCrops.map((c) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF6F2E9),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFDDD6C4)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.eco_rounded, size: 14, color: Color(0xFF1E4D2B)),
                            const SizedBox(width: 4),
                            Text(
                              c,
                              style: const TextStyle(
                                fontFamily: 'Mukta',
                                fontSize: 12.5,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF1B2A21),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 18),

                  // Description
                  const Text(
                    'Land Description',
                    style: TextStyle(
                      fontFamily: 'Mukta',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1B2A21),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    land.description,
                    style: const TextStyle(
                      fontFamily: 'Mukta',
                      fontSize: 13.5,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF55655A),
                      height: 1.4,
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Seller Profile Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFE6E0D2)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 22,
                              backgroundColor: const Color(0xFFE2EFDF),
                              child: Text(
                                land.sellerName.isNotEmpty ? land.sellerName[0] : 'K',
                                style: const TextStyle(
                                  fontFamily: 'Mukta',
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF1E4D2B),
                                ),
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
                                        land.sellerName,
                                        style: const TextStyle(
                                          fontFamily: 'Mukta',
                                          fontSize: 15.5,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF1B2A21),
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      const Icon(Icons.verified_rounded, color: Color(0xFF1E4D2B), size: 16),
                                    ],
                                  ),
                                  Text(
                                    isHindi ? '${land.village} · जमीन मालिक' : '${land.village} · Land Owner',
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
                          ],
                        ),
                        const SizedBox(height: 14),

                        // Contact Buttons
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () => _callSeller(context),
                                icon: const Icon(Icons.call_rounded, size: 16, color: Color(0xFF1E4D2B)),
                                label: const Text(
                                  'Call Owner',
                                  style: TextStyle(
                                    fontFamily: 'Mukta',
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF1E4D2B),
                                  ),
                                ),
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: Color(0xFF1E4D2B)),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () => _whatsappSeller(context),
                                icon: const Icon(Icons.chat_outlined, size: 16, color: Colors.white),
                                label: const Text(
                                  'WhatsApp',
                                  style: TextStyle(
                                    fontFamily: 'Mukta',
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF25D366),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 90),
                ],
              ),
            ),
          ),
        ],
      ),

      // Sticky Bottom Bar
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '₹${land.totalPriceLakhs} L',
                    style: const TextStyle(
                      fontFamily: 'Mukta',
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1E4D2B),
                    ),
                  ),
                  Text(
                    'Total for ${land.totalAcres} Acres',
                    style: const TextStyle(
                      fontFamily: 'Mukta',
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF55655A),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 20),
              Expanded(
                child: GestureDetector(
                  onTap: () => _scheduleVisit(context),
                  child: Container(
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
                      'Schedule Land Visit →',
                      style: TextStyle(
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
      ),
    );
  }

  Widget _buildFeatureRow({
    required IconData icon,
    required Color color,
    required Color bg,
    required String title,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Mukta',
                    fontSize: 11.5,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF55655A),
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontFamily: 'Mukta',
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1B2A21),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

