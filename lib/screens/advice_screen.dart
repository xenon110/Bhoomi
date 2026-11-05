import 'package:flutter/material.dart';
import '../l10n/app_strings.dart';
import '../models/diary_entry.dart';
import '../services/storage_service.dart';
import '../services/weather_service.dart';
import '../theme/app_theme.dart';
import 'scan/scan_ask_screen.dart';

class AdviceScreen extends StatefulWidget {
  final VoidCallback? onBackToHome;
  const AdviceScreen({Key? key, this.onBackToHome}) : super(key: key);

  @override
  State<AdviceScreen> createState() => _AdviceScreenState();
}

class _AdviceScreenState extends State<AdviceScreen> {
  final StorageService _storage = StorageService();
  WeatherForecast? _weather = WeatherForecast.fallback();
  String? _currentlySpeakingCrop;
  final Set<String> _completedTasks = {};

  @override
  void initState() {
    super.initState();
    _fetchWeather();
    _storage.addListener(_onStorageChanged);
  }

  @override
  void dispose() {
    _storage.removeListener(_onStorageChanged);
    super.dispose();
  }

  void _onStorageChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _fetchWeather() async {
    final w = await WeatherService().getWeather();
    if (mounted) setState(() => _weather = w);
  }

  void _toggleChecklistTask(String cropTitle, String item) {
    final taskKey = '$cropTitle::$item';
    final isDone = _completedTasks.contains(taskKey);
    setState(() {
      if (isDone) {
        _completedTasks.remove(taskKey);
      } else {
        _completedTasks.add(taskKey);
      }
    });

    if (!isDone) {
      final isHindi = AppLanguage().isHindi;
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isHindi ? '✓ कार्य पूरा हुआ: $item' : '✓ Task marked completed: $item',
            style: const TextStyle(fontFamily: 'Mukta'),
          ),
          backgroundColor: AppColors.primaryGreen,
          action: SnackBarAction(
            label: isHindi ? 'डायरी में जोड़ें' : 'Log to Diary',
            textColor: AppColors.cardGold,
            onPressed: () async {
              final newEntry = DiaryEntry(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                title: '$cropTitle: $item',
                category: 'Advisory Task',
                date: 'Today',
                notes: 'Completed field advisory task: $item',
              );
              await _storage.addDiaryEntry(newEntry);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(isHindi ? '✓ कृषि डायरी में सहेज लिया गया!' : '✓ Logged into Farm Diary!'),
                    backgroundColor: AppColors.primaryGreen,
                  ),
                );
              }
            },
          ),
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  void _showWeatherDetailsModal(BuildContext context, bool isHindi) {
    final w = _weather ?? WeatherForecast.fallback();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
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
                decoration: BoxDecoration(color: const Color(0xFFDDD6C4), borderRadius: BorderRadius.circular(2)),
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
                      isHindi ? 'स्थानीय मौसम व खेत पूर्वानुमान' : 'Local Weather & Outlook',
                      style: const TextStyle(fontFamily: 'Mukta', fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.textDark),
                    ),
                    Text(
                      '${_storage.getProfile().district}, ${_storage.getProfile().state}',
                      style: const TextStyle(fontFamily: 'Mukta', fontSize: 13, color: AppColors.textMuted),
                    ),
                  ],
                ),
                Text(
                  '${w.temperature.round()}°C',
                  style: const TextStyle(fontFamily: 'Mukta', fontSize: 32, fontWeight: FontWeight.w600, color: AppColors.primaryGreen),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                _buildWeatherMiniCard(Icons.water_drop_outlined, isHindi ? 'नमी' : 'Humidity', '${w.humidity}%'),
                const SizedBox(width: 8),
                _buildWeatherMiniCard(Icons.umbrella_outlined, isHindi ? 'बारिश' : 'Rain', '${w.rainChance}%'),
                const SizedBox(width: 8),
                _buildWeatherMiniCard(Icons.air_rounded, isHindi ? 'हवा' : 'Wind', '${w.windSpeed} km/h'),
              ],
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.mintTint,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Icon(Icons.tips_and_updates_rounded, color: AppColors.primaryGreen, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      w.agriculturalAdvice,
                      style: const TextStyle(fontFamily: 'Mukta', fontSize: 12.5, color: Color(0xFF1B2A21), height: 1.3),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            ...w.dailyForecasts.map((d) {
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.creamBg,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(d.day, style: const TextStyle(fontFamily: 'Mukta', fontSize: 14, fontWeight: FontWeight.w600)),
                    Text(d.temp, style: const TextStyle(fontFamily: 'Mukta', fontSize: 13, color: AppColors.primaryGreen, fontWeight: FontWeight.w500)),
                    Text(d.condition, style: const TextStyle(fontFamily: 'Mukta', fontSize: 12.5, color: AppColors.textMuted)),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherMiniCard(IconData icon, String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.creamBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Column(
          children: [
            Icon(icon, size: 18, color: AppColors.primaryGreen),
            const SizedBox(height: 2),
            Text(value, style: const TextStyle(fontFamily: 'Mukta', fontSize: 14, fontWeight: FontWeight.w600)),
            Text(label, style: const TextStyle(fontFamily: 'Mukta', fontSize: 11, color: AppColors.textMuted)),
          ],
        ),
      ),
    );
  }

  void _showVoiceAdviceModal({
    required BuildContext context,
    required String cropName,
    required String stage,
    required List<String> checklist,
    required bool isHindi,
  }) {
    setState(() => _currentlySpeakingCrop = cropName);
    showModalBottomSheet(
      context: context,
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
                    decoration: BoxDecoration(color: const Color(0xFFDDD6C4), borderRadius: BorderRadius.circular(2)),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: const BoxDecoration(color: AppColors.primaryGreen, shape: BoxShape.circle),
                      child: const Center(child: Icon(Icons.volume_up_rounded, color: Colors.white, size: 24)),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isHindi ? '$cropName कृषि सलाह (ऑडियो)' : '$cropName Field Guidance',
                            style: const TextStyle(fontFamily: 'Mukta', fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textDark),
                          ),
                          Text(stage, style: const TextStyle(fontFamily: 'Mukta', fontSize: 13, color: AppColors.textMuted)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.mintTint,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.graphic_eq_rounded, color: AppColors.primaryGreen, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            isHindi ? 'बोलकर सुनाई जा रही मुख्य बातें:' : 'Speaking Guidance:',
                            style: const TextStyle(fontFamily: 'Mukta', fontSize: 13.5, fontWeight: FontWeight.w600, color: AppColors.primaryGreen),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ...checklist.map((c) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 3),
                        child: Text('• $c', style: const TextStyle(fontFamily: 'Mukta', fontSize: 14, color: AppColors.textDark, height: 1.3)),
                      )),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  ),
                  icon: const Icon(Icons.check_rounded, size: 18),
                  label: Text(isHindi ? 'समझ लिया (Done)' : 'Got it', style: const TextStyle(fontFamily: 'Mukta', fontSize: 15, fontWeight: FontWeight.w600)),
                  onPressed: () {
                    Navigator.pop(ctx);
                    setState(() => _currentlySpeakingCrop = null);
                  },
                ),
              ],
            ),
          );
        },
      ),
    ).whenComplete(() {
      if (mounted) setState(() => _currentlySpeakingCrop = null);
    });
  }

  void _simulateSpeech(String cropName) {
    setState(() => _currentlySpeakingCrop = cropName);
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.volume_up_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                AppLanguage().isHindi
                    ? 'कृषि सलाह बोलकर सुनाई जा रही है: $cropName...'
                    : 'Playing crop advisory for: $cropName...',
                style: const TextStyle(
                  fontFamily: 'Mukta',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.primaryGreen,
        duration: const Duration(seconds: 3),
      ),
    );
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) setState(() => _currentlySpeakingCrop = null);
    });
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
              // 1. Top Header with Back button
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: widget.onBackToHome ?? () => Navigator.maybePop(context),
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
                          isHindi ? 'आपकी फसलों के लिए सलाह' : 'HELP FOR YOUR CROPS',
                          style: const TextStyle(
                            fontFamily: 'Mukta',
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.8,
                            color: Color(0xFF3A6B4A),
                          ),
                        ),
                        Text(
                          isHindi ? 'आज की सलाह' : "Today's Advice",
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
                isHindi ? 'आपके खेत के लिए सरल मार्गदर्शन।' : 'Simple guidance for your farm.',
                style: const TextStyle(
                  fontFamily: 'Mukta',
                  fontSize: 14.5,
                  color: AppColors.textMuted, fontWeight: FontWeight.w400,
                ),
              ),

              const SizedBox(height: 12),

              // 2. Weather Banner (Responsive, tappable for 3-day forecast)
              InkWell(
                onTap: () => _showWeatherDetailsModal(context, isHindi),
                borderRadius: BorderRadius.circular(26),
                child: Container(
                  constraints: const BoxConstraints(minHeight: 122),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen, // #1E4D2B
                    borderRadius: BorderRadius.circular(26),
                    boxShadow: const [
                      BoxShadow(
                        color: AppColors.primaryDark, // #123320
                        offset: Offset(0, 4),
                        blurRadius: 0,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(26),
                    child: Stack(
                      children: [
                        // SVG Landscape / Weather Graphic on Right
                        Positioned(
                          right: 0,
                          top: 0,
                          bottom: 0,
                          width: 140,
                          child: CustomPaint(
                            painter: _AdviceWeatherPainter(),
                          ),
                        ),
                        // Text on Left
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    isHindi ? 'स्थानीय मौसम · ' : 'LOCAL WEATHER · ',
                                    style: TextStyle(
                                      fontFamily: 'Mukta',
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w400,
                                      letterSpacing: 0.8,
                                      color: Colors.white.withOpacity(0.85),
                                    ),
                                  ),
                                  Text(
                                    _storage.getProfile().district,
                                    style: const TextStyle(
                                      fontFamily: 'Mukta',
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.cardGold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${_weather?.temp.round() ?? 28}°C',
                                style: const TextStyle(
                                  fontFamily: 'Mukta',
                                  fontSize: 38,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                  height: 1.1,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    _weather != null
                                        ? '${_weather!.condition} · ${_weather!.rainChance}% rain'
                                        : (isHindi ? 'आंशिक बादल · 20% बारिश' : 'Partly cloudy · 20% rain'),
                                    style: const TextStyle(
                                      fontFamily: 'Mukta',
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white70, size: 11),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // 3. Section Title: "For your crops"
              Text(
                isHindi ? 'आपकी फसलों के लिए' : 'For your crops',
                style: const TextStyle(
                  fontFamily: 'Mukta',
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
              ),

              const SizedBox(height: 10),

              // Dynamic crop advice cards
              ..._buildCropAdviceList(isHindi),

              const SizedBox(height: 2),

              // 6. Camera Banner Button: "Notice any yellow spots or pests?"
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ScanAskScreen()),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.mintTint, // #E2EFDF
                    border: Border.all(color: const Color(0xFFBFDCB8), width: 1.5),
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.primaryGreen, // #1E4D2B
                          borderRadius: BorderRadius.circular(13),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.camera_alt_outlined,
                            size: 22,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isHindi
                                  ? 'पत्तियों पर पीले धब्बे या कीट दिखे?'
                                  : 'Notice any yellow spots or pests?',
                              style: const TextStyle(
                                fontFamily: 'Mukta',
                                fontSize: 15.5,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textDark,
                              ),
                            ),
                            Text(
                              isHindi
                                  ? 'Scan & Ask से तुरंत फोटो खींचें।'
                                  : 'Tap to take a photo with Scan & Ask.',
                              style: const TextStyle(
                                fontFamily: 'Mukta',
                                fontSize: 13,
                                fontWeight: FontWeight.w400,
                                color: Color(0xFF3F5547),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.chevron_right_rounded,
                        size: 22,
                        color: AppColors.textDark,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // 7. Disclaimer Warning Box
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.accentGoldLight, // #FCEFD0
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 2, right: 10),
                      child: Icon(
                        Icons.info_outline_rounded,
                        size: 18,
                        color: Color(0xFF5C3D00),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        isHindi
                          ? 'केवल सांकेतिक सलाह। उपचार से पहले स्थानीय परिस्थितियों और कृषि विशेषज्ञ से सलाह लें।'
                          : 'Sample guidance only. Verify local conditions and consult an agricultural expert before treatment.',
                        style: const TextStyle(
                          fontFamily: 'Mukta',
                          fontSize: 12.5,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF5C3D00),
                          height: 1.3,
                        ),
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
  }

  List<Widget> _buildCropAdviceList(bool isHindi) {
    final crops = _storage.getPrimaryFarm().crops;
    if (crops.isEmpty) {
      return [
        _buildCropAdviceCard(
          title: isHindi ? 'अश्वगंधा' : 'Ashwagandha',
          stage: isHindi ? 'शुरुआती विकास अवस्था' : 'Early growth stage',
          iconType: _CropIconType.ashwagandha,
          checklist: isHindi
              ? [
                  'पानी देने से पहले मिट्टी की नमी जांचें।',
                  'खरपतवार सावधानी से निकालें।',
                  'कीट या बीमारी के लिए पत्तियों की जांच करें।',
                ]
              : [
                  'Check soil moisture before watering.',
                  'Remove weeds carefully.',
                  'Inspect leaves for pest damage.',
                ],
          isSpeaking: _currentlySpeakingCrop == 'Ashwagandha',
          onListen: () => _showVoiceAdviceModal(
            context: context,
            cropName: isHindi ? 'अश्वगंधा' : 'Ashwagandha',
            stage: isHindi ? 'शुरुआती विकास अवस्था' : 'Early growth stage',
            checklist: isHindi
                ? [
                    'पानी देने से पहले मिट्टी की नमी जांचें।',
                    'खरपतवार सावधानी से निकालें।',
                    'कीट या बीमारी के लिए पत्तियों की जांच करें।',
                  ]
                : [
                    'Check soil moisture before watering.',
                    'Remove weeds carefully.',
                    'Inspect leaves for pest damage.',
                  ],
            isHindi: isHindi,
          ),
        ),
      ];
    }

    final widgets = <Widget>[];
    for (final c in crops) {
      final nameLower = c.name.toLowerCase();
      final bool isTulsi = nameLower.contains('tulsi');
      final bool isAshwagandha = nameLower.contains('ashwagandha');

      _CropIconType iconType = _CropIconType.generic;
      if (isAshwagandha) iconType = _CropIconType.ashwagandha;
      else if (isTulsi) iconType = _CropIconType.tulsi;

      List<String> checklist;
      if (isAshwagandha) {
        checklist = isHindi
            ? [
                'पानी देने से पहले मिट्टी की नमी जांचें।',
                'खरपतवार सावधानी से निकालें।',
                'कीट या बीमारी के लिए पत्तियों की जांच करें।',
              ]
            : [
                'Check soil moisture before watering.',
                'Remove weeds carefully.',
                'Inspect leaves for pest damage.',
              ];
      } else if (isTulsi) {
        checklist = isHindi
            ? [
                'पानी का ठहराव न होने दें।',
                'पौधों के बीच उचित दूरी बनाए रखें।',
                'नियमित रूप से पत्तियों का निरीक्षण करें।',
              ]
            : [
                'Avoid standing water.',
                'Maintain plant spacing.',
                'Check leaves regularly.',
              ];
      } else if (nameLower.contains('mustard')) {
        checklist = isHindi
            ? [
                'पौधों के बीच 15 सेमी की दूरी के लिए छंटाई करें।',
                'फूल आने से पहले चेपा (माहू) की जांच करें।',
                'फूल आने से पहले हल्की सिंचाई दें।',
              ]
            : [
                'Thin seedlings to maintain 15cm spacing.',
                'Inspect buds for early aphids.',
                'Provide light irrigation prior to flowering.',
              ];
      } else if (nameLower.contains('wheat')) {
        checklist = isHindi
            ? [
                'ताज मूल अवस्था पर पहली सिंचाई दें।',
                'अनुशंसित यूरिया की पहली खुराक दें।',
                'पीला रतुआ के शुरुआती लक्षणों की निगरानी करें।',
              ]
            : [
                'Provide first irrigation at crown root stage.',
                'Apply recommended nitrogen top-dress.',
                'Monitor for early signs of yellow rust.',
              ];
      } else {
        checklist = isHindi
            ? [
                'नियमित नमी की जांच करें।',
                'खरपतवार समय पर निकालें।',
                'प्राकृतिक जैविक नीम का छिड़काव करें।',
              ]
            : [
                'Check root zone moisture regularly.',
                'Remove weeds around borders.',
                'Apply organic neem preventive spray.',
              ];
      }

      final cStage = c.growthStage ?? (isHindi ? 'सक्रिय विकास अवस्था' : 'Active growth stage');

      widgets.add(
        _buildCropAdviceCard(
          title: c.name,
          stage: cStage,
          iconType: iconType,
          checklist: checklist,
          isSpeaking: _currentlySpeakingCrop == c.name,
          onListen: () => _showVoiceAdviceModal(
            context: context,
            cropName: c.name,
            stage: cStage,
            checklist: checklist,
            isHindi: isHindi,
          ),
        ),
      );
      widgets.add(const SizedBox(height: 12));
    }
    return widgets;
  }

  Widget _buildCropAdviceCard({
    required String title,
    required String stage,
    required _CropIconType iconType,
    required List<String> checklist,
    required bool isSpeaking,
    required VoidCallback onListen,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.borderLight, width: 1), // #E6E0D2
        boxShadow: const [
          BoxShadow(
            color: AppColors.cardShadow, // #E9E2D1
            offset: Offset(0, 3),
            blurRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Crop Header Row
          Row(
            children: [
              SizedBox(
                width: 44,
                height: 44,
                child: CustomPaint(
                  painter: iconType == _CropIconType.ashwagandha
                      ? _AdviceAshwagandhaPainter()
                      : _AdviceTulsiPainter(),
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
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textDark,
                      ),
                    ),
                    Text(
                      stage,
                      style: const TextStyle(
                        fontFamily: 'Mukta',
                        fontSize: 13,
                        fontWeight: FontWeight.w400, color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              // Listen Audio Button
              GestureDetector(
                onTap: onListen,
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: isSpeaking ? AppColors.accentGold : AppColors.mintTint, // #E2EFDF
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Center(
                    child: Icon(
                      isSpeaking ? Icons.volume_up_rounded : Icons.volume_up_outlined,
                      size: 22,
                      color: isSpeaking ? Colors.white : AppColors.primaryGreen,
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Checklist items (Interactive: Tap to toggle & log to Farm Diary)
          Column(
            children: checklist.map((item) {
              final isDone = _completedTasks.contains('$title::$item');
              return InkWell(
                onTap: () => _toggleChecklistTask(title, item),
                borderRadius: BorderRadius.circular(10),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 2),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Circular tick badge
                      Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          color: isDone ? AppColors.primaryGreen : const Color(0xFFDDEFD9),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Icon(
                            Icons.check_rounded,
                            size: 14,
                            color: isDone ? Colors.white : const Color(0xFF2E9B4F),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          item,
                          style: TextStyle(
                            fontFamily: 'Mukta',
                            fontSize: 14.5,
                            fontWeight: FontWeight.w400,
                            decoration: isDone ? TextDecoration.lineThrough : null,
                            color: isDone ? AppColors.textMuted : AppColors.textDark,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

enum _CropIconType { ashwagandha, tulsi, generic }

/// Weather graphic matching SVG:
/// Sun halo, sun disc, cloud shape, and 3 angled rain dashes
class _AdviceWeatherPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // 1. Sun Halo: cx: 100, cy: 42, r: 30, #F2B134, opacity: 0.22
    final haloPaint = Paint()
      ..color = const Color(0xFFF2B134).withOpacity(0.22)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(const Offset(100, 42), 30, haloPaint);

    // 2. Sun Disc: cx: 104, cy: 38, r: 20, #F2B134
    final sunPaint = Paint()
      ..color = const Color(0xFFF2B134)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(const Offset(104, 38), 20, sunPaint);

    // 3. Cloud: M42 92h60a16 16 0 0 0 0-32 22 22 0 0 0-42-4 18 18 0 0 0-18 36z
    final cloudPaint = Paint()
      ..color = Colors.white.withOpacity(0.95)
      ..style = PaintingStyle.fill;

    final cloudPath = Path();
    cloudPath.moveTo(42, 92);
    cloudPath.lineTo(102, 92);
    cloudPath.arcToPoint(const Offset(102, 60), radius: const Radius.circular(16));
    cloudPath.arcToPoint(const Offset(60, 56), radius: const Radius.circular(22));
    cloudPath.arcToPoint(const Offset(42, 92), radius: const Radius.circular(18));
    cloudPath.close();
    canvas.drawPath(cloudPath, cloudPaint);

    // 4. Rain dashes: M60 100l-4 10 M78 100l-4 10 M96 100l-4 10
    final rainPaint = Paint()
      ..color = const Color(0xFF7DB88A)
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    canvas.drawLine(const Offset(60, 100), const Offset(56, 110), rainPaint);
    canvas.drawLine(const Offset(78, 100), const Offset(74, 110), rainPaint);
    canvas.drawLine(const Offset(96, 100), const Offset(92, 110), rainPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Ashwagandha Plant squircle matching SVG (viewBox 0 0 52 52)
class _AdviceAshwagandhaPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 52.0;
    canvas.scale(scale, scale);

    // Squircle background: rx=16, #E2EFDF
    final bgPaint = Paint()
      ..color = const Color(0xFFE2EFDF)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(0, 0, 52, 52), const Radius.circular(16)),
      bgPaint,
    );

    // Stem: M26 42 V22, stroke #1E4D2B, width 2.4
    final stemPaint = Paint()
      ..color = const Color(0xFF1E4D2B)
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    canvas.drawLine(const Offset(26, 42), const Offset(26, 22), stemPaint);

    // Leaves: M26 30 c-8 0-11-5-11-11 7 0 11 4 11 11 z; M26 26 c0-6 4-10 11-10 0 7-4 10-11 10 z
    final leafFill = Paint()
      ..color = const Color(0xFF3A8350)
      ..style = PaintingStyle.fill;
    final leafStroke = Paint()
      ..color = const Color(0xFF1E4D2B)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final leftLeaf = Path()
      ..moveTo(26, 30)
      ..cubicTo(18, 30, 15, 25, 15, 19)
      ..cubicTo(22, 19, 26, 23, 26, 30)
      ..close();
    canvas.drawPath(leftLeaf, leafFill);
    canvas.drawPath(leftLeaf, leafStroke);

    final rightLeaf = Path()
      ..moveTo(26, 26)
      ..cubicTo(26, 20, 30, 16, 37, 16)
      ..cubicTo(37, 23, 33, 26, 26, 26)
      ..close();
    canvas.drawPath(rightLeaf, leafFill);
    canvas.drawPath(rightLeaf, leafStroke);

    // Berry: cx=26, cy=15, r=3, fill #F2B134, stroke #8A5600, width 1.4
    final berryFill = Paint()
      ..color = const Color(0xFFF2B134)
      ..style = PaintingStyle.fill;
    final berryStroke = Paint()
      ..color = const Color(0xFF8A5600)
      ..strokeWidth = 1.4
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(const Offset(26, 15), 3, berryFill);
    canvas.drawCircle(const Offset(26, 15), 3, berryStroke);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Tulsi Pot squircle matching SVG (viewBox 0 0 52 52)
class _AdviceTulsiPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 52.0;
    canvas.scale(scale, scale);

    // Squircle background: rx=16, #FBE3A6
    final bgPaint = Paint()
      ..color = const Color(0xFFFBE3A6)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(0, 0, 52, 52), const Radius.circular(16)),
      bgPaint,
    );

    // Pot: M17 34 h18 l-2 6 H19 z, fill #C06A3C, stroke #8E3F20, width 1.4
    final potPath = Path()
      ..moveTo(17, 34)
      ..lineTo(35, 34)
      ..lineTo(33, 40)
      ..lineTo(19, 40)
      ..close();
    final potFill = Paint()
      ..color = const Color(0xFFC06A3C)
      ..style = PaintingStyle.fill;
    final potStroke = Paint()
      ..color = const Color(0xFF8E3F20)
      ..strokeWidth = 1.4
      ..style = PaintingStyle.stroke;
    canvas.drawPath(potPath, potFill);
    canvas.drawPath(potPath, potStroke);

    // Stem: M26 34 V22, stroke #1E4D2B, width 2.4
    final stemPaint = Paint()
      ..color = const Color(0xFF1E4D2B)
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    canvas.drawLine(const Offset(26, 34), const Offset(26, 22), stemPaint);

    // Leaves: M26 26 c-6 0-9-3-9-8 6 0 9 3 9 8 z; M26 22 c0-5 3-8 9-8 0 5-3 8-9 8 z
    final leafFill = Paint()
      ..color = const Color(0xFF3A8350)
      ..style = PaintingStyle.fill;
    final leafStroke = Paint()
      ..color = const Color(0xFF1E4D2B)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final leftLeaf = Path()
      ..moveTo(26, 26)
      ..cubicTo(20, 26, 17, 23, 17, 18)
      ..cubicTo(23, 18, 26, 21, 26, 26)
      ..close();
    canvas.drawPath(leftLeaf, leafFill);
    canvas.drawPath(leftLeaf, leafStroke);

    final rightLeaf = Path()
      ..moveTo(26, 22)
      ..cubicTo(26, 17, 29, 14, 35, 14)
      ..cubicTo(35, 19, 32, 22, 26, 22)
      ..close();
    canvas.drawPath(rightLeaf, leafFill);
    canvas.drawPath(rightLeaf, leafStroke);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
