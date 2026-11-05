import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../l10n/app_strings.dart';
import '../services/storage_service.dart';
import '../services/weather_service.dart';
import '../theme/app_theme.dart';
import 'diary/farm_diary_screen.dart';
import 'planner/farm_planner_screen.dart';
import 'scan/scan_ask_screen.dart';
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
  WeatherForecast? _weather = WeatherForecast.fallback();
  bool _isLoadingWeather = false;

  @override
  void initState() {
    super.initState();
    _fetchWeather();
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
              Text(
                'Source: ${w.source}',
                style: const TextStyle(fontSize: 12, color: Color(0xFF55655A)),
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),

              // Metrics Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildMetricTile(lang.isHindi ? 'नमी' : 'Humidity', '${w.humidity}%', Icons.water_drop_rounded),
                  _buildMetricTile(lang.isHindi ? 'बारिश' : 'Rain Chance', '${w.rainChance}%', Icons.umbrella_rounded),
                  _buildMetricTile(lang.isHindi ? 'हवा' : 'Wind', '${w.windSpeed} km/h', Icons.air_rounded),
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
                      w.agriculturalAdvice,
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: Color(0xFF1B2A21),
                        height: 1.4,
                      ),
                    ),
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
        );
      },
    );
  }

  Widget _buildMetricTile(String label, String value, IconData icon) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: const BoxDecoration(
            color: Color(0xFFE2EFDF),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: const Color(0xFF1E4D2B), size: 20),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1B2A21),
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: Color(0xFF55655A)),
        ),
      ],
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
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE6E0D2)),
          boxShadow: const [
            BoxShadow(
              color: Color(0xFFE9E2D1),
              offset: Offset(0, 2),
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
          // 1. TOP HEADER: Logo + Brand Name + Language Switcher + Voice Assistant
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Logo + Brand Name
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E4D2B),
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0xFF123320),
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: SizedBox(
                      width: 26,
                      height: 26,
                      child: CustomPaint(
                        painter: _LogoLeafPainter(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        lang.t('app_name'),
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1B2A21),
                          height: 1.1,
                        ),
                      ),
                      Text(
                        lang.t('app_tagline'),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF55655A),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              // Language Button & Voice Mic Button
              Row(
                children: [
                  // Language Button
                  InkWell(
                    onTap: () {
                      final nextLang = isHindi ? 'English' : 'हिन्दी';
                      lang.setLanguage(nextLang);
                    },
                    borderRadius: BorderRadius.circular(22),
                    child: Container(
                      height: 44,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: const Color(0xFFDDD6C4), width: 1),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.language_rounded,
                            size: 18,
                            color: Color(0xFF1B2A21),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            isHindi ? 'हिन्दी' : 'EN',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: Color(0xFF1B2A21),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Mic Button
                  InkWell(
                    onTap: () => VoiceAssistantModal.show(context),
                    borderRadius: BorderRadius.circular(22),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E4D2B),
                        shape: BoxShape.circle,
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0xFF123320),
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.mic_none_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                  ),
                ],
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
                                            profile.district.isNotEmpty
                                                ? profile.district
                                                : (isHindi ? 'स्थानीय प्रक्षेत्र' : 'Local Farm'),
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

          const SizedBox(height: 14),

          // 3. SCAN & ASK BANNER (Harvest Gold, Box Shadow 0 4px 0 #C98F1C)
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
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Decorative Circle
                    Positioned(
                      right: -20,
                      top: -30,
                      width: 110,
                      height: 110,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.22),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),

                    Row(
                      children: [
                        // White Box with Viewfinder Leaf
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
                          ),
                          alignment: Alignment.center,
                          child: SizedBox(
                            width: 40,
                            height: 40,
                            child: CustomPaint(
                              painter: _ScanViewfinderLeafPainter(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),

                        // Text
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                lang.t('scan_ask_title'),
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF2A1B00),
                                ),
                              ),
                              Text(
                                lang.t('scan_ask_desc'),
                                style: const TextStyle(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w400,
                                  color: Color(0xFF2A1B00),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Scan Pill Button
                        Container(
                          height: 40,
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E4D2B),
                            borderRadius: BorderRadius.circular(22),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                lang.t('scan_btn'),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
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
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 18),

          // 4. SECTION TITLE: Essential Farm Tools (No duplicate of Bottom Nav)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isHindi ? 'ज़रूरी किसान उपकरण' : 'Essential Farm Tools',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1B2A21),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFE2EFDF),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  isHindi ? '4 उपकरण' : '4 Tools',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF1E4D2B),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // 2x2 ACTION GRID (Unique high-value farmer tools)
          Row(
            children: [
              // Tile 1: Rent Farm Equipment (कृषि यंत्र किराया)
              Expanded(
                child: _buildActionTile(
                  bColor: const Color(0xFFE2EFDF),
                  iconBg: const Color(0xFFCFE5CA),
                  icon: Icons.agriculture_rounded,
                  iconColor: const Color(0xFF1E4D2B),
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

              // Tile 2: Design My Land (खेत डिजाइन)
              Expanded(
                child: _buildActionTile(
                  bColor: const Color(0xFFDDEBF3),
                  iconBg: const Color(0xFFC9E1EE),
                  iconPainter: _PlannerParcelsPainter(),
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
              // Tile 3: Kisan Ledger / Bahi-Khata (किसान बही-खाता)
              Expanded(
                child: _buildActionTile(
                  bColor: const Color(0xFFFCEFD0),
                  iconBg: const Color(0xFFFBE3A6),
                  icon: Icons.account_balance_wallet_outlined,
                  iconColor: const Color(0xFF8A5600),
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

              // Tile 4: Sarkari Yojana (सरकारी योजनाएं)
              Expanded(
                child: _buildActionTile(
                  bColor: const Color(0xFFF6E0D6),
                  iconBg: const Color(0xFFF3D3C4),
                  icon: Icons.account_balance_outlined,
                  iconColor: const Color(0xFFC98F1C),
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

          const SizedBox(height: 14),

          // 5. BUY & SELL AGRICULTURAL LAND (Direct Farmer-to-Farmer Marketplace)
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: const Color(0xFFE6E0D2), width: 1),
              borderRadius: BorderRadius.circular(22),
              boxShadow: const [
                BoxShadow(
                  color: Color(0xFFE9E2D1),
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE2EFDF),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          alignment: Alignment.center,
                          child: const Icon(Icons.terrain_rounded, color: Color(0xFF1E4D2B), size: 20),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isHindi ? 'जमीन क्रय-विक्रय बाज़ार' : 'FARMLAND MARKET',
                              style: const TextStyle(
                                fontFamily: 'Mukta',
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1E4D2B),
                                letterSpacing: 0.5,
                              ),
                            ),
                            Text(
                              isHindi ? 'कृषि जमीन खरीदें या बेचें' : 'Sell or Buy Farmland',
                              style: const TextStyle(
                                fontFamily: 'Mukta',
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1B2A21),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF2B134).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        '0% Brokerage',
                        style: TextStyle(
                          fontFamily: 'Mukta',
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF8A5600),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  isHindi
                      ? 'अपने गांव व जिले में उपजाऊ बोरवेल जमीन देखें या अपनी जमीन सीधे किसानों को बेचें।'
                      : 'Verified irrigated plots near your village. Direct deal with farmers, zero middleman commission.',
                  style: const TextStyle(
                    fontFamily: 'Mukta',
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF55655A),
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const LandMarketplaceScreen()),
                          );
                        },
                        child: Container(
                          height: 38,
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E4D2B),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            isHindi ? 'जमीन देखें →' : 'Browse Farmland →',
                            style: const TextStyle(
                              fontFamily: 'Mukta',
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const LandMarketplaceScreen()),
                          );
                        },
                        child: Container(
                          height: 38,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF6F2E9),
                            border: Border.all(color: const Color(0xFFDDD6C4)),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            isHindi ? '+ अपनी जमीन बेचें' : '+ Post Land to Sell',
                            style: const TextStyle(
                              fontFamily: 'Mukta',
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1B2A21),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // 6. REAL ACTIVE CROPS IN FIELD (REAL PHOTOGRAPHY & FARMING FEEL)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isHindi ? 'खेत की फसलें (Active Crops)' : 'Your Active Crops',
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1B2A21),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFE2EFDF),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  isHindi ? '3 भूखंड सक्रिय' : '3 Plots Active',
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF1E4D2B),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Horizontal Carousel of Real Crops
          () {
            final farm = _storage.getPrimaryFarm();
            final crops = farm.crops;
            if (crops.isEmpty) {
              return InkWell(
                onTap: () => widget.onNavigateTab?.call(1),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFE6E0D2)),
                    boxShadow: const [BoxShadow(color: Color(0xFFE9E2D1), offset: Offset(0, 3))],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE2EFDF),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        alignment: Alignment.center,
                        child: const Icon(Icons.spa_rounded, color: Color(0xFF1E4D2B), size: 24),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isHindi ? 'अपनी फसलें जोड़ें' : 'Add Your Farm Crops',
                              style: const TextStyle(
                                fontFamily: 'Mukta',
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1B2A21),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              isHindi
                                  ? 'खेत में उगाई जा रही फसलों का विवरण दर्ज करें और मौसम सलाह पाएं।'
                                  : 'Track your crops, sowing dates, and tailored advisory.',
                              style: const TextStyle(
                                fontFamily: 'Mukta',
                                fontSize: 12.5,
                                fontWeight: FontWeight.w400,
                                color: Color(0xFF55655A),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Color(0xFF1E4D2B)),
                    ],
                  ),
                ),
              );
            }

            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: crops.map((crop) {
                  final cNameLower = crop.name.toLowerCase();
                  String img = 'assets/images/farmer_field.jpg';
                  if (cNameLower.contains('mustard') || cNameLower.contains('sarson')) {
                    img = 'assets/images/mustard_crop.jpg';
                  } else if (cNameLower.contains('wheat') || cNameLower.contains('gehu')) {
                    img = 'assets/images/wheat_crop.jpg';
                  }
                  final plotText = farm.totalArea > 0
                      ? '${farm.totalArea} Acres · ${farm.village.isNotEmpty ? farm.village : (isHindi ? "खेत" : "Farmland")}'
                      : (farm.village.isNotEmpty ? farm.village : (isHindi ? "सक्रिय खेत" : "Active Plot"));
                  final varietyText = (crop.variety != null && crop.variety!.trim().isNotEmpty)
                      ? '${isHindi ? "किस्म:" : "Variety:"} ${crop.variety!}'
                      : ((crop.notes != null && crop.notes!.trim().isNotEmpty)
                          ? crop.notes!
                          : (isHindi ? 'सक्रिय खेती' : 'Active Growth'));
                  final stageText = (crop.growthStage != null && crop.growthStage!.trim().isNotEmpty)
                      ? crop.growthStage!
                      : (isHindi ? 'अनुकूल स्थिति' : 'Healthy');

                  return _buildCropCard(
                    imagePath: img,
                    cropName: crop.name,
                    variety: varietyText,
                    stage: stageText,
                    plotInfo: plotText,
                    badgeBg: const Color(0xFFE2EFDF),
                    badgeTextColor: const Color(0xFF1E4D2B),
                  );
                }).toList(),
              ),
            );
          }(),

          const SizedBox(height: 20),

          // 7. FARMER SMART SERVICES & HUBS
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isHindi ? 'विशेष किसान सेवाएँ (Smart Tools)' : 'Farmer Smart Services',
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1B2A21),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFF2B134).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  '5 Services',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF8A5600),
                  ),
                ),
              ),
            ],
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

  // Real Crop Card with photo, stage tag, and plot info
  Widget _buildCropCard({
    required String imagePath,
    required String cropName,
    required String variety,
    required String stage,
    required String plotInfo,
    required Color badgeBg,
    required Color badgeTextColor,
  }) {
    return Container(
      width: 220,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE6E0D2)),
        boxShadow: const [
          BoxShadow(
            color: Color(0xFFE9E2D1),
            offset: Offset(0, 3),
            blurRadius: 0,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Real Image
            Stack(
              children: [
                SizedBox(
                  height: 115,
                  width: 220,
                  child: SafeLocalImage(
                    imagePath: imagePath,
                    width: 220,
                    height: 115,
                    fit: BoxFit.cover,
                    fallback: Container(
                      height: 115,
                      width: 220,
                      color: badgeBg,
                      child: Center(
                        child: Icon(Icons.agriculture_rounded, color: badgeTextColor, size: 36),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: badgeBg,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      stage,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: badgeTextColor,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    cropName,
                    style: const TextStyle(
                      fontSize: 15.5,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1B2A21),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    variety,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF55655A),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, size: 14, color: Color(0xFF1E4D2B)),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          plotInfo,
                          style: const TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF1E4D2B),
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
    );
  }


  // Action Tile matching .t, .b, .g classes from HTML
  Widget _buildActionTile({
    required Color bColor,
    required Color iconBg,
    CustomPainter? iconPainter,
    IconData? icon,
    Color? iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFFE6E0D2), width: 1),
          borderRadius: BorderRadius.circular(22),
          boxShadow: const [
            BoxShadow(
              color: Color(0xFFE9E2D1),
              offset: Offset(0, 3),
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
                  decoration: const BoxDecoration(
                    color: Color(0xFFF3EFE4),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.chevron_right_rounded,
                    size: 16,
                    color: Color(0xFF1E4D2B),
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
