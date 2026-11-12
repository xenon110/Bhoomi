import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'mandi_service.dart';
import 'network/http_helper.dart';
import 'storage_service.dart';
import 'weather_service.dart';

/// Estimated topsoil composition from ISRIC SoilGrids v2 satellite-interpolated database
class SoilProfile {
  final double ph;
  final double organicCarbonPct; // e.g. 0.62%
  final String nitrogenStatusEn;
  final String nitrogenStatusHi;
  final double clayPct;
  final double sandPct;
  final String textureEn;
  final String textureHi;
  final bool isLive;

  const SoilProfile({
    required this.ph,
    required this.organicCarbonPct,
    required this.nitrogenStatusEn,
    required this.nitrogenStatusHi,
    required this.clayPct,
    required this.sandPct,
    required this.textureEn,
    required this.textureHi,
    this.isLive = false,
  });

  String getTexture(bool isHindi) => isHindi ? textureHi : textureEn;
  String getNitrogenStatus(bool isHindi) => isHindi ? nitrogenStatusHi : nitrogenStatusEn;

  factory SoilProfile.fallback() {
    return const SoilProfile(
      ph: 6.6,
      organicCarbonPct: 0.58,
      nitrogenStatusEn: 'Moderate (Supplemental Urea / Compost Advised)',
      nitrogenStatusHi: 'मध्यम (संतुलित यूरिया व गोबर खाद उपयोगी)',
      clayPct: 26.0,
      sandPct: 41.0,
      textureEn: 'Sandy Clay Loam',
      textureHi: 'बलुई दोमट मिट्टी',
      isLive: false,
    );
  }
}

/// Complete cross-app agricultural context fed into Gemini for tailored farm conclusions
class FarmIntelSnapshot {
  final WeatherForecast weather;
  final SoilProfile soil;
  final String farmerName;
  final String locationLabel;
  final double totalAcres;
  final List<String> activeCrops;
  final double totalIncome;
  final double totalExpense;
  final double netProfit;
  final String topExpenseCategory;
  final String fungalRiskLevel; // 'low' | 'moderate' | 'high'
  final String promptContext;

  const FarmIntelSnapshot({
    required this.weather,
    required this.soil,
    required this.farmerName,
    required this.locationLabel,
    required this.totalAcres,
    required this.activeCrops,
    required this.totalIncome,
    required this.totalExpense,
    required this.netProfit,
    required this.topExpenseCategory,
    required this.fungalRiskLevel,
    required this.promptContext,
  });
}

/// Central Agricultural Intelligence Service combining:
/// 1. ISRIC SoilGrids REST API (free GPS topsoil pH, clay/sand, organic carbon)
/// 2. OGD India data.gov.in Agmarknet Live Mandi API (optional free key)
/// 3. Cross-screen Data Synthesis (Weather + Soil + Farm + Ledger + Mandi)
class AgroIntelService {
  static final AgroIntelService _instance = AgroIntelService._internal();
  factory AgroIntelService() => _instance;
  AgroIntelService._internal();

  /// Optional: Free API key from https://data.gov.in for live Agmarknet daily prices
  /// Resource ID: 9ef84268-d588-465a-a308-a864a43d0070
  static String dataGovApiKey = '';

  SoilProfile? _cachedSoil;
  double? _cachedSoilLat;
  double? _cachedSoilLon;

  /// Fetches real topsoil pH, organic carbon, and texture via ISRIC SoilGrids REST API
  Future<SoilProfile> fetchSoilProfile({double? lat, double? lon}) async {
    final wService = WeatherService();
    final targetLat = lat ?? wService.activeLat;
    final targetLon = lon ?? wService.activeLon;

    if (_cachedSoil != null &&
        _cachedSoilLat != null &&
        _cachedSoilLon != null &&
        (targetLat - _cachedSoilLat!).abs() < 0.05 &&
        (targetLon - _cachedSoilLon!).abs() < 0.05) {
      return _cachedSoil!;
    }

    try {
      final url =
          'https://rest.isric.org/soilgrids/v2.0/properties/query'
          '?lon=${targetLon.toStringAsFixed(4)}'
          '&lat=${targetLat.toStringAsFixed(4)}'
          '&property=phh2o&property=nitrogen&property=soc&property=clay&property=sand'
          '&depth=0-5cm&value=mean';

      final body = await httpGet(url).timeout(const Duration(milliseconds: 3500));
      if (body != null && body.isNotEmpty) {
        final data = jsonDecode(body);
        final layers = (data['properties']?['layers'] as List?) ?? [];
        if (layers.isNotEmpty) {
          double ph = 6.6;
          double soc = 5.8; // dg/kg
          double nitrogen = 140.0; // cg/kg
          double clay = 260.0; // g/kg
          double sand = 410.0; // g/kg

          for (final l in layers) {
            final name = l['name']?.toString() ?? '';
            final depths = (l['depths'] as List?) ?? [];
            final val = depths.isNotEmpty ? (depths[0]['values']?['mean'] as num?)?.toDouble() : null;
            if (val == null) continue;
            if (name == 'phh2o') ph = val / 10.0;
            if (name == 'soc') soc = val / 10.0; // g/kg
            if (name == 'nitrogen') nitrogen = val;
            if (name == 'clay') clay = val / 10.0; // %
            if (name == 'sand') sand = val / 10.0; // %
          }

          final ocPct = double.parse((soc / 10.0).toStringAsFixed(2));
          final texturePair = _classifySoilTexture(clay, sand);
          final nPair = _classifyNitrogen(nitrogen);

          _cachedSoil = SoilProfile(
            ph: double.parse(ph.toStringAsFixed(1)),
            organicCarbonPct: ocPct.clamp(0.1, 5.0),
            nitrogenStatusEn: nPair.$1,
            nitrogenStatusHi: nPair.$2,
            clayPct: double.parse(clay.toStringAsFixed(1)),
            sandPct: double.parse(sand.toStringAsFixed(1)),
            textureEn: texturePair.$1,
            textureHi: texturePair.$2,
            isLive: true,
          );
          _cachedSoilLat = targetLat;
          _cachedSoilLon = targetLon;
          return _cachedSoil!;
        }
      }
    } catch (e) {
      debugPrint('SoilGrids API fallback: $e');
    }

    return SoilProfile.fallback();
  }

  (String, String) _classifySoilTexture(double clayPct, double sandPct) {
    if (clayPct >= 35) return ('Clayey Soil (High Water Retention)', 'चिकनी मिट्टी (अधिक नमी धारण)');
    if (sandPct >= 65) return ('Sandy Soil (Fast Draining)', 'बलुई मिट्टी (हल्की व जल्दी सूखने वाली)');
    if (clayPct >= 20 && sandPct <= 55) return ('Clay Loam (Fertile)', 'दोमट / मटियार मिट्टी (उपजाऊ)');
    return ('Sandy Clay Loam', 'बलुई दोमट मिट्टी');
  }

  (String, String) _classifyNitrogen(double nitrogenCgKg) {
    if (nitrogenCgKg >= 200) return ('Good Organic Nitrogen', 'उत्तम नाइट्रोजन स्तर');
    if (nitrogenCgKg >= 120) return ('Moderate Nitrogen (Split Urea Needed)', 'मध्यम नाइट्रोजन (संतुलित यूरिया जरूरी)');
    return ('Low Nitrogen (Add Urea + Compost)', 'कम नाइट्रोजन (यूरिया व जैविक खाद बढ़ाएं)');
  }

  /// Optional live Govt Agmarknet Daily Prices via data.gov.in API
  Future<List<Map<String, dynamic>>?> fetchDataGovMandiRates({
    required String cropName,
    String? state,
  }) async {
    if (dataGovApiKey.trim().isEmpty) return null;

    try {
      final commodity = Uri.encodeComponent(cropName);
      var url =
          'https://api.data.gov.in/resource/9ef84268-d588-465a-a308-a864a43d0070'
          '?api-key=${dataGovApiKey.trim()}&format=json&limit=8&filters%5Bcommodity%5D=$commodity';
      if (state != null && state.isNotEmpty) {
        url += '&filters%5Bstate%5D=${Uri.encodeComponent(state)}';
      }

      final res = await httpGet(url).timeout(const Duration(milliseconds: 3800));
      if (res != null && res.isNotEmpty) {
        final data = jsonDecode(res);
        final records = data['records'] as List?;
        if (records != null && records.isNotEmpty) {
          return records.map<Map<String, dynamic>>((r) {
            final rec = Map<String, dynamic>.from(r as Map);
            return {
              'mandiName': '${rec['market'] ?? 'APMC'} Mandi',
              'district': (rec['district'] ?? 'District').toString(),
              'state': (rec['state'] ?? 'India').toString(),
              'distance': 'Live Govt Feed',
              'minPrice': int.tryParse(rec['min_price']?.toString() ?? '') ?? 4500,
              'maxPrice': int.tryParse(rec['max_price']?.toString() ?? '') ?? 5200,
              'modalPrice': int.tryParse(rec['modal_price']?.toString() ?? '') ?? 4900,
              'variety': (rec['variety'] ?? 'Standard Grade').toString(),
              'source': 'Agmarknet Official (data.gov.in)',
              'arrival': 'Govt Verified Today',
              'priceChange': 'Live',
              'isUp': true,
            };
          }).toList();
        }
      }
    } catch (e) {
      debugPrint('data.gov.in Agmarknet API error: $e');
    }
    return null;
  }

  /// Calculates real fungal/blight disease pressure from live humidity, temp & rain chance
  String computeFungalRisk({
    required int humidity,
    required double temperature,
    required int rainChance,
  }) {
    if ((humidity >= 78 && temperature >= 16 && temperature <= 28) || rainChance >= 65) {
      return 'high';
    }
    if (humidity >= 65 || rainChance >= 35) {
      return 'moderate';
    }
    return 'low';
  }

  /// Combines Storage + Weather + SoilGrids + Mandi into one unified intelligence snapshot
  Future<FarmIntelSnapshot> buildFarmIntelSnapshot() async {
    final storage = StorageService();
    final profile = storage.getProfile();
    final farm = storage.getPrimaryFarm();
    final entries = storage.getLedgerEntries();
    final diary = storage.getDiaryEntries();

    final weather = await WeatherService().getWeather();
    final soil = await fetchSoilProfile();

    final cropSet = <String>{};
    for (final f in farm.fields) {
      if (f.crop.trim().isNotEmpty) cropSet.add(f.crop.trim());
    }
    for (final c in farm.crops) {
      if (c.name.trim().isNotEmpty) cropSet.add(c.name.trim());
    }
    if (cropSet.isEmpty) {
      cropSet.addAll(['Mustard', 'Wheat']);
    }

    final totalIncome = storage.getTotalIncome();
    final totalExpense = storage.getTotalExpense();
    final netProfit = storage.getNetProfit();

    final Map<String, double> catSpend = {};
    for (final e in entries) {
      if (!e.isIncome) {
        catSpend[e.category] = (catSpend[e.category] ?? 0) + e.amount;
      }
    }
    String topExpenseCategory = 'General';
    double topAmt = -1;
    catSpend.forEach((k, v) {
      if (v > topAmt) {
        topAmt = v;
        topExpenseCategory = k;
      }
    });

    final fungalRisk = computeFungalRisk(
      humidity: weather.humidity,
      temperature: weather.temperature,
      rainChance: weather.rainChance,
    );

    final mandi = MandiService();
    final cropRates = cropSet.take(3).map((c) {
      final rate = mandi.getBenchmarkPrice(c);
      return '$c: ₹$rate/Qtl';
    }).join(', ');

    final recentDiary = diary.take(2).map((d) => '${d.title} (${d.category})').join('; ');

    final locLabel = WeatherService().activeLocationName.isNotEmpty
        ? WeatherService().activeLocationName
        : (profile.village.isNotEmpty ? '${profile.village}, ${profile.district}' : 'Medininagar, Palamu');

    final ctx = '''
Farmer: ${profile.name.isNotEmpty ? profile.name : 'Kisan Ji'} | Location: $locLabel
Farm Size: ${farm.totalArea.toStringAsFixed(1)} acres | Active Crops: ${cropSet.join(', ')}
Live Weather: ${weather.temperature.toStringAsFixed(1)}°C (${weather.condition}), Humidity ${weather.humidity}%, Rain Prob ${weather.rainChance}%, Wind ${weather.windSpeed} km/h
7-Day Accumulated Rainfall: ${weather.past7DaysRainMm} mm | Daily Evaporation Loss (ET0): ${weather.evapotranspiration} mm/day
Live Soil Telemetry: Surface Moisture ${weather.soilMoistureSurface}%, Root-Depth (3-9cm) Moisture ${weather.soilMoistureRoot}%, Soil Temp ${weather.soilTemperature}°C
Satellite Soil Profile: pH ${soil.ph}, Texture ${soil.textureEn}, Organic Carbon ${soil.organicCarbonPct}%
Disease Outbreak Pressure: ${fungalRisk.toUpperCase()}
Kisan Ledger Summary: Total Income ₹${totalIncome.toStringAsFixed(0)}, Total Expense ₹${totalExpense.toStringAsFixed(0)}, Net Profit ₹${netProfit.toStringAsFixed(0)}, Highest Spend Category: $topExpenseCategory
Current Mandi Benchmarks: $cropRates
Recent Farm Notes: ${recentDiary.isNotEmpty ? recentDiary : 'None recorded yet'}
'''.trim();

    return FarmIntelSnapshot(
      weather: weather,
      soil: soil,
      farmerName: profile.name.isNotEmpty ? profile.name : 'Kisan Ji',
      locationLabel: locLabel,
      totalAcres: farm.totalArea,
      activeCrops: cropSet.toList(),
      totalIncome: totalIncome,
      totalExpense: totalExpense,
      netProfit: netProfit,
      topExpenseCategory: topExpenseCategory,
      fungalRiskLevel: fungalRisk,
      promptContext: ctx,
    );
  }
}
