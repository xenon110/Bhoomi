import 'package:flutter/material.dart';
import '../../l10n/app_strings.dart';
import '../../services/storage_service.dart';
import '../../services/turso/turso_service.dart';
import '../../theme/app_theme.dart';

/// Kisan Chopal & Machinery Rental Sharing Board
/// Hyperlocal village-level communication and agricultural tool renting (tractor, rotavator, drone sprayer)
class KisanChopalScreen extends StatefulWidget {
  const KisanChopalScreen({super.key});

  @override
  State<KisanChopalScreen> createState() => _KisanChopalScreenState();
}

class _KisanChopalScreenState extends State<KisanChopalScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool get isHindi => AppLanguage().isHindi;

  final List<Map<String, dynamic>> _notices = [
    {
      'id': '1',
      'title': 'Daltonganj APMC Mandi Holiday on Friday',
      'hi': 'डाल्टनगंज मुख्य मंडी शुक्रवार को कार्तिक पूर्णिमा अवकाश हेतु बंद रहेगी।',
      'author': 'Mandi Secretary Office',
      'date': 'Today, 8:30 AM',
      'badge': 'Mandi Notice',
      'isUrgent': true,
      'icon': Icons.campaign_rounded,
    },
    {
      'id': '2',
      'title': 'Yellow Rust & Stem Blight Pest Warning',
      'hi': 'गढ़वा सीमावर्ती क्षेत्रों में सरसों व गेहूं में पीला रतुआ देखा गया है। खेत की तुरंत जांच करें।',
      'author': 'Dr. Alok Verma, KVK Scientist',
      'date': 'Yesterday',
      'badge': 'Pest Warning',
      'isUrgent': true,
      'icon': Icons.bug_report_rounded,
    },
    {
      'id': '3',
      'title': 'IFFCO Nano Urea & DAP Stock Available',
      'hi': 'चान्की पैक्स (PACS) समिति में नैनो यूरिया व डीएपी खाद का नया स्टॉक आ गया है। ₹225 प्रति बोतल।',
      'author': 'Chanki PACS Society',
      'date': '2 Nov 2026',
      'badge': 'Fertilizer Stock',
      'isUrgent': false,
      'icon': Icons.inventory_2_rounded,
    },
  ];

  final List<Map<String, dynamic>> _machinery = [
    {
      'name': 'Mahindra 575 DI (45 HP) + Rotavator',
      'hi': 'महिंद्रा ट्रैक्टर + 7 फीट रोटावेटर (गहरी जोताई)',
      'ownerEn': 'Rameshwar Yadav (Farmer)',
      'ownerHi': 'रामेश्वर यादव (किसान)',
      'rateEn': '₹600 / Hour',
      'rateHi': '₹600 / घंटा',
      'village': 'Chanki (1.5 km)',
      'phone': '+91 94311 11223',
      'icon': Icons.agriculture_rounded,
      'isAvailable': true,
    },
    {
      'name': '16L Battery Power Sprayer',
      'hi': 'बैटरी स्प्रेयर पंप 16 लीटर (स्प्रेयर पाइप समेत)',
      'ownerEn': 'Dinesh Mahto',
      'ownerHi': 'दिनेश महतो',
      'rateEn': '₹120 / Day',
      'rateHi': '₹120 / दिन',
      'village': 'Satbarwa (3 km)',
      'phone': '+91 98350 44556',
      'icon': Icons.shower_outlined,
      'isAvailable': true,
    },
    {
      'name': 'Agricultural Drone Spraying Service',
      'hi': 'ड्रोन द्वारा 10 मिनट में 1 एकड़ नैनो यूरिया छिड़काव',
      'ownerEn': 'Palamu Kisan Drone Sangha',
      'ownerHi': 'पलामू किसान ड्रोन संघ',
      'rateEn': '₹350 / Acre',
      'rateHi': '₹350 / एकड़',
      'village': 'Daltonganj Block',
      'phone': '+91 94315 77889',
      'icon': Icons.flight_takeoff_rounded,
      'isAvailable': true,
    },
    {
      'name': '4 HP Solar Tubewell Water Pump',
      'hi': 'सोलर बोरवेल पंप सेट (4 इंच पाइप सिंचाई)',
      'ownerEn': 'Shivpujan Singh',
      'ownerHi': 'शिवपूजन सिंह',
      'rateEn': '₹140 / Hour',
      'rateHi': '₹140 / घंटा',
      'village': 'Chanki East (0.8 km)',
      'phone': '+91 94312 99001',
      'icon': Icons.water_drop_outlined,
      'isAvailable': false,
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _syncChopalWithTurso();
  }

  Future<void> _syncChopalWithTurso() async {
    try {
      final cloudNotices = await TursoService().fetchChopalNoticesCloud();
      if (cloudNotices.isNotEmpty && mounted) {
        setState(() {
          for (final cn in cloudNotices) {
            if (!_notices.any((n) => n['id'] == cn['id'])) {
              _notices.insert(0, {
                'id': cn['id'],
                'title': cn['title'],
                'hi': cn['title_hi'] ?? cn['title'],
                'author': cn['author'] ?? 'Farmer Post',
                'date': cn['date'] ?? 'Recent',
                'badge': cn['badge'] ?? 'Notice',
                'isUrgent': cn['is_urgent'] == 1,
                'icon': Icons.campaign_rounded,
              });
            }
          }
        });
      } else {
        // Seed initial notices to Turso cloud
        for (final n in _notices) {
          await TursoService().upsertChopalNoticeCloud(n);
        }
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showAddNoticeDialog() {
    final isHindi = AppLanguage().isHindi;
    final titleCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: Text(isHindi ? 'चौपाल सूचना साझा करें' : 'Share Community Notice', style: const TextStyle(fontFamily: 'Mukta', fontWeight: FontWeight.w600)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleCtrl,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: isHindi ? 'अपने क्षेत्र के किसानों के लिए सूचना टाइप करें...' : 'Type notice for local farmers...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryGreen, foregroundColor: Colors.white),
            onPressed: () {
              if (titleCtrl.text.trim().isNotEmpty) {
                final farmerName = StorageService().getProfile().name;
                final newNotice = {
                  'id': DateTime.now().millisecondsSinceEpoch.toString(),
                  'title': titleCtrl.text.trim(),
                  'hi': titleCtrl.text.trim(),
                  'author': farmerName.isNotEmpty
                      ? '$farmerName (You)'
                      : (isHindi ? 'आप (किसान साथी)' : 'You (Farmer)'),
                  'date': 'Just now',
                  'badge': 'Farmer Post',
                  'isUrgent': false,
                  'icon': Icons.record_voice_over_rounded,
                };
                setState(() {
                  _notices.insert(0, newNotice);
                });
                TursoService().upsertChopalNoticeCloud(newNotice);
              }
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(isHindi ? '✓ आपकी सूचना चौपाल पर पोस्ट हो गई!' : '✓ Your notice has been posted to Chopal!'), backgroundColor: AppColors.primaryGreen),
              );
            },
            child: Text(isHindi ? 'पोस्ट करें' : 'Post Notice'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isHindi = AppLanguage().isHindi;
    return Scaffold(
      backgroundColor: AppColors.creamBg,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: AppStyles.backButtonBox,
                      child: const Center(
                        child: Icon(Icons.arrow_back_rounded, color: AppColors.textDark, size: 20),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('VILLAGE COMMUNITY & RENTALS', style: AppStyles.kicker),
                      Text(
                        isHindi ? 'किसान चौपाल व यंत्र साझा' : 'Village Community & Tool Share',
                        style: const TextStyle(
                          fontFamily: 'Mukta',
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDark,
                          height: 1.1,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // Tab Bar
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: TabBar(
                controller: _tabController,
                labelColor: AppColors.primaryGreen,
                unselectedLabelColor: AppColors.textMuted,
                indicatorColor: AppColors.primaryGreen,
                indicatorWeight: 3,
                labelStyle: const TextStyle(fontFamily: 'Mukta', fontSize: 14, fontWeight: FontWeight.w600),
                unselectedLabelStyle: const TextStyle(fontFamily: 'Mukta', fontSize: 14, fontWeight: FontWeight.w400),
                tabs: [
                  Tab(text: isHindi ? '📢 चौपाल समाचार' : '📢 Community Notices'),
                  Tab(text: isHindi ? '🚜 यंत्र साझा' : '🚜 Shared Machinery'),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Tab Views
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Tab 1: Notices
                  _buildNoticesTab(isHindi),
                  // Tab 2: Machinery
                  _buildMachineryTab(isHindi),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoticesTab(bool isHindi) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      child: Column(
        children: [
          // Post Notice Button
          GestureDetector(
            onTap: _showAddNoticeDialog,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.mintTint,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFC3DFC0)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.edit_note_rounded, color: AppColors.primaryGreen, size: 22),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      isHindi ? 'गाँव के किसानों के साथ सूचना साझा करें...' : 'Share an update or notice with fellow farmers...',
                      style: const TextStyle(fontFamily: 'Mukta', fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.primaryGreen),
                    ),
                  ),
                  const Icon(Icons.add_circle, color: AppColors.primaryGreen, size: 20),
                ],
              ),
            ),
          ),

          const SizedBox(height: 14),

          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _notices.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (ctx, idx) {
              final n = _notices[idx];
              final isUrgent = n['isUrgent'] as bool;
              return Container(
                padding: const EdgeInsets.all(14),
                decoration: AppStyles.cardBox,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: isUrgent ? const Color(0xFFFDE8E8) : AppColors.creamBg,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(n['icon'] as IconData, size: 14, color: isUrgent ? const Color(0xFFB03A2E) : AppColors.primaryGreen),
                              const SizedBox(width: 4),
                              Text(
                                n['badge'] as String,
                                style: TextStyle(
                                  fontFamily: 'Mukta',
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: isUrgent ? const Color(0xFFB03A2E) : AppColors.primaryGreen,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          n['date'] as String,
                          style: const TextStyle(fontFamily: 'Mukta', fontSize: 11.5, color: AppColors.textMuted),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      n['hi'] as String,
                      style: const TextStyle(
                        fontFamily: 'Mukta',
                        fontSize: 14.5,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textDark,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.person_pin_circle_outlined, size: 14, color: AppColors.textMuted),
                        const SizedBox(width: 4),
                        Text(
                          '${isHindi ? "द्वारा: " : "By: "}${n['author']}',
                          style: const TextStyle(fontFamily: 'Mukta', fontSize: 12, color: AppColors.textMuted),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMachineryTab(bool isHindi) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      child: Column(
        children: [
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _machinery.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (ctx, idx) {
              final m = _machinery[idx];
              final isAvail = m['isAvailable'] as bool;
              return Container(
                padding: const EdgeInsets.all(14),
                decoration: AppStyles.cardBox,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppColors.mintTint,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Center(child: Icon(m['icon'] as IconData, color: AppColors.primaryGreen, size: 24)),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                m['name'] as String,
                                style: const TextStyle(
                                  fontFamily: 'Mukta',
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textDark,
                                ),
                              ),
                              if (isHindi)
                                Text(
                                  m['hi'] as String,
                                  style: const TextStyle(fontFamily: 'Mukta', fontSize: 12.5, color: AppColors.textMuted),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              (isHindi ? m['rateHi'] : m['rateEn']) as String,
                              style: const TextStyle(
                                fontFamily: 'Mukta',
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primaryGreen,
                              ),
                            ),
                            Text(
                              '${isHindi ? "मालिक: " : "Owner: "}${isHindi ? m['ownerHi'] : m['ownerEn']} (${m['village']})',
                              style: const TextStyle(fontFamily: 'Mukta', fontSize: 12, color: AppColors.textMuted),
                            ),
                          ],
                        ),
                        GestureDetector(
                          onTap: () {
                            if (!isAvail) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(isHindi ? 'यह यंत्र अभी किराए पर चल रहा है।' : 'This machinery is currently booked.'),
                                  backgroundColor: const Color(0xFFB03A2E),
                                ),
                              );
                              return;
                            }
                            _showRentMachineryModal(m, isHindi);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                            decoration: BoxDecoration(
                              color: isAvail ? AppColors.primaryGreen : Colors.grey.shade400,
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.call_rounded, size: 14, color: Colors.white),
                                const SizedBox(width: 4),
                                Text(
                                  isAvail ? (isHindi ? 'किराया लें' : 'Rent Now') : (isHindi ? 'व्यस्त है' : 'Booked'),
                                  style: const TextStyle(
                                    fontFamily: 'Mukta',
                                    fontSize: 12.5,
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
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showRentMachineryModal(Map<String, dynamic> m, bool isHindi) {
    int hours = 3;
    final ownerName = isHindi ? m['ownerHi'] : m['ownerEn'];
    final toolName = isHindi ? m['hi'] : m['name'];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (modalCtx, setModalState) {
          return Container(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
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
                    decoration: BoxDecoration(color: const Color(0xFFDDD6C4), borderRadius: BorderRadius.circular(2)),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(color: AppColors.mintTint, borderRadius: BorderRadius.circular(16)),
                      child: Center(child: Icon(m['icon'] as IconData, color: AppColors.primaryGreen, size: 26)),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(toolName as String, style: const TextStyle(fontFamily: 'Mukta', fontSize: 17, fontWeight: FontWeight.w600, color: AppColors.textDark)),
                          Text('मालिक: $ownerName · ${m['village']}', style: const TextStyle(fontFamily: 'Mukta', fontSize: 13, color: AppColors.textMuted)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: AppColors.creamBg, borderRadius: BorderRadius.circular(16)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(isHindi ? 'किराया दर:' : 'Rental Rate:', style: const TextStyle(fontFamily: 'Mukta', fontSize: 14)),
                      Text((isHindi ? m['rateHi'] : m['rateEn']) as String, style: const TextStyle(fontFamily: 'Mukta', fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.primaryGreen)),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(isHindi ? 'आवश्यक समय (घंटे):' : 'Duration (Hours):', style: const TextStyle(fontFamily: 'Mukta', fontSize: 14, fontWeight: FontWeight.w500)),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline_rounded, color: AppColors.primaryGreen),
                          onPressed: () {
                            if (hours > 1) setModalState(() => hours--);
                          },
                        ),
                        Text('$hours घंटे', style: const TextStyle(fontFamily: 'Mukta', fontSize: 16, fontWeight: FontWeight.w600)),
                        IconButton(
                          icon: const Icon(Icons.add_circle_outline_rounded, color: AppColors.primaryGreen),
                          onPressed: () {
                            if (hours < 12) setModalState(() => hours++);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.primaryGreen),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        icon: const Icon(Icons.phone_rounded, color: AppColors.primaryGreen, size: 18),
                        label: Text(isHindi ? 'कॉल करें' : 'Call Owner', style: const TextStyle(fontFamily: 'Mukta', fontWeight: FontWeight.w600, color: AppColors.primaryGreen)),
                        onPressed: () {
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Calling $ownerName (${m['phone']})...'),
                              backgroundColor: AppColors.primaryGreen,
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryGreen,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        icon: const Icon(Icons.check_circle_outline_rounded, size: 18),
                        label: Text(isHindi ? 'बुकिंग भेजें' : 'Book Rental', style: const TextStyle(fontFamily: 'Mukta', fontWeight: FontWeight.w600)),
                        onPressed: () {
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(isHindi ? '✓ $ownerName को $hours घंटे का बुकिंग संदेश भेज दिया गया!' : '✓ Booking request sent to $ownerName for $hours hours!'),
                              backgroundColor: AppColors.primaryGreen,
                              duration: const Duration(seconds: 3),
                            ),
                          );
                        },
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
}

