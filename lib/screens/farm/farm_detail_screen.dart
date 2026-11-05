import 'package:flutter/material.dart';
import '../../models/farm.dart';
import '../../models/crop.dart';
import '../../theme/app_theme.dart';
import 'add_field_screen.dart';
import 'add_crop_screen.dart';
import 'edit_farm_screen.dart';
import '../../widgets/safe_local_image.dart';

class FarmDetailScreen extends StatefulWidget {
  final Farm farm;
  const FarmDetailScreen({Key? key, required this.farm}) : super(key: key);

  @override
  State<FarmDetailScreen> createState() => _FarmDetailScreenState();
}

class _FarmDetailScreenState extends State<FarmDetailScreen> {
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
    final farm = widget.farm;
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: AppColors.creamBg,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
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
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'YOUR LAND DETAILS',
                          style: TextStyle(
                            fontFamily: 'Mukta',
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.1,
                            color: AppColors.textMuted,
                          ),
                        ),
                        Text(
                          '${farm.farmerName}\'s Land',
                          style: const TextStyle(
                            fontFamily: 'Mukta',
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textDark,
                            height: 1.15,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () async {
                      final edited = await Navigator.of(context).push<Farm>(
                        MaterialPageRoute(builder: (_) => EditFarmScreen(farm: farm)),
                      );
                      if (edited != null && mounted) {
                        setState(() {});
                      }
                    },
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
                          Icons.edit_outlined,
                          size: 20,
                          color: AppColors.primaryGreen,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Overview Hero Card
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: const [
                    BoxShadow(
                      color: AppColors.tactileGreenShadow,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Stack(
                    children: [
                      // Real Farm Photo Background
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
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                const Color(0xFF1E4D2B).withOpacity(0.92),
                                const Color(0xFF1E4D2B).withOpacity(0.85),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // Content
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'REGISTERED FARM',
                                  style: TextStyle(
                                    fontFamily: 'Mukta',
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.cardGold,
                                    letterSpacing: 1.1,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.18),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    '${farm.fields.length} active plots',
                                    style: const TextStyle(
                                      fontFamily: 'Mukta',
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${farm.totalArea.toStringAsFixed(farm.totalArea.truncateToDouble() == farm.totalArea ? 0 : 1)} acres',
                              style: const TextStyle(
                                fontFamily: 'Mukta',
                                fontSize: 32,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                                height: 1.1,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                const Icon(Icons.location_on_rounded, size: 16, color: AppColors.cardGold),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    '${farm.village}, ${farm.district}, ${farm.state}',
                                    style: TextStyle(
                                      fontFamily: 'Mukta',
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white.withOpacity(0.9),
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
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
              ),

              const SizedBox(height: 24),

              // Crops Section Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Crops',
                    style: TextStyle(
                      fontFamily: 'Mukta',
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark,
                    ),
                  ),
                  GestureDetector(
                    onTap: () async {
                      final newCrop = await Navigator.of(context).push<Crop>(
                        MaterialPageRoute(builder: (_) => AddCropScreen(farm: farm)),
                      );
                      if (newCrop != null && mounted) {
                        setState(() {
                          farm.crops.add(newCrop);
                        });
                      }
                    },
                    child: Container(
                      height: 36,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: AppStyles.goldButtonBox,
                      child: const Center(
                        child: Text(
                          '+ Add crop',
                          style: TextStyle(
                            fontFamily: 'Mukta',
                            fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: AppColors.textDark,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              if (farm.crops.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: AppStyles.cardBox,
                  child: const Center(
                    child: Text(
                      'No crops added yet. Tap "+ Add crop" to track a crop.',
                      style: TextStyle(
                        fontFamily: 'Mukta',
                        fontSize: 13,
                        fontWeight: FontWeight.w400, color: AppColors.textMuted,
                      ),
                    ),
                  ),
                )
              else
                ...farm.crops.map((c) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: AppStyles.cardBox,
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE2EFDF),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: SafeLocalImage(
                              imagePath: _getCropImagePath(c.name),
                              fit: BoxFit.cover,
                              fallback: const Center(
                                child: Icon(Icons.eco_rounded, color: AppColors.primaryGreen, size: 22),
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
                                c.name + (c.variety != null ? ' (${c.variety})' : ''),
                                style: const TextStyle(
                                  fontFamily: 'Mukta',
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textDark,
                                ),
                              ),
                              Text(
                                'Stage: ${c.growthStage ?? "Early vegetative"}',
                                style: const TextStyle(
                                  fontFamily: 'Mukta',
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400, color: AppColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE2EFDF),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'Active',
                            style: TextStyle(
                              fontFamily: 'Mukta',
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primaryGreen,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),

              const SizedBox(height: 24),

              // Fields Section Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Field Plots',
                    style: TextStyle(
                      fontFamily: 'Mukta',
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark,
                    ),
                  ),
                  GestureDetector(
                    onTap: () async {
                      final newField = await Navigator.of(context).push<Field>(
                        MaterialPageRoute(builder: (_) => AddFieldScreen(farm: farm)),
                      );
                      if (newField != null && mounted) {
                        setState(() {
                          farm.fields.add(newField);
                        });
                      }
                    },
                    child: Container(
                      height: 36,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: AppColors.primaryGreen,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: const [
                          BoxShadow(
                            color: AppColors.tactileGreenShadow,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Text(
                          '+ Add field',
                          style: TextStyle(
                            fontFamily: 'Mukta',
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              if (farm.fields.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: AppStyles.cardBox,
                  child: const Center(
                    child: Text(
                      'No fields partitioned yet. Tap "+ Add field" to partition plots.',
                      style: TextStyle(
                        fontFamily: 'Mukta',
                        fontSize: 13,
                        fontWeight: FontWeight.w400, color: AppColors.textMuted,
                      ),
                    ),
                  ),
                )
              else
                ...farm.fields.map((f) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: AppStyles.cardBox,
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFCEFD0),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Center(
                            child: Icon(Icons.grid_view_rounded, color: Color(0xFF8A5600), size: 22),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                f.name,
                                style: const TextStyle(
                                  fontFamily: 'Mukta',
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textDark,
                                ),
                              ),
                              Text(
                                'Crop: ${f.crop} · ${f.area} acres',
                                style: const TextStyle(
                                  fontFamily: 'Mukta',
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400, color: AppColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }),

              SizedBox(height: bottomInset > 0 ? bottomInset + 12 : 24),
            ],
          ),
        ),
      ),
    );
  }
}
