import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../l10n/app_strings.dart';
import '../../models/diary_entry.dart';
import '../../services/gallery_picker_service.dart';
import '../../services/gemini_service.dart';
import '../../services/storage_service.dart';
import '../../services/turso/turso_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/safe_local_image.dart';

enum ScanCategory { leaf, soil, pest, bottleCard, nonAgri }

class DeviceGalleryPhoto {
  final String id;
  final String fileName;
  final String fileSize;
  final String nameEn;
  final String nameHi;
  final String imagePath;
  final ScanCategory category;
  final String hint;

  const DeviceGalleryPhoto({
    required this.id,
    required this.fileName,
    required this.fileSize,
    required this.nameEn,
    required this.nameHi,
    required this.imagePath,
    required this.category,
    required this.hint,
  });
}

class ScanAskScreen extends StatefulWidget {
  const ScanAskScreen({Key? key}) : super(key: key);

  @override
  State<ScanAskScreen> createState() => _ScanAskScreenState();
}

class _ScanAskScreenState extends State<ScanAskScreen>
    with SingleTickerProviderStateMixin {
  final StorageService _storage = StorageService();

  late AnimationController _laserController;
  late Animation<double> _laserAnimation;

  ScanCategory _selectedCategory = ScanCategory.leaf;
  late DeviceGalleryPhoto _selectedPhoto;

  // Real uploaded image from user's phone gallery
  Uint8List? _uploadedImageBytes;
  String? _uploadedFileName;

  bool _isFlashOn = false;
  bool _isSpeaking = false;
  bool _isScanning = false;

  // Null on start for clean, uncluttered interface
  GeminiCropDiagnosis? _diagnosis;
  bool get isHindi => AppLanguage().isHindi;

  final List<DeviceGalleryPhoto> _deviceGallery = [
    const DeviceGalleryPhoto(
      id: 'dcim_mustard',
      fileName: 'IMG_MustardLeaf.jpg',
      fileSize: '2.4 MB',
      nameEn: 'Mustard Leaf',
      nameHi: 'सरसों की पत्ती',
      imagePath: 'assets/images/mustard_crop.jpg',
      category: ScanCategory.leaf,
      hint: 'Leaf spot with circular brown-yellow halos',
    ),
    const DeviceGalleryPhoto(
      id: 'dcim_wheat',
      fileName: 'DCIM_WheatRust.jpg',
      fileSize: '3.1 MB',
      nameEn: 'Wheat Crop',
      nameHi: 'गेहूं की फसल',
      imagePath: 'assets/images/wheat_crop.jpg',
      category: ScanCategory.leaf,
      hint: 'Yellow rust stripe pustules across leaves',
    ),
    const DeviceGalleryPhoto(
      id: 'dcim_tomato',
      fileName: 'Tomato_EarlyBlight.jpg',
      fileSize: '1.9 MB',
      nameEn: 'Tomato Plant',
      nameHi: 'टमाटर का पौधा',
      imagePath: 'assets/images/farmer_field.jpg',
      category: ScanCategory.leaf,
      hint: 'Early blight dark concentric rings',
    ),
    const DeviceGalleryPhoto(
      id: 'storage_blacksoil',
      fileName: 'BlackCottonSoil.jpg',
      fileSize: '4.2 MB',
      nameEn: 'Black Cotton Soil',
      nameHi: 'काली दोमट मिट्टी',
      imagePath: 'assets/images/optimized_farmland.jpg',
      category: ScanCategory.soil,
      hint: 'Moisture rich, nitrogen and zinc deficit',
    ),
    const DeviceGalleryPhoto(
      id: 'storage_aphids',
      fileName: 'Aphids_PestCluster.jpg',
      fileSize: '1.7 MB',
      nameEn: 'Aphids / Sucking Pests',
      nameHi: 'माहू व रस चूसक कीट',
      imagePath: 'assets/images/mustard_crop.jpg',
      category: ScanCategory.pest,
      hint: 'Clusters of sap sucking insects on leaf undersides',
    ),
    const DeviceGalleryPhoto(
      id: 'storage_bottle',
      fileName: 'Fertilizer_Pesticide_SoilCard.jpg',
      fileSize: '2.1 MB',
      nameEn: 'Bottle / Soil Card',
      nameHi: 'दवा बोतल / मृदा कार्ड',
      imagePath: 'assets/images/farmer_hero.jpg',
      category: ScanCategory.bottleCard,
      hint: 'Fertilizer/Pesticide label or Govt Soil Health Card',
    ),
    const DeviceGalleryPhoto(
      id: 'storage_vehicle',
      fileName: 'IMG_Car_Vehicle.jpg',
      fileSize: '3.4 MB',
      nameEn: 'Vehicle / Car (Test)',
      nameHi: 'वाहन / कार (टेस्ट)',
      imagePath: 'assets/images/tractor_rental.jpg',
      category: ScanCategory.nonAgri,
      hint: 'Non-agricultural machine',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _selectedPhoto = _deviceGallery[0];

    _laserController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);

    _laserAnimation = Tween<double>(begin: 0.08, end: 0.92).animate(
      CurvedAnimation(parent: _laserController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _laserController.dispose();
    super.dispose();
  }

  String _getCategoryKey(ScanCategory cat) {
    switch (cat) {
      case ScanCategory.leaf:
        return 'leaf';
      case ScanCategory.soil:
        return 'soil';
      case ScanCategory.pest:
        return 'pest';
      case ScanCategory.bottleCard:
        return 'bottle_card';
      case ScanCategory.nonAgri:
        return 'other';
    }
  }

  /// PICK ACTUAL PHOTO FROM PHONE'S INTERNAL GALLERY
  Future<void> _pickRealPhotoFromPhoneGallery() => _pickWithCategory('leaf');

  Future<void> _pickWithCategory(String category) async {
    try {
      final picked = await GalleryPickerService.pickImage();
      if (picked != null && picked.bytes.isNotEmpty) {
        setState(() {
          _uploadedImageBytes = picked.bytes;
          _uploadedFileName = picked.fileName;
          _isScanning = true;
        });

        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    isHindi
                        ? 'फोन गैलरी से फोटो अपलोड हुई: ${picked.fileName}'
                        : 'Uploaded from Phone Gallery: ${picked.fileName}',
                    style: const TextStyle(fontFamily: 'Mukta', fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            backgroundColor: AppColors.primaryGreen,
            duration: const Duration(seconds: 3),
          ),
        );

        // Run Gemini Vision on user's real uploaded photo bytes
        final result = await GeminiService().diagnoseCrop(
          cropName: picked.fileName,
          symptoms: category == 'bottle_card'
              ? 'Pesticide/Fertilizer bottle label or Govt Soil Health Card photo from gallery'
              : 'Actual photo uploaded directly from user phone gallery',
          category: category,
          imageBytes: picked.bytes,
          mimeType: picked.mimeType,
        );

        if (mounted) {
          setState(() {
            _diagnosis = result;
            _isScanning = false;
          });
        }
        if (result.isRelevant) {
          TursoService().insertAiScanCloud(
            cropName: result.getCropName(false),
            scanType: result.scanType,
            diseaseName: result.getDiseaseName(false),
            severity: result.getSeverity(false),
            dangerTitle: result.getDangerTitle(false),
            immediateAction: result.getImmediateAction(false),
            organicTreatment: result.getOrganicTreatment(false),
            chemicalTreatment: result.getChemicalTreatment(false),
            isRelevant: true,
          );
        }
      } else {
        // If system dialog closed without picking, offer device gallery picker
        _showGalleryOptionsSheet();
      }
    } catch (e) {
      debugPrint('Gallery picker error: $e');
      _showGalleryOptionsSheet();
    }
  }

  /// SHOW GALLERY OPTIONS SHEET
  void _showGalleryOptionsSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 24),
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
              const SizedBox(height: 14),

              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.mintTint,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.photo_library_rounded,
                      color: AppColors.primaryGreen,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isHindi ? 'फोन की आंतरिक गैलरी' : 'Your Phone Gallery',
                          style: const TextStyle(
                            fontFamily: 'Mukta',
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textDark,
                          ),
                        ),
                        Text(
                          isHindi
                              ? 'अपने फोन की फोटो गैलरी से कोई भी फसल फोटो अपलोड करें'
                              : 'Select any plant or leaf photo directly from your device',
                          style: const TextStyle(
                            fontFamily: 'Mukta',
                            fontSize: 12.5,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Action 1: Native Phone Gallery Dialog
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(ctx);
                    _pickRealPhotoFromPhoneGallery();
                  },
                  icon: const Icon(Icons.file_upload_outlined, color: Colors.white, size: 22),
                  label: Text(
                    isHindi ? '📁 अपने फोन की गैलरी खोलें' : '📁 Open Phone Gallery / Photos',
                    style: const TextStyle(
                      fontFamily: 'Mukta',
                      fontSize: 15.5,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                ),
              ),

              const SizedBox(height: 14),

              Text(
                isHindi ? 'या हाल ही में ली गई फोटो चुनें:' : 'Or pick from device storage:',
                style: const TextStyle(
                  fontFamily: 'Mukta',
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),

              const SizedBox(height: 10),

              // Horizontal list of stored photos
              SizedBox(
                height: 110,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _deviceGallery.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 10),
                  itemBuilder: (context, index) {
                    final item = _deviceGallery[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.pop(ctx);
                        setState(() {
                          _uploadedImageBytes = null;
                          _uploadedFileName = null;
                        });
                        _performScan(item);
                      },
                      child: Container(
                        width: 100,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFE5DECE), width: 1),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(13),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              SafeLocalImage(imagePath: item.imagePath, fit: BoxFit.cover),
                              Container(color: Colors.black.withOpacity(0.35)),
                              Positioned(
                                left: 6,
                                bottom: 6,
                                right: 6,
                                child: Text(
                                  isHindi ? item.nameHi : item.nameEn,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontFamily: 'Mukta',
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
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
            ],
          ),
        );
      },
    );
  }

  Future<void> _performScan(DeviceGalleryPhoto photo) async {
    setState(() {
      _selectedPhoto = photo;
      _selectedCategory = photo.category;
      _isScanning = true;
    });

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                isHindi
                    ? 'AI खतरे की जांच कर रहा है: ${photo.nameHi}...'
                    : 'AI analyzing plant danger: ${photo.nameEn}...',
                style: const TextStyle(
                  fontFamily: 'Mukta',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.primaryGreen,
        duration: const Duration(seconds: 2),
      ),
    );

    final catKey = _getCategoryKey(photo.category);
    final result = await GeminiService().diagnoseCrop(
      cropName: photo.nameEn,
      symptoms: photo.hint,
      category: catKey,
      imageBytes: _uploadedImageBytes,
    );

    if (mounted) {
      setState(() {
        _diagnosis = result;
        _isScanning = false;
      });
    }
    if (result.isRelevant) {
      TursoService().insertAiScanCloud(
        cropName: result.getCropName(false),
        scanType: result.scanType,
        diseaseName: result.getDiseaseName(false),
        severity: result.getSeverity(false),
        dangerTitle: result.getDangerTitle(false),
        immediateAction: result.getImmediateAction(false),
        organicTreatment: result.getOrganicTreatment(false),
        chemicalTreatment: result.getChemicalTreatment(false),
        isRelevant: true,
      );
    }
  }

  void _clearDiagnosis() {
    setState(() {
      _diagnosis = null;
      _uploadedImageBytes = null;
      _uploadedFileName = null;
    });
  }

  void _cycleSample() {
    final curIdx = _deviceGallery.indexWhere((s) => s.id == _selectedPhoto.id);
    final nextIdx = (curIdx + 1) % _deviceGallery.length;
    setState(() {
      _uploadedImageBytes = null;
      _uploadedFileName = null;
      _selectedPhoto = _deviceGallery[nextIdx];
      _selectedCategory = _selectedPhoto.category;
    });
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isHindi
              ? 'फोटो बदली: ${_selectedPhoto.nameHi}'
              : 'Switched to: ${_selectedPhoto.nameEn}',
          style: const TextStyle(fontFamily: 'Mukta', fontWeight: FontWeight.w500),
        ),
        duration: const Duration(seconds: 1),
        backgroundColor: AppColors.primaryGreen,
      ),
    );
    if (_diagnosis != null) {
      _performScan(_selectedPhoto);
    }
  }

  void _speakDiagnosis() {
    if (_diagnosis == null) return;
    setState(() => _isSpeaking = true);
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.volume_up_rounded, color: Colors.white, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _diagnosis!.isRelevant
                    ? _diagnosis!.getVoiceSummary(isHindi)
                    : _diagnosis!.getIrrelevanceReason(isHindi),
                style: const TextStyle(
                  fontFamily: 'Mukta',
                  fontWeight: FontWeight.w600,
                  fontSize: 14.5,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: _diagnosis!.isRelevant
            ? AppColors.primaryGreen
            : const Color(0xFFDC2626),
        duration: const Duration(seconds: 5),
      ),
    );
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) setState(() => _isSpeaking = false);
    });
  }

  void _addToDiary() async {
    if (_diagnosis == null) return;
    final entry = DiaryEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: 'AI Scan: ${_diagnosis!.getDiseaseName(false)}',
      category: _selectedCategory == ScanCategory.soil
          ? 'Soil & Fertility'
          : (_selectedCategory == ScanCategory.pest
              ? 'Pest & Insect Control'
              : 'Crop Health'),
      date: 'Today, Just now',
      notes:
          '${_diagnosis!.getDiseaseName(isHindi)}: ${_diagnosis!.getDangerTitle(isHindi)} | ${_diagnosis!.getImmediateAction(isHindi)}',
    );
    await _storage.addDiaryEntry(entry);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isHindi ? '✓ खेत डायरी में जोड़ दिया गया' : '✓ Saved to Farm Diary!',
            style: const TextStyle(
              fontFamily: 'Mukta',
              fontWeight: FontWeight.w500,
            ),
          ),
          backgroundColor: AppColors.primaryGreen,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _showAskAiDialog() {
    final textController = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        bool isAsking = false;
        String? aiAnswer;

        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: EdgeInsets.only(
                left: 18,
                right: 18,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
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
                          child: const Icon(Icons.psychology_rounded,
                              color: Color(0xFF7A4D00), size: 24),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isHindi ? 'AI किसान डॉक्टर से पूछें' : 'Ask AI Crop Specialist',
                                style: const TextStyle(
                                  fontFamily: 'Mukta',
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textDark,
                                ),
                              ),
                              Text(
                                isHindi ? 'Gemini AI द्वारा संचालित' : 'Powered by Gemini AI',
                                style: const TextStyle(
                                  fontFamily: 'Mukta',
                                  fontSize: 12,
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: textController,
                      decoration: InputDecoration(
                        hintText: isHindi
                            ? 'अपनी फसल के खतरे व समाधान के बारे में पूछें...'
                            : 'Ask about plant danger, spray timings or dosage...',
                        hintStyle: const TextStyle(
                            fontFamily: 'Mukta', color: AppColors.textMuted),
                        filled: true,
                        fillColor: const Color(0xFFF7F5EE),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.send_rounded,
                              color: AppColors.primaryGreen),
                          onPressed: () async {
                            final q = textController.text.trim();
                            if (q.isEmpty) return;
                            setModalState(() {
                              isAsking = true;
                              aiAnswer = null;
                            });
                            final reply = await GeminiService()
                                .askKisanAi(q, isHindi: isHindi);
                            setModalState(() {
                              isAsking = false;
                              aiAnswer = reply;
                            });
                          },
                        ),
                      ),
                    ),
                    if (isAsking) ...[
                      const SizedBox(height: 20),
                      const Center(
                        child: CircularProgressIndicator(
                            color: AppColors.primaryGreen),
                      ),
                    ],
                    if (aiAnswer != null) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF8F1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                              color: const Color(0xFFA6DBB2), width: 1.2),
                        ),
                        child: Text(
                          aiAnswer!,
                          style: const TextStyle(
                            fontFamily: 'Mukta',
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textDark,
                            height: 1.35,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBF8F2),
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Top Bar
              _buildTopBar(),

              const SizedBox(height: 14),

              // 2. High-Tech Camera Viewfinder with Real Image Display & Laser
              _buildViewfinder(),

              const SizedBox(height: 14),

              // 3. Floating Camera Action Dock (Phone Gallery + Shutter + Switch)
              _buildCameraDock(),

              const SizedBox(height: 16),

              // 4. Content Area:
              // - If diagnosis exists: DANGER IN PLANT & WHAT TO DO
              // - If diagnosis is null: Clean Quick Target Options
              if (_diagnosis != null)
                _buildDangerAndActionReport()
              else
                _buildCoolQuickOptions(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Row(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => Navigator.maybePop(context),
            borderRadius: BorderRadius.circular(21),
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFE5DECE), width: 1),
              ),
              child: const Center(
                child: Icon(
                  Icons.arrow_back_rounded,
                  size: 20,
                  color: AppColors.textDark,
                ),
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
                isHindi ? 'AI फसल डॉक्टर' : 'AI Crop Doctor',
                style: const TextStyle(
                  fontFamily: 'Mukta',
                  fontSize: 19,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                  height: 1.1,
                ),
              ),
              Text(
                isHindi ? 'पत्ती का खतरा व समाधान जांचें' : 'Check plant danger & treatment',
                style: const TextStyle(
                  fontFamily: 'Mukta',
                  fontSize: 12.5,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
        // Flash Button
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => setState(() => _isFlashOn = !_isFlashOn),
            borderRadius: BorderRadius.circular(20),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _isFlashOn ? const Color(0xFFF2B134) : Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: _isFlashOn ? const Color(0xFFC98F1C) : const Color(0xFFE5DECE),
                  width: 1,
                ),
              ),
              child: Center(
                child: Icon(
                  _isFlashOn ? Icons.flash_on_rounded : Icons.flash_off_outlined,
                  size: 18,
                  color: _isFlashOn ? Colors.white : AppColors.textDark,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        // AI Chat Help
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _showAskAiDialog,
            borderRadius: BorderRadius.circular(20),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.mintTint,
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFA6DBB2), width: 1),
              ),
              child: const Center(
                child: Icon(
                  Icons.psychology_rounded,
                  size: 20,
                  color: AppColors.primaryGreen,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildViewfinder() {
    return Container(
      height: 250,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF132A1C),
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x22000000),
            offset: Offset(0, 6),
            blurRadius: 14,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Display real uploaded image from phone gallery if available!
            if (_uploadedImageBytes != null)
              Image.memory(
                _uploadedImageBytes!,
                fit: BoxFit.cover,
              )
            else
              SafeLocalImage(
                imagePath: _selectedPhoto.imagePath,
                fit: BoxFit.cover,
              ),

            Container(color: Colors.black.withOpacity(0.30)),

            // Animated Laser Reticle
            AnimatedBuilder(
              animation: _laserAnimation,
              builder: (context, _) {
                return CustomPaint(
                  painter: _ScannerLaserPainter(
                    laserPos: _laserAnimation.value,
                    isScanning: _isScanning,
                    isFlashOn: _isFlashOn,
                  ),
                );
              },
            ),

            // Top Photo Badge: shows filename of uploaded photo or sample
            Positioned(
              left: 14,
              top: 14,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.65),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white24, width: 0.8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _uploadedImageBytes != null
                          ? Icons.phone_android_rounded
                          : Icons.eco_rounded,
                      size: 13,
                      color: const Color(0xFF00E676),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      _uploadedFileName ?? _selectedPhoto.fileName,
                      style: const TextStyle(
                        fontFamily: 'Mukta',
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom Active Status
            Positioned(
              left: 14,
              bottom: 14,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.60),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.auto_awesome_rounded, size: 13, color: Color(0xFFF2B134)),
                    const SizedBox(width: 5),
                    Text(
                      _uploadedImageBytes != null
                          ? (isHindi ? 'गैलरी फोटो स्कैन' : 'Gallery Photo Loaded')
                          : (isHindi ? 'AI विज़न सक्रिय' : 'Gemini AI Vision Active'),
                      style: const TextStyle(
                        fontFamily: 'Mukta',
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Scanning Overlay Spinner
            if (_isScanning)
              Container(
                color: Colors.black.withOpacity(0.40),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.95),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: AppColors.primaryGreen,
                            strokeWidth: 2.5,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          isHindi ? 'खतरे का विश्लेषण हो रहा है...' : 'Analyzing plant danger...',
                          style: const TextStyle(
                            fontFamily: 'Mukta',
                            fontSize: 13.5,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// CAMERA ACTION DOCK WITH REAL PHONE GALLERY UPLOAD
  Widget _buildCameraDock() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE5DECE), width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            offset: Offset(0, 3),
            blurRadius: 8,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // 1. Switch Photo / Angle
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _cycleSample,
              borderRadius: BorderRadius.circular(22),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF4F0E4),
                        borderRadius: BorderRadius.circular(23),
                      ),
                      child: const Center(
                        child: Icon(Icons.flip_camera_ios_outlined,
                            color: AppColors.textDark, size: 22),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isHindi ? 'फोटो बदलें' : 'Switch',
                      style: const TextStyle(
                        fontFamily: 'Mukta',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textDark,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 2. Central Shutter Button (Clickable, Ripple Feedback)
          Material(
            color: AppColors.primaryGreen,
            shape: const CircleBorder(),
            elevation: 4,
            shadowColor: AppColors.primaryGreen.withOpacity(0.4),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: () {
                if (_uploadedImageBytes != null) {
                  // Re-diagnose the uploaded image
                  setState(() => _isScanning = true);
                  GeminiService()
                      .diagnoseCrop(
                        cropName: _uploadedFileName ?? 'Uploaded Plant',
                        category: 'leaf',
                        imageBytes: _uploadedImageBytes,
                      )
                      .then((res) {
                    if (mounted) {
                      setState(() {
                        _diagnosis = res;
                        _isScanning = false;
                      });
                    }
                  });
                } else {
                  _performScan(_selectedPhoto);
                }
              },
              child: SizedBox(
                width: 68,
                height: 68,
                child: Center(
                  child: Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2.5),
                    ),
                    child: Center(
                      child: Icon(
                        _isScanning ? Icons.hourglass_top_rounded : Icons.camera_alt_rounded,
                        color: Colors.white,
                        size: 26,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // 3. REAL PHONE GALLERY UPLOAD BUTTON
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _pickRealPhotoFromPhoneGallery,
              borderRadius: BorderRadius.circular(22),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF8F1),
                        borderRadius: BorderRadius.circular(23),
                        border: Border.all(color: const Color(0xFFA6DBB2), width: 1.2),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.drive_folder_upload_rounded,
                          color: AppColors.primaryGreen,
                          size: 24,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isHindi ? 'गैलरी अपलोड' : 'Phone Gallery',
                      style: const TextStyle(
                        fontFamily: 'Mukta',
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryGreen,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// COOL QUICK OPTIONS (When no scan has been taken yet)
  Widget _buildCoolQuickOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Gallery upload hero banner
        Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          child: InkWell(
            onTap: _pickRealPhotoFromPhoneGallery,
            borderRadius: BorderRadius.circular(18),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFE5DECE), width: 1),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.mintTint,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.add_photo_alternate_rounded,
                        color: AppColors.primaryGreen, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isHindi ? 'गैलरी से फोटो अपलोड करें' : 'Upload Photo from Your Phone',
                          style: const TextStyle(
                            fontFamily: 'Mukta',
                            fontSize: 15.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textDark,
                          ),
                        ),
                        Text(
                          isHindi
                              ? 'फोन गैलरी से फसल की फोटो चुनें, AI खतरा व उपाय बताएगा'
                              : 'Select plant from gallery to see danger & exact remedies',
                          style: const TextStyle(
                            fontFamily: 'Mukta',
                            fontSize: 12.5,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textMuted,
                            height: 1.25,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted, size: 24),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Crisp 2x2 Visual Quick Scan Grid
        Row(
          children: [
            _buildQuickPill(
              title: isHindi ? '🌿 पत्ती रोग' : '🌿 Leaf Spot',
              photoId: 'dcim_mustard',
            ),
            const SizedBox(width: 8),
            _buildQuickPill(
              title: isHindi ? '🪴 मिट्टी जांच' : '🪴 Soil Health',
              photoId: 'storage_blacksoil',
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _buildQuickPill(
              title: isHindi ? '🐛 कीट पहचान' : '🐛 Pest Check',
              photoId: 'storage_aphids',
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Material(
                color: const Color(0xFFEFF8F1),
                borderRadius: BorderRadius.circular(16),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => _pickWithCategory('bottle_card'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFB7DEC1), width: 1),
                    ),
                    child: Center(
                      child: Text(
                        isHindi ? '🧪 दवा / मृदा कार्ड' : '🧪 Bottle / Card',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: 'Mukta',
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryGreen,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 10),

        // Non-Agri Rejection Demo Pill
        Center(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                final testPhoto = _deviceGallery.firstWhere(
                  (s) => s.category == ScanCategory.nonAgri,
                );
                _performScan(testPhoto);
              },
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.warning_amber_rounded, size: 16, color: Color(0xFFDC2626)),
                    const SizedBox(width: 6),
                    Text(
                      isHindi ? 'गैर-कृषि फोटो टेस्ट करें' : 'Test Non-Agri Photo Rejection',
                      style: const TextStyle(
                        fontFamily: 'Mukta',
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFDC2626),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickPill({required String title, required String photoId}) {
    return Expanded(
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            setState(() {
              _uploadedImageBytes = null;
              _uploadedFileName = null;
            });
            final photo = _deviceGallery.firstWhere((s) => s.id == photoId);
            _performScan(photo);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE5DECE), width: 1),
            ),
            child: Center(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: 'Mukta',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// REPORT: WHAT IS THE DANGER IN THAT PLANT & WHAT TO DO
  Widget _buildDangerAndActionReport() {
    final d = _diagnosis!;

    // Case 1: Non-Agricultural or Unclear Image Rejection
    if (!d.isRelevant) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF5F3),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFFCA5A5), width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.no_photography_rounded,
                    color: Color(0xFFDC2626), size: 24),
                const SizedBox(width: 8),
                Text(
                  isHindi ? 'गैर-कृषि या अस्पष्ट फोटो' : 'Not a Farming Image',
                  style: const TextStyle(
                    fontFamily: 'Mukta',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF991B1B),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              d.getIrrelevanceReason(isHindi),
              style: const TextStyle(
                fontFamily: 'Mukta',
                fontSize: 13.5,
                fontWeight: FontWeight.w500,
                color: Color(0xFF7F1D1D),
                height: 1.3,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton.icon(
                onPressed: _pickRealPhotoFromPhoneGallery,
                icon: const Icon(Icons.drive_folder_upload_rounded, size: 20, color: Colors.white),
                label: Text(
                  isHindi ? 'गैलरी से फसल फोटो अपलोड करें' : 'Upload Plant from Gallery',
                  style: const TextStyle(
                    fontFamily: 'Mukta',
                    fontSize: 14.5,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFDC2626),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Case 2: Full "DANGER IN PLANT" & "WHAT TO DO" Report
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // SECTION 1: WHAT IS THE DANGER IN THAT PLANT?
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: const Color(0xFFFED7AA), width: 1.2),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0C000000),
                offset: Offset(0, 3),
                blurRadius: 8,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Tag & Severity
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF2F2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFFCA5A5), width: 0.8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.warning_amber_rounded, size: 14, color: Color(0xFFDC2626)),
                        const SizedBox(width: 4),
                        Text(
                          isHindi ? 'पौधे में खतरा:' : 'DANGER IN PLANT:',
                          style: const TextStyle(
                            fontFamily: 'Mukta',
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                            color: Color(0xFFDC2626),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      d.getSeverity(isHindi),
                      style: const TextStyle(
                        fontFamily: 'Mukta',
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFB45309),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // Disease & Crop Name
              Text(
                d.getDiseaseName(isHindi),
                style: const TextStyle(
                  fontFamily: 'Mukta',
                  fontSize: 21,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                  height: 1.15,
                ),
              ),
              Text(
                '${isHindi ? 'प्रभावित फसल:' : 'Affected Crop:'} ${d.getCropName(isHindi)} (${_uploadedFileName ?? _selectedPhoto.fileName})',
                style: const TextStyle(
                  fontFamily: 'Mukta',
                  fontSize: 12.5,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textMuted,
                ),
              ),

              const SizedBox(height: 10),

              // Danger Headline & Yield Loss Forecast
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF7ED),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFFDBA74), width: 1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      d.getDangerTitle(isHindi),
                      style: const TextStyle(
                        fontFamily: 'Mukta',
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFC2410C),
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      d.getDangerDescription(isHindi),
                      style: const TextStyle(
                        fontFamily: 'Mukta',
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF9A3412),
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 14),

        // SECTION 2: WHAT TO DO (ACTION PLAN)
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: const Color(0xFFE5DECE), width: 1),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0C000000),
                offset: Offset(0, 3),
                blurRadius: 8,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: What to do
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColors.mintTint,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.health_and_safety_rounded,
                            color: AppColors.primaryGreen, size: 18),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        isHindi ? 'अब क्या करें? (तुरंत समाधान)' : 'What To Do (Immediate Action)',
                        style: const TextStyle(
                          fontFamily: 'Mukta',
                          fontSize: 16.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                        ),
                      ),
                    ],
                  ),
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _speakDiagnosis,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _isSpeaking ? AppColors.accentGold : AppColors.mintTint,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _isSpeaking ? Icons.volume_up_rounded : Icons.volume_up_outlined,
                              size: 15,
                              color: _isSpeaking ? Colors.white : AppColors.primaryGreen,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              isHindi ? 'सुनें' : 'Listen',
                              style: TextStyle(
                                fontFamily: 'Mukta',
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600,
                                color: _isSpeaking ? Colors.white : AppColors.primaryGreen,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Step 1: Immediate Action Today
              _buildActionStep(
                badge: isHindi ? '१. आज ही करें' : '1. Do Today',
                badgeColor: const Color(0xFFC05621),
                text: d.getImmediateAction(isHindi),
              ),

              const SizedBox(height: 10),

              // Step 2: Organic Remedy
              _buildActionStep(
                badge: isHindi ? '२. जैविक उपाय' : '2. Organic',
                badgeColor: const Color(0xFF2E7D32),
                text: d.getOrganicTreatment(isHindi),
              ),

              const SizedBox(height: 10),

              // Step 3: Chemical Treatment & Dosage
              _buildActionStep(
                badge: isHindi ? '३. दवा व खुराक' : '3. Chemical',
                badgeColor: const Color(0xFF1565C0),
                text: d.getChemicalTreatment(isHindi),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Action Buttons: Save to Diary & Scan Another
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 46,
                child: ElevatedButton.icon(
                  onPressed: _addToDiary,
                  icon: const Icon(Icons.bookmark_add_outlined, size: 18, color: Colors.white),
                  label: Text(
                    isHindi ? 'डायरी में जोड़ें' : 'Save to Diary',
                    style: const TextStyle(
                      fontFamily: 'Mukta',
                      fontSize: 14.5,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Material(
              color: const Color(0xFFF4F0E4),
              borderRadius: BorderRadius.circular(14),
              child: InkWell(
                onTap: _clearDiagnosis,
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  height: 46,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  alignment: Alignment.center,
                  child: Text(
                    isHindi ? 'नया स्कैन' : 'Scan New',
                    style: const TextStyle(
                      fontFamily: 'Mukta',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionStep({
    required String badge,
    required Color badgeColor,
    required String text,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: AppColors.creamBg.withOpacity(0.55),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderLight, width: 0.9),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: badgeColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(7),
            ),
            child: Text(
              badge,
              style: TextStyle(
                fontFamily: 'Mukta',
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: badgeColor,
              ),
            ),
          ),
          const SizedBox(height: 5),
          Text(
            text,
            style: const TextStyle(
              fontFamily: 'Mukta',
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.textDark,
              height: 1.32,
            ),
          ),
        ],
      ),
    );
  }
}

/// Custom painter for camera reticle corners, flash effect, and laser scanning line
class _ScannerLaserPainter extends CustomPainter {
  final double laserPos;
  final bool isScanning;
  final bool isFlashOn;

  _ScannerLaserPainter({
    required this.laserPos,
    required this.isScanning,
    required this.isFlashOn,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (isFlashOn) {
      final flashPaint = Paint()
        ..shader = RadialGradient(
          center: Alignment.center,
          radius: 0.8,
          colors: [
            Colors.white.withOpacity(0.38),
            Colors.white.withOpacity(0.0),
          ],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
      canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), flashPaint);
    }

    // Corner brackets [  ]
    final bracketColor = isScanning ? const Color(0xFF00E676) : const Color(0xFFF2B134);
    final bracketPaint = Paint()
      ..color = bracketColor
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    const double margin = 20.0;
    const double len = 24.0;
    final double left = margin;
    final double top = margin;
    final double right = size.width - margin;
    final double bottom = size.height - margin;

    // Top-left
    canvas.drawLine(Offset(left, top), Offset(left + len, top), bracketPaint);
    canvas.drawLine(Offset(left, top), Offset(left, top + len), bracketPaint);

    // Top-right
    canvas.drawLine(Offset(right, top), Offset(right - len, top), bracketPaint);
    canvas.drawLine(Offset(right, top), Offset(right - len, top + len), bracketPaint);

    // Bottom-left
    canvas.drawLine(Offset(left, bottom), Offset(left + len, bottom), bracketPaint);
    canvas.drawLine(Offset(left, bottom), Offset(left, bottom - len), bracketPaint);

    // Bottom-right
    canvas.drawLine(Offset(right, bottom), Offset(right - len, bottom), bracketPaint);
    canvas.drawLine(Offset(right, bottom), Offset(right - len, bottom - len), bracketPaint);

    // Laser Line
    final double ly = size.height * laserPos;
    final laserColor = isScanning ? const Color(0xFF00E676) : const Color(0xFFF2B134);

    final linePaint = Paint()
      ..color = laserColor
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final glowPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          laserColor.withOpacity(0.0),
          laserColor.withOpacity(0.25),
        ],
      ).createShader(Rect.fromLTWH(margin, ly - 20, size.width - (margin * 2), 20));

    canvas.drawRect(Rect.fromLTWH(margin, ly - 20, size.width - (margin * 2), 20), glowPaint);
    canvas.drawLine(Offset(margin, ly), Offset(size.width - margin, ly), linePaint);
  }

  @override
  bool shouldRepaint(covariant _ScannerLaserPainter oldDelegate) {
    return oldDelegate.laserPos != laserPos ||
        oldDelegate.isScanning != isScanning ||
        oldDelegate.isFlashOn != isFlashOn;
  }
}
