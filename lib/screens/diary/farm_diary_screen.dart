import 'package:flutter/material.dart';
import '../../l10n/app_strings.dart';
import '../../models/diary_entry.dart';
import '../../services/storage_service.dart';
import '../../theme/app_theme.dart';

class FarmDiaryScreen extends StatefulWidget {
  const FarmDiaryScreen({Key? key}) : super(key: key);

  @override
  State<FarmDiaryScreen> createState() => _FarmDiaryScreenState();
}

class _FarmDiaryScreenState extends State<FarmDiaryScreen> {
  final StorageService _storage = StorageService();
  List<DiaryEntry> _entries = [];

  @override
  void initState() {
    super.initState();
    _loadEntries();
    _storage.addListener(_onStorageChanged);
  }

  @override
  void dispose() {
    _storage.removeListener(_onStorageChanged);
    super.dispose();
  }

  void _onStorageChanged() {
    if (mounted) _loadEntries();
  }

  void _loadEntries() {
    setState(() {
      _entries = _storage.getDiaryEntries();
    });
  }

  void _quickLogActivity(String activityName, String category, String cropName) async {
    final entry = DiaryEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: activityName,
      category: category,
      date: 'Today',
      notes: '$activityName performed on $cropName field.',
    );
    await _storage.addDiaryEntry(entry);
    _loadEntries();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '✓ $activityName logged for $cropName!',
            style: const TextStyle(fontFamily: 'Mukta', fontWeight: FontWeight.w500),
          ),
          backgroundColor: AppColors.primaryGreen,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _openNewEntryDialog() {
    final titleCtrl = TextEditingController();
    final cropCtrl = TextEditingController(text: 'Ashwagandha · 1 acre');
    final notesCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'New Diary Entry / नई प्रविष्टि',
                style: TextStyle(
                  fontFamily: 'Mukta',
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: titleCtrl,
                decoration: const InputDecoration(
                  labelText: 'Activity (e.g. Checked leaves, Pruning)',
                ),
                style: const TextStyle(fontFamily: 'Mukta'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: cropCtrl,
                decoration: const InputDecoration(
                  labelText: 'Crop & Area (e.g. Tulsi · 1 acre)',
                ),
                style: const TextStyle(fontFamily: 'Mukta'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: notesCtrl,
                decoration: const InputDecoration(
                  labelText: 'Notes (optional)',
                ),
                style: const TextStyle(fontFamily: 'Mukta'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  if (titleCtrl.text.trim().isNotEmpty) {
                    final entry = DiaryEntry(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      title: titleCtrl.text.trim(),
                      category: cropCtrl.text.trim(),
                      date: 'Today',
                      notes: notesCtrl.text.trim(),
                    );
                    await _storage.addDiaryEntry(entry);
                    _loadEntries();
                    Navigator.pop(ctx);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Save Entry / प्रविष्टि सहेजें',
                  style: TextStyle(fontFamily: 'Mukta', fontSize: 16, fontWeight: FontWeight.w500),
                ),
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
              // 1. Header with Circular Back Button
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
                          isHindi ? 'खेत की दैनिक डायरी' : 'YOUR FIELD NOTES',
                          style: const TextStyle(
                            fontFamily: 'Mukta',
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.8,
                            color: Color(0xFF3A6B4A),
                          ),
                        ),
                        Text(
                          isHindi ? 'खेत डायरी' : 'Farm Diary',
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
                isHindi
                    ? 'दैनिक कृषि गतिविधियों का हिसाब रखें।'
                    : 'Keep track of daily field activities.',
                style: const TextStyle(
                  fontFamily: 'Mukta',
                  fontSize: 14.5,
                  color: AppColors.textMuted, fontWeight: FontWeight.w400,
                ),
              ),

              const SizedBox(height: 16),

              // 2. Section: What did you do today?
              Text(
                isHindi ? 'आज आपने क्या किया?' : 'What did you do today?',
                style: const TextStyle(
                  fontFamily: 'Mukta',
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
              ),

              const SizedBox(height: 10),

              // 4 Quick Action Activity Cards in Row
              Row(
                children: [
                  // 1. Watering
                  _buildQuickActionCard(
                    title: isHindi ? 'सिंचाई' : 'Watering',
                    icon: Icons.water_drop_outlined,
                    bgColor: const Color(0xFFDDEBF3),
                    iconColor: const Color(0xFF18566F),
                    onTap: () => _quickLogActivity('Watered', 'Irrigation', 'Tulsi'),
                  ),
                  const SizedBox(width: 8),
                  // 2. Weeding
                  _buildQuickActionCard(
                    title: isHindi ? 'निराई' : 'Weeding',
                    icon: Icons.grass_rounded,
                    bgColor: const Color(0xFFE2EFDF),
                    iconColor: const Color(0xFF1E4D2B),
                    onTap: () => _quickLogActivity('Weeded', 'Field Care', 'Ashwagandha'),
                  ),
                  const SizedBox(width: 8),
                  // 3. Fertiliser
                  _buildQuickActionCard(
                    title: isHindi ? 'खाद' : 'Fertiliser',
                    icon: Icons.shopping_bag_outlined,
                    bgColor: const Color(0xFFFCEFD0),
                    iconColor: const Color(0xFF7A4D00),
                    onTap: () => _quickLogActivity('Applied Organic Compost', 'Nutrition', 'Ashwagandha'),
                  ),
                  const SizedBox(width: 8),
                  // 4. Spraying
                  _buildQuickActionCard(
                    title: isHindi ? 'छिड़काव' : 'Spraying',
                    icon: Icons.sanitizer_outlined,
                    bgColor: const Color(0xFFF3D3C4),
                    iconColor: const Color(0xFF8E3F20),
                    onTap: () => _quickLogActivity('Neem Oil Spray', 'Pest Control', 'Tulsi'),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              // 3. Section: Recent entries
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isHindi ? 'हाल की प्रविष्टियां' : 'Recent entries',
                    style: const TextStyle(
                      fontFamily: 'Mukta',
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark,
                    ),
                  ),
                  Text(
                    isHindi ? 'नमूना प्रविष्टियां' : 'Sample entries',
                    style: const TextStyle(
                      fontFamily: 'Mukta',
                      fontSize: 13,
                      fontWeight: FontWeight.w400, color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Recent Entries Container (.c, padding: 4 14)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
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
                    // Item 1: Checked leaves (Ashwagandha · 1 acre, Today)
                    _buildDiaryRow(
                      icon: Icons.eco_outlined,
                      iconBg: const Color(0xFFE2EFDF),
                      iconColor: AppColors.primaryGreen,
                      title: isHindi ? 'पत्तियों की जांच की' : 'Checked leaves',
                      subtitle: isHindi ? 'अश्वगंधा · 1 एकड़' : 'Ashwagandha · 1 acre',
                      time: isHindi ? 'आज' : 'Today',
                      showDivider: true,
                    ),
                    // Item 2: Watered (Tulsi · 1 acre, Yesterday)
                    _buildDiaryRow(
                      icon: Icons.water_drop_outlined,
                      iconBg: const Color(0xFFDDEBF3),
                      iconColor: const Color(0xFF18566F),
                      title: isHindi ? 'सिंचाई की' : 'Watered',
                      subtitle: isHindi ? 'तुलसी · 1 एकड़' : 'Tulsi · 1 acre',
                      time: isHindi ? 'कल' : 'Yesterday',
                      showDivider: true,
                    ),
                    // Item 3: Weeded (Ashwagandha · 1 acre, 2 days ago)
                    _buildDiaryRow(
                      icon: Icons.grass_rounded,
                      iconBg: const Color(0xFFE2EFDF),
                      iconColor: AppColors.primaryGreen,
                      title: isHindi ? 'निराई-गुड़ाई की' : 'Weeded',
                      subtitle: isHindi ? 'अश्वगंधा · 1 एकड़' : 'Ashwagandha · 1 acre',
                      time: isHindi ? '2 दिन पहले' : '2 days ago',
                      showDivider: _entries.isNotEmpty,
                    ),
                    // Dynamic additional user entries from storage
                    ..._entries.take(5).map((e) {
                      return _buildDiaryRow(
                        icon: Icons.edit_note_rounded,
                        iconBg: AppColors.accentGoldLight,
                        iconColor: const Color(0xFF7A4D00),
                        title: e.title,
                        subtitle: e.category,
                        time: e.date,
                        showDivider: e != _entries.last,
                      );
                    }).toList(),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // 4. Bottom Full-Width "+ New diary entry" Button
              GestureDetector(
                onTap: _openNewEntryDialog,
                child: Container(
                  width: double.infinity,
                  height: 52,
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen,
                    borderRadius: BorderRadius.circular(26),
                    boxShadow: const [
                      BoxShadow(
                        color: AppColors.primaryDark,
                        offset: Offset(0, 4),
                        blurRadius: 0,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.add, color: Colors.white, size: 20),
                      const SizedBox(width: 6),
                      Text(
                        isHindi ? 'नई डायरी प्रविष्टि' : 'New diary entry',
                        style: const TextStyle(
                          fontFamily: 'Mukta',
                          fontSize: 16.5,
                          fontWeight: FontWeight.w500,
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
    );
  }

  Widget _buildQuickActionCard({
    required String title,
    required IconData icon,
    required Color bgColor,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
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
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Icon(icon, size: 20, color: iconColor),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                title,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: 'Mukta',
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDiaryRow({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String time,
    required bool showDivider,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 11),
      decoration: BoxDecoration(
        border: showDivider
            ? const Border(bottom: BorderSide(color: Color(0xFFEEE8DA), width: 1))
            : null,
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Icon(icon, size: 20, color: iconColor),
            ),
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
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textDark,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontFamily: 'Mukta',
                    fontSize: 13,
                    fontWeight: FontWeight.w400, color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          Text(
            time,
            style: const TextStyle(
              fontFamily: 'Mukta',
              fontSize: 13,
              fontWeight: FontWeight.w400, color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}
