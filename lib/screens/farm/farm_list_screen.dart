import 'package:flutter/material.dart';
import '../../models/farm.dart';
import '../../services/storage_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/safe_local_image.dart';
import 'farm_detail_screen.dart';

class FarmListScreen extends StatefulWidget {
  const FarmListScreen({Key? key}) : super(key: key);

  @override
  State<FarmListScreen> createState() => _FarmListScreenState();
}

class _FarmListScreenState extends State<FarmListScreen> {
  final StorageService _storage = StorageService();
  late List<Farm> _farms;

  @override
  void initState() {
    super.initState();
    _loadFarms();
  }

  void _loadFarms() {
    final primary = _storage.getPrimaryFarm();
    setState(() {
      _farms = [primary];
    });
  }

  String _getCropImagePath(String cropName) {
    final nameLower = cropName.toLowerCase();
    if (nameLower.contains('mustard') || nameLower.contains('sarson')) {
      return 'assets/images/mustard_crop.jpg';
    } else if (nameLower.contains('wheat') || nameLower.contains('gehun')) {
      return 'assets/images/wheat_crop.jpg';
    } else {
      return 'assets/images/farmer_field.jpg';
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: AppColors.creamBg,
      body: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Bar
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.maybePop(context),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: AppStyles.backButtonBox,
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
                          'YOUR HOLDINGS',
                          style: TextStyle(
                            fontFamily: 'Mukta',
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.1,
                            color: AppColors.textMuted,
                          ),
                        ),
                        Text(
                          'Farm Lands',
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
              const SizedBox(height: 18),

              // Farm List
              Expanded(
                child: ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  itemCount: _farms.length,
                  itemBuilder: (context, index) {
                    final farm = _farms[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: const Color(0xFFE6E0D2)),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0xFFE9E2D1),
                            offset: Offset(0, 4),
                            blurRadius: 0,
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: InkWell(
                          onTap: () async {
                            await Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => FarmDetailScreen(farm: farm)),
                            );
                            _loadFarms();
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Farm Hero Image Banner
                              Stack(
                                children: [
                                  SizedBox(
                                    height: 130,
                                    width: double.infinity,
                                    child: const SafeLocalImage(
                                      imagePath: 'assets/images/farmer_field.jpg',
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  // Gradient Overlay
                                  Container(
                                    height: 130,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          Colors.black.withOpacity(0.15),
                                          const Color(0xFF1E4D2B).withOpacity(0.85),
                                        ],
                                      ),
                                    ),
                                  ),
                                  // Top Chip
                                  Positioned(
                                    top: 12,
                                    right: 12,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        '${farm.totalArea} Acres',
                                        style: const TextStyle(
                                          fontFamily: 'Mukta',
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF1E4D2B),
                                        ),
                                      ),
                                    ),
                                  ),
                                  // Bottom Farm Title
                                  Positioned(
                                    left: 14,
                                    bottom: 10,
                                    right: 14,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '${farm.farmerName}\'s Farm',
                                          style: const TextStyle(
                                            fontFamily: 'Mukta',
                                            fontSize: 20,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white,
                                          ),
                                        ),
                                        Text(
                                          '${farm.village}, ${farm.district}',
                                          style: TextStyle(
                                            fontFamily: 'Mukta',
                                            fontSize: 12.5,
                                            fontWeight: FontWeight.w400,
                                            color: Colors.white.withOpacity(0.9),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),

                              // Crops Row
                              Padding(
                                padding: const EdgeInsets.all(14),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          '${farm.crops.length} Registered Crops',
                                          style: const TextStyle(
                                            fontFamily: 'Mukta',
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFF1B2A21),
                                          ),
                                        ),
                                        const Row(
                                          children: [
                                            Text(
                                              'View Details',
                                              style: TextStyle(
                                                fontFamily: 'Mukta',
                                                fontSize: 12.5,
                                                fontWeight: FontWeight.w500,
                                                color: Color(0xFF1E4D2B),
                                              ),
                                            ),
                                            Icon(
                                              Icons.chevron_right_rounded,
                                              size: 16,
                                              color: Color(0xFF1E4D2B),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),

                                    // Crops Thumbnails Carousel
                                    SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: Row(
                                        children: farm.crops.map((crop) {
                                          return Container(
                                            margin: const EdgeInsets.only(right: 8),
                                            padding: const EdgeInsets.fromLTRB(6, 6, 10, 6),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFF6F2E9),
                                              borderRadius: BorderRadius.circular(14),
                                              border: Border.all(color: const Color(0xFFE6E0D2)),
                                            ),
                                            child: Row(
                                              children: [
                                                ClipRRect(
                                                  borderRadius: BorderRadius.circular(10),
                                                  child: SizedBox(
                                                    width: 32,
                                                    height: 32,
                                                    child: SafeLocalImage(
                                                      imagePath: _getCropImagePath(crop.name),
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      crop.name,
                                                      style: const TextStyle(
                                                        fontFamily: 'Mukta',
                                                        fontSize: 13,
                                                        fontWeight: FontWeight.w600,
                                                        color: Color(0xFF1B2A21),
                                                      ),
                                                    ),
                                                    Text(
                                                      '${crop.variety != null && crop.variety!.isNotEmpty ? crop.variety : "Crop"} · ${crop.growthStage ?? "Active"}',
                                                      style: const TextStyle(
                                                        fontFamily: 'Mukta',
                                                        fontSize: 10.5,
                                                        fontWeight: FontWeight.w400,
                                                        color: Color(0xFF55655A),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          );
                                        }).toList(),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: bottomInset > 0 ? bottomInset : 12),
            ],
          ),
        ),
      ),
    );
  }
}
