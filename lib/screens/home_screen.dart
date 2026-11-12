import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../l10n/app_strings.dart';
import '../services/agro_intel_service.dart';
import '../services/gemini_service.dart';
import '../services/mandi_service.dart';
import '../services/storage_service.dart';
import '../services/weather_service.dart';
import '../theme/app_theme.dart';
import 'diary/farm_diary_screen.dart';
import 'planner/farm_planner_screen.dart';
import 'scan/scan_ask_screen.dart';
import 'chat/farmer_ai_chat_screen.dart';
import 'voice/voice_assistant_modal.dart';
import 'ledger/kisan_ledger_screen.dart';
import 'market/mandi_arbitrage_screen.dart';
import 'chopal/kisan_chopal_screen.dart';
import 'claim/crop_loss_claim_screen.dart';
import 'tools/fertilizer_calculator_screen.dart';
import 'tools/kisan_yojana_screen.dart';
import 'equipment/equipment_rental_screen.dart';
import 'land/land_marketplace_screen.dart';
import 'planner/boundary_canvas_screen.dart';
import '../widgets/safe_local_image.dart';
import '../widgets/turso_database_modal.dart';
import '../services/turso/turso_service.dart';

class HomeScreen extends StatefulWidget {
  final Function(int)? onNavigateTab;
  const HomeScreen({Key? key, this.onNavigateTab}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final WeatherService _weatherService = WeatherService();
  final StorageService _storage = StorageService();
  final MandiService _mandiService = MandiService();
  WeatherForecast? _weather = WeatherForecast.fallback();
  bool _isLoadingWeather = false;
  FarmIntelSnapshot? _intelSnapshot;
  GeminiSmartBriefing? _smartBriefing;
  bool _isLoadingIntel = false;

  @override
  void initState() {
    super.initState();
    _fetchWeather();
    _loadSmartIntel();
    _storage.addListener(_onStorageChanged);
    TursoService().addListener(_onStorageChanged);
  }

  @override
  void dispose() {
    _storage.removeListener(_onStorageChanged);
    TursoService().removeListener(_onStorageChanged);
    super.dispose();
  }

  void _onStorageChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _fetchWeather() async {
    final w = await _weatherService.getWeather();
    if (mounted) {
      setState(() {
        _weather = w;
        _isLoadingWeather = false;
      });
    }
  }

  Future<void> _loadSmartIntel() async {
    if (_isLoadingIntel) return;
    if (mounted) setState(() => _isLoadingIntel = true);
    try {
      await _weatherService.syncLocationFromCloud();
      final snap = await AgroIntelService().buildFarmIntelSnapshot();
      final topCrop = snap.activeCrops.isNotEmpty ? snap.activeCrops.first : 'Mustard';
      final bestRate = _mandiService.getBenchmarkPrice(topCrop);
      final briefing = await GeminiService().generateSmartBriefing(
        promptContext: snap.promptContext,
        soilMoistureRoot: snap.weather.soilMoistureRoot,
        humidity: snap.weather.humidity,
        rainChance: snap.weather.rainChance,
        netProfit: snap.netProfit,
        topCrop: topCrop,
        bestRate: bestRate,
        soilPh: snap.soil.ph,
      );
      if (mounted) {
        setState(() {
          _weather = snap.weather;
          _intelSnapshot = snap;
          _smartBriefing = briefing;
          _isLoadingIntel = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoadingIntel = false);
    }
  }

  void _showLocationPinDialog() {
    final ctrl = TextEditingController();
    final isHindi = AppLanguage().isHindi;
    bool resolving = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlgState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            isHindi ? '📍 गांव / पिन कोड बदलें' : '📍 Set Village or PIN Code',
            style: const TextStyle(fontFamily: 'Mukta', fontSize: 18, fontWeight: FontWeight.w700),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isHindi
                    ? '6-अंकों का पिन कोड (जैसे 822101) या शहर/जिले का नाम लिखें। मौसम और सैटेलाइट मिट्टी जांच अपने-आप अपडेट हो जाएगी।'
                    : 'Enter any 6-digit Indian PIN code (e.g. 822101) or village/district name to load hyper-local weather & soil pH.',
                style: const TextStyle(fontFamily: 'Mukta', fontSize: 13, color: AppColors.textMuted),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: ctrl,
                decoration: InputDecoration(
                  hintText: isHindi ? 'पिन कोड या शहर (उदा. 822101, Varanasi)' : 'PIN code or District (e.g. 822101)',
                  filled: true,
                  fillColor: AppColors.creamBg,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(isHindi ? 'रद्द करें' : 'Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryGreen),
              onPressed: resolving
                  ? null
                  : () async {
                      final q = ctrl.text.trim();
                      if (q.isEmpty) return;
                      setDlgState(() => resolving = true);
                      final found = await _weatherService.resolveLocationByPinOrName(q);
                      if (ctx.mounted) Navigator.pop(ctx);
                      if (found != null) {
                        await _loadSmartIntel();
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(isHindi ? '✓ स्थान अपडेट: $found' : '✓ Location updated: $found'),
                              backgroundColor: AppColors.primaryGreen,
                            ),
                          );
                        }
                      } else if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(isHindi ? 'स्थान नहीं मिला, पुनः प्रयास करें' : 'Location not found, try a district or PIN code'),
                            backgroundColor: const Color(0xFFD97706),
                          ),
                        );
                      }
                    },
              child: resolving
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : Text(isHindi ? 'अपडेट करें' : 'Update', style: const TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  String _getTimeGreeting(bool isHindi) {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return isHindi ? 'शुभ प्रभात' : 'Good morning';
    } else if (hour < 17) {
      return isHindi ? 'शुभ दोपहर' : 'Good afternoon';
    } else {
      return isHindi ? 'शुभ संध्या' : 'Good evening';
    }
  }

  void _showWeatherDetailsModal() {
    if (_weather == null) return;
    final w = _weather!;
    final lang = AppLanguage();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 22.0, vertical: 20.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              Center(
                child: Container(
                  width: 42,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    lang.isHindi ? 'कृषि मौसम पूर्वानुमान' : 'Agricultural Weather Forecast',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1B2A21),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE2EFDF),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      w.isLive ? 'LIVE' : 'SAMPLE',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1E4D2B),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Source: ${w.source}',
                      style: const TextStyle(fontSize: 12, color: Color(0xFF55655A)),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      Navigator.pop(ctx);
                      _showLocationPinDialog();
                    },
                    icon: const Icon(Icons.edit_location_alt_rounded, size: 16, color: AppColors.primaryGreen),
                    label: Text(
                      lang.isHindi ? 'पिन/स्थान बदलें' : 'Change PIN/Area',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primaryGreen),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Divider(),
              const SizedBox(height: 12),

              // Uniform 3x2 Telemetry Bento Grid (Weather + Satellite Soil)
              Row(
                children: [
                  Expanded(child: _buildBentoMetricBox(lang.isHindi ? 'नमी' : 'Humidity', '${w.humidity}%', Icons.water_drop_rounded, const Color(0xFFE0F2FE), const Color(0xFF0369A1))),
                  const SizedBox(width: 8),
                  Expanded(child: _buildBentoMetricBox(lang.isHindi ? 'बारिश' : 'Rain', '${w.rainChance}%', Icons.umbrella_rounded, const Color(0xFFE0F2FE), const Color(0xFF0369A1))),
                  const SizedBox(width: 8),
                  Expanded(child: _buildBentoMetricBox(lang.isHindi ? 'हवा' : 'Wind', '${w.windSpeed.round()} km/h', Icons.air_rounded, const Color(0xFFF6F2E9), AppColors.textDark)),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(child: _buildBentoMetricBox(lang.isHindi ? 'जड़ नमी' : 'Soil Moist', '${w.soilMoistureRoot}%', Icons.grass_rounded, AppColors.mintTint, AppColors.primaryGreen)),
                  const SizedBox(width: 8),
                  Expanded(child: _buildBentoMetricBox(lang.isHindi ? 'मिट्टी ताप' : 'Soil Temp', '${w.soilTemperature}°C', Icons.thermostat_rounded, const Color(0xFFFEF3C7), const Color(0xFFB45309))),
                  const SizedBox(width: 8),
                  Expanded(child: _buildBentoMetricBox(lang.isHindi ? 'वाष्पन' : 'ET₀ Loss', '${w.evapotranspiration} mm', Icons.wb_sunny_outlined, const Color(0xFFFEF3C7), const Color(0xFFB45309))),
                ],
              ),

              const SizedBox(height: 18),

              // Advisory Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: const Color(0xFFE2EFDF),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFDDEFD9)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.eco_rounded, size: 17, color: Color(0xFF1E4D2B)),
                        const SizedBox(width: 6),
                        Text(
                          lang.isHindi ? 'खेत कार्य सलाह:' : 'Farm Activity Guidance:',
                          style: const TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF1E4D2B),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _smartBriefing?.getIrrigationAdvice(lang.isHindi) ?? w.agriculturalAdvice,
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: Color(0xFF1B2A21),
                        height: 1.4,
                      ),
                    ),
                    if (_intelSnapshot != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        '${lang.isHindi ? "मिट्टी" : "Soil"}: ${_intelSnapshot!.soil.getTexture(lang.isHindi)} · pH ${_intelSnapshot!.soil.ph}',
                        style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF3A6B4A),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 20),
              Text(
                lang.isHindi ? '3-दिवसीय खेत पूर्वानुमान' : '3-Day Field Outlook',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1B2A21),
                ),
              ),
              const SizedBox(height: 10),

              ...w.dailyForecasts.map((d) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF6F2E9),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFE6E0D2)),
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 84,
                        child: Text(
                          d.day,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF1B2A21),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${d.condition} (${d.temp}) · ${lang.isHindi ? 'बारिश' : 'Rain'}: ${d.rainProb}',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                color: Color(0xFF1B2A21),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              d.advice,
                              style: const TextStyle(fontSize: 11.5, color: Color(0xFF55655A)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 10),
            ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSpecialToolPill({
    required String title,
    required String sub,
    required IconData icon,
    required Color color,
    required Color bgColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minWidth: 120),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Color.lerp(Colors.white, bgColor, 0.35),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Color.lerp(const Color(0xFFE6E0D2), bgColor, 0.45) ?? const Color(0xFFE6E0D2)),
          boxShadow: [
            BoxShadow(
              color: Color.lerp(const Color(0xFFE9E2D1), bgColor, 0.35) ?? const Color(0xFFE9E2D1),
              offset: const Offset(0, 2),
              blurRadius: 0,
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(child: Icon(icon, color: color, size: 18)),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Mukta',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1B2A21),
                  ),
                ),
                Text(
                  sub,
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lang = AppLanguage();
    final profile = StorageService().getProfile();
    final isHindi = lang.isHindi;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. TOP HEADER: Brand + Kisan AI Talk + Language + Mic
          Row(
            children: [
              // Logo + Brand Name
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E4D2B),
                        borderRadius: BorderRadius.circular(13),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0xFF123320),
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CustomPaint(
                          painter: _LogoLeafPainter(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 9),
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            lang.t('app_name'),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 21,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1B2A21),
                              height: 1.1,
                            ),
                          ),
                          Text(
                            lang.t('app_tagline'),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w400,
                              color: Color(0xFF55655A),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 6),

              // Kisan AI Talk Button (Primary Top Action)
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const FarmerAiChatScreen()),
                  );
                },
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  height: 38,
                  padding: const EdgeInsets.symmetric(horizontal: 11),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E4D2B),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0xFF123320),
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.record_voice_over_rounded,
                        size: 16,
                        color: Color(0xFFF2B134),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        isHindi ? 'किसान AI' : 'Kisan AI',
                        style: const TextStyle(
                          fontFamily: 'Mukta',
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 6),

              // Language Button
              InkWell(
                onTap: () {
                  final nextLang = isHindi ? 'English' : 'हिन्दी';
                  lang.setLanguage(nextLang);
                },
                borderRadius: BorderRadius.circular(19),
                child: Container(
                  height: 38,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(19),
                    border: Border.all(color: const Color(0xFFDDD6C4), width: 1),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.language_rounded,
                        size: 16,
                        color: Color(0xFF1B2A21),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        isHindi ? 'हिन्दी' : 'EN',
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF1B2A21),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 6),

              // Voice Mic Button
              InkWell(
                onTap: () => VoiceAssistantModal.show(context),
                borderRadius: BorderRadius.circular(19),
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFDDD6C4), width: 1),
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.mic_none_rounded,
                    color: Color(0xFF1E4D2B),
                    size: 19,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // 2. HERO FARM WEATHER & FARMER CARD (Real Farmer & Landscape + Floating Weather Card)
          Container(
            height: 215,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFF1E4D2B),
              borderRadius: BorderRadius.circular(28),
              boxShadow: const [
                BoxShadow(
                  color: Color(0xFFE9E2D1),
                  offset: Offset(0, 4),
                  blurRadius: 0,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Real Farmer & Field Background Photo
                  SafeLocalImage(
                    imagePath: 'assets/images/farmer_hero.jpg',
                    fit: BoxFit.cover,
                    alignment: const Alignment(0.4, -0.2),
                    fallback: CustomPaint(
                      painter: _HomeHeroLandscapePainter(),
                    ),
                  ),

                  // Deep Farm Green Gradient Overlay to keep text legible with authentic atmosphere
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          const Color(0xFF1E4D2B).withOpacity(0.85),
                          const Color(0xFF1E4D2B).withOpacity(0.65),
                          const Color(0xFF1E4D2B).withOpacity(0.92),
                        ],
                        stops: const [0.0, 0.45, 1.0],
                      ),
                    ),
                  ),

                  // Top Greeting Text + Turso Cloud Status Pill
                  Positioned(
                    left: 18,
                    top: 16,
                    right: 18,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _getTimeGreeting(isHindi),
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.white.withOpacity(0.92),
                                  letterSpacing: 0.2,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                profile.name.isNotEmpty
                                    ? (isHindi ? 'नमस्ते, ${profile.name} 👋' : 'Namaste, ${profile.name} 👋')
                                    : (isHindi ? 'नमस्ते, किसान साथी 👋' : 'Namaste, Kisan Saathi 👋'),
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                  height: 1.15,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Turso Cloud Pill
                        GestureDetector(
                          onTap: () => TursoDatabaseModal.show(context),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.35),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: TursoService().isConnected
                                    ? const Color(0xFF68D391).withOpacity(0.8)
                                    : Colors.white.withOpacity(0.35),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 7,
                                  height: 7,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: TursoService().isConnected
                                        ? const Color(0xFF48BB78)
                                        : const Color(0xFFECC94B),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  TursoService().isConnected ? 'Turso 24/7' : 'Turso DB',
                                  style: const TextStyle(
                                    fontFamily: 'Mukta',
                                    fontSize: 11.5,
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

                  // Floating Weather Card (inside hero at bottom)
                  Positioned(
                    left: 12,
                    right: 12,
                    bottom: 12,
                    child: InkWell(
                      onTap: _showWeatherDetailsModal,
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: _isLoadingWeather
                            ? const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(6.0),
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: Color(0xFF1E4D2B),
                                  ),
                                ),
                              )
                            : Row(
                                children: [
                                  // Sun Icon Box
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFCEFD0),
                                      borderRadius: BorderRadius.circular(13),
                                    ),
                                    child: const Icon(
                                      Icons.wb_sunny_rounded,
                                      color: Color(0xFFF2B134),
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(width: 12),

                                  // Temp & Condition
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          '${_weather!.temperature.round()}°C',
                                          style: const TextStyle(
                                            fontSize: 22,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFF1B2A21),
                                            height: 1.1,
                                          ),
                                        ),
                                        Text(
                                          _weather!.condition,
                                          style: const TextStyle(
                                            fontSize: 12.5,
                                            fontWeight: FontWeight.w400,
                                            color: Color(0xFF55655A),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Rain & Location
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(
                                            Icons.water_drop_outlined,
                                            size: 15,
                                            color: Color(0xFF18566F),
                                          ),
                                          const SizedBox(width: 5),
                                          Text(
                                            'Rain ${_weather!.rainChance}%',
                                            style: const TextStyle(
                                              fontSize: 12.5,
                                              fontWeight: FontWeight.w400,
                                              color: Color(0xFF18566F),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 2),
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(
                                            Icons.location_on_outlined,
                                            size: 15,
                                            color: Color(0xFF2B4A36),
                                          ),
                                          const SizedBox(width: 5),
                                          Text(
                                            _weatherService.activeLocationName.isNotEmpty
                                                ? _weatherService.activeLocationName.split(',').first
                                                : (profile.district.isNotEmpty
                                                    ? profile.district
                                                    : (isHindi ? 'स्थानीय प्रक्षेत्र' : 'Local Farm')),
                                            style: const TextStyle(
                                              fontSize: 12.5,
                                              fontWeight: FontWeight.w400,
                                              color: Color(0xFF2B4A36),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // 3. CLASSIC HARVEST GOLD SCAN & ASK BANNER
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ScanAskScreen()),
              );
            },
            borderRadius: BorderRadius.circular(24),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: const Color(0xFFF2B134),
                borderRadius: BorderRadius.circular(24),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0xFFC98F1C),
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(17),
                    ),
                    alignment: Alignment.center,
                    child: SizedBox(
                      width: 36,
                      height: 36,
                      child: CustomPaint(painter: _ScanViewfinderLeafPainter()),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          lang.t('scan_ask_title'),
                          style: const TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF2A1B00),
                            height: 1.15,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          lang.t('scan_ask_desc'),
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF3E2900),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    height: 38,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E4D2B),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          lang.t('scan_btn'),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.arrow_forward_rounded,
                          color: Colors.white,
                          size: 16,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // 4. SECTION TITLE: Essential Farm Tools
          Text(
            isHindi ? 'ज़रूरी किसान उपकरण' : 'Essential Farm Tools',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1B2A21),
            ),
          ),
          const SizedBox(height: 12),

          // 2x2 ACTION GRID (Unique high-value farmer tools)
          Row(
            children: [
              // Tile 1: Rent Farm Equipment (Sage Green)
              Expanded(
                child: _buildActionTile(
                  cardBg: const Color(0xFFEEF7EC),
                  borderColor: const Color(0xFFC8E2C2),
                  shadowColor: const Color(0xFFD2E8CD),
                  bColor: const Color(0xFFD9EED4),
                  iconBg: const Color(0xFFC5E4BE),
                  icon: Icons.agriculture_rounded,
                  iconColor: const Color(0xFF1E4D2B),
                  chevronColor: const Color(0xFF1E4D2B),
                  title: isHindi ? 'यंत्र किराया' : 'Rent Equipment',
                  subtitle: isHindi ? 'ट्रैक्टर, हार्वेस्टर व ड्रोन' : 'Tractors & Tools',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const EquipmentRentalScreen()),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),

              // Tile 2: Design My Land (Irrigation Sky Blue)
              Expanded(
                child: _buildActionTile(
                  cardBg: const Color(0xFFECF5FA),
                  borderColor: const Color(0xFFC4DFEE),
                  shadowColor: const Color(0xFFCFE6F3),
                  bColor: const Color(0xFFD6EAF5),
                  iconBg: const Color(0xFFBFE0F1),
                  iconPainter: _PlannerParcelsPainter(),
                  chevronColor: const Color(0xFF18566F),
                  title: isHindi ? 'खेत डिजाइन' : 'Design My Land',
                  subtitle: isHindi ? 'दूरी व बुवाई नक्शा' : 'Spacing & Layout',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const FarmPlannerScreen()),
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              // Tile 3: Kisan Ledger / Bahi-Khata (Harvest Honey Gold)
              Expanded(
                child: _buildActionTile(
                  cardBg: const Color(0xFFFEF7E4),
                  borderColor: const Color(0xFFF0D9A3),
                  shadowColor: const Color(0xFFF3E2B7),
                  bColor: const Color(0xFFFBECC6),
                  iconBg: const Color(0xFFF9DF9E),
                  icon: Icons.account_balance_wallet_outlined,
                  iconColor: const Color(0xFF8A5600),
                  chevronColor: const Color(0xFF8A5600),
                  title: isHindi ? 'किसान बही-खाता' : 'Kisan Ledger',
                  subtitle: isHindi ? 'आय-व्यय व मुनाफा' : 'Income & Cost P&L',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const KisanLedgerScreen()),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),

              // Tile 4: Sarkari Yojana (Warm Terracotta Peach)
              Expanded(
                child: _buildActionTile(
                  cardBg: const Color(0xFFFCF1EC),
                  borderColor: const Color(0xFFEDD0C2),
                  shadowColor: const Color(0xFFF1D9CE),
                  bColor: const Color(0xFFF6DFD4),
                  iconBg: const Color(0xFFF3CEC0),
                  icon: Icons.account_balance_outlined,
                  iconColor: const Color(0xFF9A3E1E),
                  chevronColor: const Color(0xFF9A3E1E),
                  title: isHindi ? 'सरकारी योजनाएं' : 'Sarkari Yojana',
                  subtitle: isHindi ? 'सब्सिडी व पीएम किसान' : 'Subsidies & Grants',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const KisanYojanaScreen()),
                    );
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // 5. BUY & SELL AGRICULTURAL LAND (Compact 1-Tap Marketplace Card)
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LandMarketplaceScreen()),
              );
            },
            borderRadius: BorderRadius.circular(22),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
              decoration: AppStyles.cardBox,
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: AppColors.mintTint,
                      borderRadius: BorderRadius.circular(13),
                    ),
                    alignment: Alignment.center,
                    child: const Icon(Icons.terrain_rounded, color: AppColors.primaryGreen, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isHindi ? 'कृषि जमीन क्रय-विक्रय' : 'Farmland Marketplace',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontFamily: 'Mukta',
                            fontSize: 15.5,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textDark,
                          ),
                        ),
                        Text(
                          isHindi ? '0% दलाली · सीधे किसानों से खरीदें/बेचें' : '0% Brokerage · Verified village plots',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontFamily: 'Mukta',
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primaryGreen,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      isHindi ? 'देखें' : 'Open',
                      style: const TextStyle(
                        fontFamily: 'Mukta',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // 6. VILLAGE SERVICES & HUBS
          Text(
            isHindi ? 'गाँव की अन्य सेवाएँ' : 'Village Services',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1B2A21),
            ),
          ),
          const SizedBox(height: 10),

          // 5 Specialized Farmer Service Pills
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: [
                _buildSpecialToolPill(
                  title: isHindi ? 'मंडी भाड़ा' : 'Mandi Calc',
                  sub: isHindi ? 'मुनाफा कैलकुलेटर' : 'Diesel & Tax',
                  icon: Icons.calculate_outlined,
                  color: const Color(0xFF8A5600),
                  bgColor: const Color(0xFFFCEFD0),
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MandiArbitrageScreen())),
                ),
                const SizedBox(width: 8),
                _buildSpecialToolPill(
                  title: isHindi ? 'किसान चौपाल' : 'Chopal Hub',
                  sub: isHindi ? 'ट्रैक्टर यंत्र किराया' : 'Tool Rentals',
                  icon: Icons.groups_outlined,
                  color: const Color(0xFF18566F),
                  bgColor: const Color(0xFFDDEBF3),
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const KisanChopalScreen())),
                ),
                const SizedBox(width: 8),
                _buildSpecialToolPill(
                  title: isHindi ? 'बीमा दावा' : 'PMFBY Claim',
                  sub: isHindi ? '72-घंटे में रिपोर्ट' : 'Crop Loss Claim',
                  icon: Icons.security_outlined,
                  color: const Color(0xFFB03A2E),
                  bgColor: const Color(0xFFFDE8E8),
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CropLossClaimScreen())),
                ),
                const SizedBox(width: 8),
                _buildSpecialToolPill(
                  title: isHindi ? 'उपग्रह सीमांकन' : 'Satellite Canvas',
                  sub: isHindi ? 'खसरा GPS नक्शा' : 'GPS Boundary Map',
                  icon: Icons.architecture_rounded,
                  color: const Color(0xFF1E4D2B),
                  bgColor: const Color(0xFFE2EFDF),
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BoundaryCanvasScreen())),
                ),
                const SizedBox(width: 8),
                _buildSpecialToolPill(
                  title: isHindi ? 'खेत डायरी' : 'Farm Diary',
                  sub: isHindi ? 'दैनिक कार्य विवरण' : 'Daily Field Logs',
                  icon: Icons.menu_book_rounded,
                  color: const Color(0xFF55655A),
                  bgColor: const Color(0xFFF6F2E9),
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FarmDiaryScreen())),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Action Tile matching .t, .b, .g classes from HTML with soft earthy tints
  Widget _buildActionTile({
    Color cardBg = Colors.white,
    Color borderColor = const Color(0xFFE6E0D2),
    Color shadowColor = const Color(0xFFE9E2D1),
    required Color bColor,
    required Color iconBg,
    CustomPainter? iconPainter,
    IconData? icon,
    Color? iconColor,
    Color? chevronColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final arrowFg = chevronColor ?? iconColor ?? const Color(0xFF1E4D2B);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        decoration: BoxDecoration(
          color: cardBg,
          border: Border.all(color: borderColor, width: 1.1),
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: shadowColor,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: Stack(
            children: [
              // Top-right background arc .b
              Positioned(
                right: -16,
                top: -16,
                width: 76,
                height: 76,
                child: Container(
                  decoration: BoxDecoration(
                    color: bColor,
                    shape: BoxShape.circle,
                  ),
                ),
              ),

              // Chevron button .g
              Positioned(
                right: 12,
                top: 12,
                width: 26,
                height: 26,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.92),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.chevron_right_rounded,
                    size: 16,
                    color: arrowFg,
                  ),
                ),
              ),

              // Content with full inset padding
              Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: iconBg,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      alignment: Alignment.center,
                      child: iconPainter != null
                          ? SizedBox(
                              width: 46,
                              height: 46,
                              child: CustomPaint(
                                painter: iconPainter,
                              ),
                            )
                          : Icon(
                              icon ?? Icons.eco_rounded,
                              color: iconColor ?? const Color(0xFF1E4D2B),
                              size: 24,
                            ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      title,
                      style: const TextStyle(
                        fontFamily: 'Mukta',
                        fontFamilyFallback: AppStyles.fontFallbacks,
                        fontSize: 15.5,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1B2A21),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontFamily: 'Mukta',
                        fontFamilyFallback: AppStyles.fontFallbacks,
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF55655A),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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

  Widget _buildBentoMetricBox(String label, String val, IconData icon, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Icon(icon, size: 17, color: fg),
          const SizedBox(height: 4),
          Text(
            val,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontFamily: 'Mukta', fontSize: 14.5, fontWeight: FontWeight.w700, color: fg, height: 1.1),
          ),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontFamily: 'Mukta', fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}

// 1. Logo Golden Leaf Painter
class _LogoLeafPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final leafPaint = Paint()
      ..color = const Color(0xFFF2B134)
      ..style = PaintingStyle.fill;
    final strokePaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 1.9
      ..style = PaintingStyle.stroke;

    final path = Path();
    path.moveTo(size.width * 0.20, size.height * 0.80);
    path.cubicTo(size.width * 0.20, size.height * 0.45, size.width * 0.42, size.height * 0.22, size.width * 0.80, size.height * 0.20);
    path.cubicTo(size.width * 0.80, size.height * 0.58, size.width * 0.58, size.height * 0.80, size.width * 0.25, size.height * 0.80);
    path.close();

    canvas.drawPath(path, leafPaint);
    canvas.drawPath(path, strokePaint);

    final veinPath = Path();
    veinPath.moveTo(size.width * 0.20, size.height * 0.80);
    veinPath.quadraticBezierTo(size.width * 0.35, size.height * 0.55, size.width * 0.65, size.height * 0.40);
    canvas.drawPath(veinPath, strokePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// 2. Home Hero Landscape Painter (Exact SVG curves from HTML)
class _HomeHeroLandscapePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Sun Halo: circle cx="296" cy="50" r="38" fill="#F2B134" opacity=".22"
    final haloPaint = Paint()
      ..color = const Color(0xFFF2B134).withOpacity(0.22)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(size.width * 0.82, size.height * 0.24), 38, haloPaint);

    // Sun: circle cx="296" cy="50" r="24" fill="#F2B134"
    final sunPaint = Paint()
      ..color = const Color(0xFFF2B134)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(size.width * 0.82, size.height * 0.24), 24, sunPaint);

    // Cloud: d="M214 66h40a10 10 0 0 0 0-20 14 14 0 0 0-26-3 11 11 0 0 0-14 23z" fill="#fff" opacity=".92"
    final cloudPaint = Paint()
      ..color = Colors.white.withOpacity(0.92)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.58, size.height * 0.25, 48, 20),
        const Radius.circular(10),
      ),
      cloudPaint,
    );
    canvas.drawCircle(Offset(size.width * 0.64, size.height * 0.25), 14, cloudPaint);
    canvas.drawCircle(Offset(size.width * 0.72, size.height * 0.27), 10, cloudPaint);

    // Hill 1: d="M0 128Q90 86 190 122T358 106V206H0z" fill="#2B6A3E"
    final hill1Paint = Paint()
      ..color = const Color(0xFF2B6A3E)
      ..style = PaintingStyle.fill;
    final path1 = Path();
    path1.moveTo(0, size.height * 0.62);
    path1.quadraticBezierTo(size.width * 0.25, size.height * 0.42, size.width * 0.53, size.height * 0.59);
    path1.quadraticBezierTo(size.width * 0.80, size.height * 0.70, size.width, size.height * 0.51);
    path1.lineTo(size.width, size.height);
    path1.lineTo(0, size.height);
    path1.close();
    canvas.drawPath(path1, hill1Paint);

    // Hill 2: d="M0 162Q120 118 250 154T358 142V206H0z" fill="#3A8350"
    final hill2Paint = Paint()
      ..color = const Color(0xFF3A8350)
      ..style = PaintingStyle.fill;
    final path2 = Path();
    path2.moveTo(0, size.height * 0.78);
    path2.quadraticBezierTo(size.width * 0.33, size.height * 0.57, size.width * 0.70, size.height * 0.75);
    path2.quadraticBezierTo(size.width * 0.86, size.height * 0.82, size.width, size.height * 0.69);
    path2.lineTo(size.width, size.height);
    path2.lineTo(0, size.height);
    path2.close();
    canvas.drawPath(path2, hill2Paint);

    // Hatched grass lines: stroke="#5DAA6E" stroke-width="2"
    final grassPaint = Paint()
      ..color = const Color(0xFF5DAA6E)
      ..strokeWidth = 2.0;
    for (double x = 10; x < size.width; x += 38) {
      canvas.drawLine(
        Offset(x, size.height),
        Offset(x + 50, size.height - 40),
        grassPaint,
      );
    }

    // Fireflies / yellow dots: fill="#F2B134"
    final dotPaint = Paint()
      ..color = const Color(0xFFF2B134)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(size.width * 0.92, size.height * 0.64), 3, dotPaint);
    canvas.drawCircle(Offset(size.width * 0.95, size.height * 0.60), 3, dotPaint);
    canvas.drawCircle(Offset(size.width * 0.89, size.height * 0.59), 3, dotPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// 3. Scan Viewfinder Leaf Painter
class _ScanViewfinderLeafPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final framePaint = Paint()
      ..color = const Color(0xFF1E4D2B)
      ..strokeWidth = 2.6
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Viewfinder brackets
    canvas.drawLine(const Offset(5, 13), const Offset(5, 7), framePaint);
    canvas.drawLine(const Offset(5, 7), const Offset(13, 7), framePaint);

    canvas.drawLine(const Offset(27, 7), const Offset(33, 7), framePaint);
    canvas.drawLine(const Offset(33, 7), const Offset(33, 13), framePaint);

    canvas.drawLine(const Offset(33, 27), const Offset(33, 33), framePaint);
    canvas.drawLine(const Offset(33, 33), const Offset(27, 33), framePaint);

    canvas.drawLine(const Offset(13, 33), const Offset(7, 33), framePaint);
    canvas.drawLine(const Offset(7, 33), const Offset(7, 27), framePaint);

    // Leaf: d="M12 28c0-9 5-15 16-16 0 10-5 16-14 16z" fill="#3A8350" stroke="#1E4D2B"
    final leafPaint = Paint()
      ..color = const Color(0xFF3A8350)
      ..style = PaintingStyle.fill;
    final leafStroke = Paint()
      ..color = const Color(0xFF1E4D2B)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final leafPath = Path();
    leafPath.moveTo(12, 28);
    leafPath.cubicTo(12, 19, 17, 13, 28, 12);
    leafPath.cubicTo(28, 22, 23, 28, 14, 28);
    leafPath.close();

    canvas.drawPath(leafPath, leafPaint);
    canvas.drawPath(leafPath, leafStroke);

    // Leaf vein: d="M12 28c3-5 6-8 10-11" stroke="#fff"
    final veinPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    final veinPath = Path();
    veinPath.moveTo(12, 28);
    veinPath.quadraticBezierTo(15, 23, 22, 17);
    canvas.drawPath(veinPath, veinPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// 4. My Farm Sprout Painter (5 Leaves from HTML)
class _MyFarmSproutPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final stemPaint = Paint()
      ..color = const Color(0xFF1E4D2B)
      ..strokeWidth = 2.4;
    canvas.drawLine(const Offset(24, 40), const Offset(24, 16), stemPaint);

    final leafFill = Paint()
      ..color = const Color(0xFF3A8350)
      ..style = PaintingStyle.fill;
    final leafStroke = Paint()
      ..color = const Color(0xFF1E4D2B)
      ..strokeWidth = 1.4
      ..style = PaintingStyle.stroke;

    void drawLeaf(Offset center, double angle) {
      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(angle);
      final rect = Rect.fromCenter(center: Offset.zero, width: 6, height: 10);
      canvas.drawOval(rect, leafFill);
      canvas.drawOval(rect, leafStroke);
      canvas.restore();
    }

    drawLeaf(const Offset(24, 10), 0);
    drawLeaf(const Offset(17, 18), -0.6);
    drawLeaf(const Offset(31, 18), 0.6);
    drawLeaf(const Offset(17, 27), -0.6);
    drawLeaf(const Offset(31, 27), 0.6);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// 5. Today's Advice Lightbulb Painter
class _LightbulbPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final bulbFill = Paint()
      ..color = const Color(0xFFF2B134)
      ..style = PaintingStyle.fill;
    final bulbStroke = Paint()
      ..color = const Color(0xFF7A4D00)
      ..strokeWidth = 1.8
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(const Offset(24, 19), 10, bulbFill);
    canvas.drawCircle(const Offset(24, 19), 10, bulbStroke);

    final basePaint = Paint()
      ..color = const Color(0xFF7A4D00)
      ..strokeWidth = 2.2;
    canvas.drawLine(const Offset(20, 31), const Offset(28, 31), basePaint);
    canvas.drawLine(const Offset(21, 35), const Offset(27, 35), basePaint);

    final rayPaint = Paint()
      ..color = const Color(0xFF7A4D00)
      ..strokeWidth = 2.0;
    canvas.drawLine(const Offset(24, 4), const Offset(24, 6), rayPaint);
    canvas.drawLine(const Offset(9, 12), const Offset(11, 14), rayPaint);
    canvas.drawLine(const Offset(39, 12), const Offset(37, 14), rayPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// 6. Farm Planner 4-Quadrant Parcels Painter
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

// 7. Market Prices Rupee Coin Painter
class _RupeeCoinPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final coinPaint = Paint()
      ..color = const Color(0xFFF2B134)
      ..style = PaintingStyle.fill;
    final outerStroke = Paint()
      ..color = const Color(0xFF8E3F20)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;
    final innerStroke = Paint()
      ..color = const Color(0xFF8E3F20)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(const Offset(24, 24), 13, coinPaint);
    canvas.drawCircle(const Offset(24, 24), 13, outerStroke);
    canvas.drawCircle(const Offset(24, 24), 9, innerStroke);

    final textPainter = TextPainter(
      text: const TextSpan(
        text: '\u20B9',
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: Color(0xFF8E3F20),
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(24 - textPainter.width / 2, 24 - textPainter.height / 2));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// 8. Reminder Leaf Painter
class _ReminderLeafPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final leafPaint = Paint()
      ..color = const Color(0xFF7DB88A)
      ..style = PaintingStyle.fill;
    final strokePaint = Paint()
      ..color = const Color(0xFF1E4D2B)
      ..strokeWidth = 1.9
      ..style = PaintingStyle.stroke;

    final path = Path();
    path.moveTo(size.width * 0.20, size.height * 0.80);
    path.cubicTo(size.width * 0.20, size.height * 0.45, size.width * 0.42, size.height * 0.22, size.width * 0.80, size.height * 0.20);
    path.cubicTo(size.width * 0.80, size.height * 0.58, size.width * 0.58, size.height * 0.80, size.width * 0.25, size.height * 0.80);
    path.close();

    canvas.drawPath(path, leafPaint);
    canvas.drawPath(path, strokePaint);

    final veinPath = Path();
    veinPath.moveTo(size.width * 0.20, size.height * 0.80);
    veinPath.quadraticBezierTo(size.width * 0.35, size.height * 0.55, size.width * 0.65, size.height * 0.40);
    canvas.drawPath(veinPath, strokePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
