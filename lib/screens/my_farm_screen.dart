import 'package:flutter/material.dart';
import '../models/crop.dart';
import '../models/diary_entry.dart';
import '../models/farm.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';
import 'diary/farm_diary_screen.dart';
import 'farm/add_crop_screen.dart';
import 'farm/farm_detail_screen.dart';
import 'planner/farm_planner_screen.dart';
import '../widgets/safe_local_image.dart';

class MyFarmScreen extends StatefulWidget {
  final VoidCallback? onBackToHome;
  const MyFarmScreen({Key? key, this.onBackToHome}) : super(key: key);

  @override
  State<MyFarmScreen> createState() => _MyFarmScreenState();
}

class _MyFarmScreenState extends State<MyFarmScreen> {
  final StorageService _storage = StorageService();
  late Farm _farm;

  @override
  void initState() {
    super.initState();
    _loadFarmData();
    _storage.addListener(_onStorageChanged);
  }

  @override
  void dispose() {
    _storage.removeListener(_onStorageChanged);
    super.dispose();
  }

  void _onStorageChanged() {
    if (mounted) {
      _loadFarmData();
    }
  }

  void _loadFarmData() {
    setState(() {
      _farm = _storage.getPrimaryFarm();
    });
  }

  void _navigateToAddCrop() async {
    final newCrop = await Navigator.push<Crop>(
      context,
      MaterialPageRoute(builder: (_) => AddCropScreen(farm: _farm)),
    );
    if (newCrop != null) {
      await _storage.addCropToPrimaryFarm(newCrop);
      _loadFarmData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${newCrop.name} added to your farm crops!'),
            backgroundColor: const Color(0xFF1E4D2B),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F2E9),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Navigation & Header
            Row(
              children: [
                if (widget.onBackToHome != null)
                  InkWell(
                    onTap: widget.onBackToHome,
                    borderRadius: BorderRadius.circular(22),
                    child: Container(
                      width: 44,
                      height: 44,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFFDDD6C4), width: 1),
                      ),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.chevron_left_rounded,
                        size: 24,
                        color: Color(0xFF1B2A21),
                      ),
                    ),
                  ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'YOUR LAND, YOUR HARD WORK',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.8,
                          color: Color(0xFF3A6B4A),
                        ),
                      ),
                      Text(
                        'My Farm',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1B2A21),
                          height: 1.1,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            const Text(
              'Your crops and land, all in one place.',
              style: TextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.w400,
                color: Color(0xFF55655A),
              ),
            ),

            const SizedBox(height: 12),

            // Registered Land Hero Card (148px height, Box Shadow 0 4px 0 #123320)
            InkWell(
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => FarmDetailScreen(farm: _farm)),
                );
                await _storage.updatePrimaryFarm(_farm);
                _loadFarmData();
              },
              borderRadius: BorderRadius.circular(28),
              child: Container(
                width: double.infinity,
                height: 148,
                decoration: BoxDecoration(
                  color: const Color(0xFF1E4D2B),
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0xFF123320),
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(28),
                  child: Stack(
                    children: [
                      // Real Farm Field Background
                      Positioned.fill(
                        child: const SafeLocalImage(
                          imagePath: 'assets/images/farmer_field.jpg',
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                              colors: [
                                const Color(0xFF1E4D2B).withOpacity(0.96),
                                const Color(0xFF1E4D2B).withOpacity(0.70),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // Right SVG Farm Graphic (Exact polygons & furrow lines)
                      Positioned(
                        right: 0,
                        top: 0,
                        width: 190,
                        height: 148,
                        child: CustomPaint(
                          painter: _FarmParcelsSvgPainter(),
                        ),
                      ),

                      // Left Content
                      Positioned(
                        left: 18,
                        top: 16,
                        child: const Text(
                          'REGISTERED LAND',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            letterSpacing: 0.8,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Positioned(
                        left: 18,
                        top: 34,
                        child: Text(
                          _farm.totalArea > 0
                              ? '${_farm.totalArea.toInt() == _farm.totalArea ? _farm.totalArea.toInt() : _farm.totalArea} acres'
                              : '0 acres',
                          style: const TextStyle(
                            fontSize: 46,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            height: 1.1,
                          ),
                        ),
                      ),
                      Positioned(
                        left: 18,
                        bottom: 16,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.16),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFF2B134),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 7),
                              Text(
                                '${_farm.fields.length} active fields',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.white,
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
            ),

            const SizedBox(height: 14),

            // Section: Your crops with "+ Add crop"
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Your crops',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1B2A21),
                  ),
                ),
                InkWell(
                  onTap: _navigateToAddCrop,
                  borderRadius: BorderRadius.circular(22),
                  child: Container(
                    height: 44,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF2B134),
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0xFFC98F1C),
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(
                          Icons.add_rounded,
                          size: 18,
                          color: Color(0xFF2A1B00),
                        ),
                        SizedBox(width: 5),
                        Text(
                          'Add crop',
                          style: TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF2A1B00),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // Crop Cards Container (.c class with box-shadow: 0 3px 0 #E9E2D1)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: const Color(0xFFE6E0D2), width: 1),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0xFFE9E2D1),
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: _farm.crops.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                      child: Center(
                        child: Column(
                          children: const [
                            Icon(Icons.grass_rounded, size: 36, color: Color(0xFF8A9A86)),
                            SizedBox(height: 8),
                            Text(
                              'No crops added yet',
                              style: TextStyle(
                                fontFamily: 'Mukta',
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1B2A21),
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Tap "+ Add crop" above to record your current crop plantings and growth stages.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'Mukta',
                                fontSize: 13,
                                fontWeight: FontWeight.w400,
                                color: Color(0xFF55655A),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : Column(
                      children: [
                        for (int i = 0; i < _farm.crops.length; i++) ...[
                          _buildDynamicCropRow(_farm.crops[i]),
                          if (i < _farm.crops.length - 1)
                            const Divider(height: 1, thickness: 1, color: Color(0xFFEEE8DA)),
                        ],
                      ],
                    ),
            ),

            const SizedBox(height: 16),

            // Section: Make better use of your land
            const Text(
              'Make better use of your land',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1B2A21),
              ),
            ),
            const SizedBox(height: 10),

            // AI Farm Planner Card (.c class from HTML)
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: const Color(0xFFE6E0D2), width: 1),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0xFFE9E2D1),
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: const Color(0xFFC9E1EE),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        alignment: Alignment.center,
                        child: SizedBox(
                          width: 48,
                          height: 48,
                          child: CustomPaint(
                            painter: _PlannerParcelsPainter(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'AI Farm Planner',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1B2A21),
                              ),
                            ),
                            Text(
                              'Design your field layout and crop allocation',
                              style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w400,
                                color: Color(0xFF55655A),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const FarmPlannerScreen()),
                      );
                    },
                    borderRadius: BorderRadius.circular(24),
                    child: Container(
                      width: double.infinity,
                      height: 48,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E4D2B),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0xFF123320),
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Text(
                            'Design my land',
                            style: TextStyle(
                              fontSize: 16.5,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(
                            Icons.arrow_forward_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // Farm Diary Card (.c class from HTML)
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const FarmDiaryScreen()),
                );
              },
              borderRadius: BorderRadius.circular(22),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: const Color(0xFFE6E0D2), width: 1),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0xFFE9E2D1),
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3D3C4),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      alignment: Alignment.center,
                      child: SizedBox(
                        width: 48,
                        height: 48,
                        child: CustomPaint(
                          painter: _DiaryClipboardPainter(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Farm Diary',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1B2A21),
                            ),
                          ),
                          Text(
                            'Keep track of daily field activities',
                            style: TextStyle(
                              fontSize: 13,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF55655A),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      height: 40,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3EFE4),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Text(
                            'Open',
                            style: TextStyle(
                              fontSize: 14.5,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF1E4D2B),
                            ),
                          ),
                          SizedBox(width: 3),
                          Icon(
                            Icons.chevron_right_rounded,
                            size: 16,
                            color: Color(0xFF1E4D2B),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDynamicCropRow(Crop crop) {
    final nameLower = crop.name.toLowerCase();
    String? cropPhoto;
    if (nameLower.contains('mustard') || nameLower.contains('sarson')) {
      cropPhoto = 'assets/images/mustard_crop.jpg';
    } else if (nameLower.contains('wheat') || nameLower.contains('gehun')) {
      cropPhoto = 'assets/images/wheat_crop.jpg';
    } else {
      cropPhoto = 'assets/images/farmer_field.jpg';
    }

    final bool isTulsi = nameLower.contains('tulsi');
    final bool isAshwagandha = nameLower.contains('ashwagandha');

    Color iconBg = const Color(0xFFE2EFDF);
    Widget iconPainter = CustomPaint(painter: _AshwagandhaPlantPainter());

    if (isTulsi) {
      iconBg = const Color(0xFFFBE3A6);
      iconPainter = CustomPaint(painter: _TulsiPotPainter());
    } else if (nameLower.contains('wheat')) {
      iconBg = const Color(0xFFFCEFD0);
      iconPainter = const Center(child: Icon(Icons.grass_rounded, color: Color(0xFF8A5600), size: 28));
    } else if (nameLower.contains('mustard')) {
      iconBg = const Color(0xFFFDF1D6);
      iconPainter = const Center(child: Icon(Icons.eco_rounded, color: Color(0xFFB8860B), size: 28));
    } else if (nameLower.contains('gram')) {
      iconBg = const Color(0xFFF3D3C4);
      iconPainter = const Center(child: Icon(Icons.spa_rounded, color: Color(0xFF8E3F20), size: 28));
    } else if (!isAshwagandha) {
      iconBg = const Color(0xFFDDEBF3);
      iconPainter = const Center(child: Icon(Icons.grass_rounded, color: Color(0xFF18566F), size: 28));
    }

    return InkWell(
      onTap: () => _showCropDetailModal(crop),
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(16),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: cropPhoto != null
                    ? SafeLocalImage(
                        imagePath: cropPhoto,
                        width: 52,
                        height: 52,
                        fit: BoxFit.cover,
                        fallback: SizedBox(
                          width: 52,
                          height: 52,
                          child: iconPainter,
                        ),
                      )
                    : SizedBox(
                        width: 52,
                        height: 52,
                        child: iconPainter,
                      ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    crop.name,
                    style: const TextStyle(
                      fontFamily: 'Mukta',
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1B2A21),
                    ),
                  ),
                  Text(
                    '${crop.variety ?? "1 acre"} · ${crop.growthStage ?? "Active growing"}',
                    style: const TextStyle(
                      fontFamily: 'Mukta',
                      fontSize: 13.5,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF55655A),
                    ),
                  ),
                ],
              ),
            ),
            _buildActiveBadge(),
          ],
        ),
      ),
    );
  }

  void _showCropDetailModal(Crop crop) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (modalCtx, setModalState) {
          return Container(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          crop.name,
                          style: const TextStyle(
                            fontFamily: 'Mukta',
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1B2A21),
                          ),
                        ),
                        Text(
                          crop.variety ?? 'Certified Variety',
                          style: const TextStyle(
                            fontFamily: 'Mukta',
                            fontSize: 14,
                            color: Color(0xFF55655A),
                          ),
                        ),
                      ],
                    ),
                    _buildActiveBadge(),
                  ],
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF6F2E9),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Growth Stage:', style: TextStyle(fontFamily: 'Mukta', fontSize: 13, color: Color(0xFF55655A))),
                          Text(crop.growthStage ?? 'Active vegetative', style: const TextStyle(fontFamily: 'Mukta', fontSize: 13.5, fontWeight: FontWeight.w600, color: Color(0xFF1E4D2B))),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Sowing Date:', style: TextStyle(fontFamily: 'Mukta', fontSize: 13, color: Color(0xFF55655A))),
                          Text(
                            crop.sowingDate != null
                                ? '${crop.sowingDate!.day}/${crop.sowingDate!.month}/${crop.sowingDate!.year}'
                                : '20 Sep 2026',
                            style: const TextStyle(fontFamily: 'Mukta', fontSize: 13.5, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                      if (crop.notes != null && crop.notes!.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Field Notes: ', style: TextStyle(fontFamily: 'Mukta', fontSize: 13, color: Color(0xFF55655A))),
                            Expanded(child: Text(crop.notes!, style: const TextStyle(fontFamily: 'Mukta', fontSize: 12.5, color: Color(0xFF1B2A21)))),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Log to Diary Button
                GestureDetector(
                  onTap: () {
                    Navigator.pop(ctx);
                    _logActivityForCrop(crop);
                  },
                  child: Container(
                    width: double.infinity,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E4D2B),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: const [
                        BoxShadow(color: Color(0xFF123320), offset: Offset(0, 3)),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.edit_note_rounded, color: Colors.white, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'डायरी में गतिविधि जोड़ें (Log Activity)',
                          style: TextStyle(fontFamily: 'Mukta', fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                // Update Stage / Edit Button
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFFDDD6C4)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: () {
                          Navigator.pop(ctx);
                          _updateCropStage(crop);
                        },
                        child: const Text('अवस्था बदलें (Stage)', style: TextStyle(fontFamily: 'Mukta', color: Color(0xFF1B2A21), fontWeight: FontWeight.w600)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFFF5B7B1)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: () async {
                          Navigator.pop(ctx);
                          _farm.crops.removeWhere((c) => c.name == crop.name);
                          await _storage.updatePrimaryFarm(_farm);
                          _loadFarmData();
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('${crop.name} removed from farm')),
                            );
                          }
                        },
                        child: const Text('हटाएं (Remove)', style: TextStyle(fontFamily: 'Mukta', color: Color(0xFFB03A2E), fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _logActivityForCrop(Crop crop) {
    final noteCtrl = TextEditingController();
    String category = 'Irrigation';
    final categories = ['Irrigation', 'Fertilizer', 'Spraying', 'Weeding', 'Harvesting'];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
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
                  Text('Log Activity for ${crop.name}', style: const TextStyle(fontFamily: 'Mukta', fontSize: 18, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    children: categories.map((cat) {
                      final isSel = category == cat;
                      return ChoiceChip(
                        label: Text(cat, style: TextStyle(fontFamily: 'Mukta', color: isSel ? Colors.white : const Color(0xFF1B2A21))),
                        selected: isSel,
                        selectedColor: const Color(0xFF1E4D2B),
                        onSelected: (val) => setModalState(() => category = cat),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: noteCtrl,
                    decoration: InputDecoration(
                      hintText: 'e.g. Applied 25kg urea or 2 hours tubewell irrigation...',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E4D2B),
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    ),
                    onPressed: () async {
                      final notes = noteCtrl.text.trim().isEmpty ? 'Completed $category for ${crop.name}' : noteCtrl.text.trim();
                      final entry = DiaryEntry(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        title: '$category on ${crop.name}',
                        category: category,
                        date: 'Today',
                        notes: notes,
                      );
                      await _storage.addDiaryEntry(entry);
                      Navigator.pop(ctx);
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('✓ Saved to Farm Diary: $category on ${crop.name}'),
                            backgroundColor: const Color(0xFF1E4D2B),
                          ),
                        );
                      }
                    },
                    child: const Text('सहेजें (Save to Diary)', style: TextStyle(fontFamily: 'Mukta', fontSize: 15, fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _updateCropStage(Crop crop) {
    final stages = ['Sowing & Germination', 'Active vegetative', 'Flowering stage', 'Pod / Grain formation', 'Ready for harvest'];
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFFF6F2E9),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Update Stage for ${crop.name}', style: const TextStyle(fontFamily: 'Mukta', fontSize: 20, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            ...stages.map((st) {
              final isCur = crop.growthStage == st;
              return ListTile(
                title: Text(st, style: TextStyle(fontFamily: 'Mukta', fontWeight: isCur ? FontWeight.w600 : FontWeight.w400)),
                trailing: isCur ? const Icon(Icons.check_circle_rounded, color: Color(0xFF1E4D2B)) : null,
                onTap: () async {
                  crop.growthStage = st;
                  await _storage.updatePrimaryFarm(_farm);
                  _loadFarmData();
                  Navigator.pop(ctx);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('✓ ${crop.name} stage updated to "$st"')),
                    );
                  }
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFDDEFD9),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: const BoxDecoration(
              color: Color(0xFF2E9B4F),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 5),
          const Text(
            'Active',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: Color(0xFF1E4D2B),
            ),
          ),
        ],
      ),
    );
  }
}

// 1. Registered Land Hero SVG Painter (Polygons, Furrows, Pins)
class _FarmParcelsSvgPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Circle: cx="160" cy="30" r="30" fill="#F2B134" opacity=".2"
    final haloPaint = Paint()
      ..color = const Color(0xFFF2B134).withOpacity(0.20)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(const Offset(160, 30), 30, haloPaint);

    // Parcel 1: points="30,34 118,18 142,66 54,84" fill="#7DB88A"
    final p1 = Path()
      ..moveTo(30, 34)
      ..lineTo(118, 18)
      ..lineTo(142, 66)
      ..lineTo(54, 84)
      ..close();
    canvas.drawPath(p1, Paint()..color = const Color(0xFF7DB88A));

    // Furrows 1 in #2B6A3E
    final f1Paint = Paint()
      ..color = const Color(0xFF2B6A3E)
      ..strokeWidth = 1.6;
    canvas.drawLine(const Offset(44, 40), const Offset(66, 86), f1Paint);
    canvas.drawLine(const Offset(62, 37), const Offset(84, 83), f1Paint);
    canvas.drawLine(const Offset(80, 34), const Offset(102, 80), f1Paint);
    canvas.drawLine(const Offset(98, 31), const Offset(120, 77), f1Paint);
    canvas.drawLine(const Offset(116, 28), const Offset(138, 74), f1Paint);

    // Parcel 2: points="54,92 142,76 166,124 78,142" fill="#3A8350"
    final p2 = Path()
      ..moveTo(54, 92)
      ..lineTo(142, 76)
      ..lineTo(166, 124)
      ..lineTo(78, 142)
      ..close();
    canvas.drawPath(p2, Paint()..color = const Color(0xFF3A8350));

    // Furrows 2 in #5DAA6E
    final f2Paint = Paint()
      ..color = const Color(0xFF5DAA6E)
      ..strokeWidth = 1.6;
    canvas.drawLine(const Offset(68, 98), const Offset(90, 144), f2Paint);
    canvas.drawLine(const Offset(86, 95), const Offset(108, 141), f2Paint);
    canvas.drawLine(const Offset(104, 92), const Offset(126, 138), f2Paint);
    canvas.drawLine(const Offset(122, 89), const Offset(144, 135), f2Paint);
    canvas.drawLine(const Offset(140, 86), const Offset(162, 132), f2Paint);

    // Yellow Pins at (142, 66) and (166, 124)
    final pinPaint = Paint()..color = const Color(0xFFF2B134);
    canvas.drawCircle(const Offset(142, 66), 6, pinPaint);
    canvas.drawCircle(const Offset(166, 124), 6, pinPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// 2. Ashwagandha Plant Painter
class _AshwagandhaPlantPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final stem = Paint()
      ..color = const Color(0xFF1E4D2B)
      ..strokeWidth = 2.4;
    canvas.drawLine(const Offset(26, 42), const Offset(26, 22), stem);

    final leafFill = Paint()
      ..color = const Color(0xFF3A8350)
      ..style = PaintingStyle.fill;
    final leafStroke = Paint()
      ..color = const Color(0xFF1E4D2B)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final p1 = Path()
      ..moveTo(26, 30)
      ..cubicTo(18, 30, 15, 25, 15, 19)
      ..cubicTo(22, 19, 26, 23, 26, 30)
      ..close();
    canvas.drawPath(p1, leafFill);
    canvas.drawPath(p1, leafStroke);

    final p2 = Path()
      ..moveTo(26, 26)
      ..cubicTo(26, 20, 30, 16, 37, 16)
      ..cubicTo(37, 23, 33, 26, 26, 26)
      ..close();
    canvas.drawPath(p2, leafFill);
    canvas.drawPath(p2, leafStroke);

    // Berry at (26, 15, r=3)
    canvas.drawCircle(const Offset(26, 15), 3, Paint()..color = const Color(0xFFF2B134));
    canvas.drawCircle(const Offset(26, 15), 3, Paint()..color = const Color(0xFF8A5600)..style = PaintingStyle.stroke..strokeWidth = 1.4);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// 3. Tulsi Pot & Plant Painter
class _TulsiPotPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Pot
    final potPath = Path()
      ..moveTo(17, 34)
      ..lineTo(35, 34)
      ..lineTo(33, 40)
      ..lineTo(19, 40)
      ..close();
    canvas.drawPath(potPath, Paint()..color = const Color(0xFFC06A3C));
    canvas.drawPath(potPath, Paint()..color = const Color(0xFF8E3F20)..style = PaintingStyle.stroke..strokeWidth = 1.4);

    // Stem
    canvas.drawLine(const Offset(26, 34), const Offset(26, 22), Paint()..color = const Color(0xFF1E4D2B)..strokeWidth = 2.4);

    // Leaves
    final leafFill = Paint()..color = const Color(0xFF3A8350);
    final leafStroke = Paint()..color = const Color(0xFF1E4D2B)..style = PaintingStyle.stroke..strokeWidth = 1.5;

    final l1 = Path()
      ..moveTo(26, 26)
      ..cubicTo(20, 26, 17, 23, 17, 18)
      ..cubicTo(23, 18, 26, 21, 26, 26)
      ..close();
    canvas.drawPath(l1, leafFill);
    canvas.drawPath(l1, leafStroke);

    final l2 = Path()
      ..moveTo(26, 22)
      ..cubicTo(26, 17, 29, 14, 35, 14)
      ..cubicTo(35, 19, 32, 22, 26, 22)
      ..close();
    canvas.drawPath(l2, leafFill);
    canvas.drawPath(l2, leafStroke);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// 4. Farm Planner 4-Quadrant Parcels Painter
class _PlannerParcelsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final borderPaint = Paint()
      ..color = const Color(0xFF18566F)
      ..strokeWidth = 1.6
      ..style = PaintingStyle.stroke;

    void drawParcel(Rect rect, Color fill) {
      canvas.drawRect(rect, Paint()..color = fill..style = PaintingStyle.fill);
      canvas.drawRect(rect, borderPaint);
    }

    drawParcel(const Rect.fromLTWH(8, 12, 14, 12), const Color(0xFF7DB88A));
    drawParcel(const Rect.fromLTWH(26, 10, 14, 14), const Color(0xFFF2B134));
    drawParcel(const Rect.fromLTWH(8, 28, 18, 10), const Color(0xFF3A8350));
    drawParcel(const Rect.fromLTWH(30, 28, 10, 10), Colors.white);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// 5. Diary Clipboard Painter
class _DiaryClipboardPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Clipboard Paper: x="13" y="10" width="22" height="28" rx="3"
    final rrect = RRect.fromRectAndRadius(const Rect.fromLTWH(13, 10, 22, 28), const Radius.circular(3));
    canvas.drawRRect(rrect, Paint()..color = Colors.white);
    canvas.drawRRect(rrect, Paint()..color = const Color(0xFF8E3F20)..style = PaintingStyle.stroke..strokeWidth = 1.8);

    // Left rings: (13,16), (13,24), (13,32)
    final ringPaint = Paint()..color = const Color(0xFF8E3F20)..strokeWidth = 1.8;
    canvas.drawLine(const Offset(13, 16), const Offset(11, 16), ringPaint);
    canvas.drawLine(const Offset(13, 24), const Offset(11, 24), ringPaint);
    canvas.drawLine(const Offset(13, 32), const Offset(11, 32), ringPaint);

    // Lines
    final linePaint = Paint()..color = const Color(0xFFC06A3C)..strokeWidth = 1.8;
    canvas.drawLine(const Offset(18, 18), const Offset(30, 18), linePaint);
    canvas.drawLine(const Offset(18, 24), const Offset(30, 24), linePaint);
    canvas.drawLine(const Offset(18, 30), const Offset(25, 30), linePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
